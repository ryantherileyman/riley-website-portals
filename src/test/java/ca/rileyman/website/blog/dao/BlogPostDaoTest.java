package ca.rileyman.website.blog.dao;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests;
import org.testng.Assert;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import ca.rileyman.common.test.SqlFileTestUtils;
import ca.rileyman.website.blog.dao.db.BlogDatabaseConstants;
import ca.rileyman.website.blog.dao.db.BlogPostCommentRowMapper;
import ca.rileyman.website.blog.model.BlogPost;
import ca.rileyman.website.blog.model.BlogPostComment;
import ca.rileyman.website.blog.model.input.NewCommentInput;
import ca.rileyman.website.blog.search.BlogPostNavSearch;

@SuppressWarnings("javadoc")
@ContextConfiguration(value={"/riley-test-datasource-context.xml"})
public class BlogPostDaoTest
extends AbstractTransactionalTestNGSpringContextTests
{
	
	@Autowired
	private BlogPostDao blogPostDao;
	
	@Test
	public void testGetActiveBlogPostCount() {
		setupBlogPostTestData();
		
		int actual = blogPostDao.getActiveBlogPostCount("ZTESTZ_1");
		Assert.assertEquals(actual, 3);
	}
	
	@Test
	public void testLoadActiveBlogPostsByNavSearch_All() {
		setupBlogPostTestData();
		
		BlogPostNavSearch search = new BlogPostNavSearch();
		search.setBlogCode("ZTESTZ_1");
		
		Collection<BlogPost> blogPostList = blogPostDao.loadActiveBlogPostsByNavSearch(search);
		
		Iterator<BlogPost> blogPostIterator = blogPostList.iterator();
		assertBlogPost4(blogPostIterator.next());
		assertBlogPost1(blogPostIterator.next());
		assertBlogPost3(blogPostIterator.next());
		Assert.assertFalse(blogPostIterator.hasNext(), "size");
	}
	
	@Test
	public void testLoadActiveBlogPostsByNavSearch_FirstTwo() {
		setupBlogPostTestData();
		
		BlogPostNavSearch search = new BlogPostNavSearch();
		search.setBlogCode("ZTESTZ_1");
		search.setStartPos(1);
		search.setCount(2);
		
		Collection<BlogPost> blogPostList = blogPostDao.loadActiveBlogPostsByNavSearch(search);
		
		Iterator<BlogPost> blogPostIterator = blogPostList.iterator();
		assertBlogPost4(blogPostIterator.next());
		assertBlogPost1(blogPostIterator.next());
		Assert.assertFalse(blogPostIterator.hasNext(), "size");
	}
	
	@Test
	public void testLoadActiveBlogPostsByNavSearch_Last() {
		setupBlogPostTestData();
		
		BlogPostNavSearch search = new BlogPostNavSearch();
		search.setBlogCode("ZTESTZ_1");
		search.setStartPos(3);
		search.setCount(2);
		
		Collection<BlogPost> blogPostList = blogPostDao.loadActiveBlogPostsByNavSearch(search);
		
		Iterator<BlogPost> blogPostIterator = blogPostList.iterator();
		assertBlogPost3(blogPostIterator.next());
		Assert.assertFalse(blogPostIterator.hasNext(), "size");
	}
	
	private void setupBlogPostTestData() {
		Collection<String> sqlStringList;
		sqlStringList = SqlFileTestUtils.loadSqlStringListFromResource(BlogPostDao.class, "BlogPostDaoTestData.sql");
		SqlFileTestUtils.executeSqlStrings(jdbcTemplate, sqlStringList);
	}
	
	private void assertBlogPost4(BlogPost blogPost) {
		Assert.assertEquals(blogPost.getPostId(), new Long(4), "postId");
		Assert.assertEquals(blogPost.getPostTitle(), "Test First Post", "postTitle");
		
		Iterator<BlogPostComment> commentIterator = blogPost.getCommentList().iterator();
		Assert.assertFalse(commentIterator.hasNext(), "comment size");
	}
	
	private void assertBlogPost1(BlogPost blogPost) {
		Assert.assertEquals(blogPost.getPostId(), new Long(1), "postId");
		Assert.assertEquals(blogPost.getPostTitle(), "Test Post Title", "postTitle");
		
		Iterator<BlogPostComment> commentIterator = blogPost.getCommentList().iterator();
		assertComment1ForBlogPost1(commentIterator.next());
		Assert.assertFalse(commentIterator.hasNext(), "comment size");
	}
	
	private void assertComment1ForBlogPost1(BlogPostComment comment) {
		Assert.assertEquals(comment.getCommentId(), new Long(1), "commentId");
		Assert.assertEquals(comment.getCommentText(), "Sample comment for Test Post Title", "commentText");
		Assert.assertNull(comment.getCommenterUsername(), "commenterUsername");
	}
	
	private void assertBlogPost3(BlogPost blogPost) {
		Assert.assertEquals(blogPost.getPostId(), new Long(3), "postId");
		Assert.assertEquals(blogPost.getPostTitle(), "Test Last Post", "postTitle");
		
		Iterator<BlogPostComment> commentIterator = blogPost.getCommentList().iterator();
		assertComment1ForBlogPost3(commentIterator.next());
		assertComment2ForBlogPost3(commentIterator.next());
		assertComment3ForBlogPost3(commentIterator.next());
		Assert.assertFalse(commentIterator.hasNext(), "comment size");
	}
	
	private void assertComment1ForBlogPost3(BlogPostComment comment) {
		Assert.assertEquals(comment.getCommentId(), new Long(4), "commentId");
		Assert.assertEquals(comment.getCommentText(), "You deleted his comment, but that makes my last comment look foolish.  You're making Jesus look foolish!", "commentText");
		Assert.assertEquals(comment.getCommenterUsername(), "Jesus Christ", "commenterUsername");
	}
	
	private void assertComment2ForBlogPost3(BlogPostComment comment) {
		Assert.assertEquals(comment.getCommentId(), new Long(3), "commentId");
		Assert.assertEquals(comment.getCommentText(), "That anonymous comment was uncalled for!", "commentText");
		Assert.assertEquals(comment.getCommenterUsername(), "Jesus Christ", "commenterUsername");
	}
	
	private void assertComment3ForBlogPost3(BlogPostComment comment) {
		Assert.assertEquals(comment.getCommentId(), new Long(1), "commentId");
		Assert.assertEquals(comment.getCommentText(), "Sample comment 1 for Test Last Post", "commentText");
		Assert.assertEquals(comment.getCommenterUsername(), "Commenter", "commenterUsername");
	}
	
	@DataProvider(name="GetBlogPostAcceptsComments")
	public Object[][] dataProvider_GetBlogPostAcceptsComments() {
		return( new Object[][] {
			{ -1L, 1L, false },
			{ -1L, 2L, false },
			{ -1L, 3L, true },
			{ -1L, 999L, false },
		});
	}
	
	@Test(dataProvider="GetBlogPostAcceptsComments")
	public void testGetBlogPostAcceptsComments(Long blogId, Long postId, boolean expectedResult) {
		setupBlogPostTestData();
		
		boolean actualResult = blogPostDao.getBlogPostAcceptsComments(blogId, postId);
		Assert.assertEquals(actualResult, expectedResult);
	}
	
	@Test
	public void testGetDatetimeOfMostRecentComment_Exists() {
		DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date EXPECTED_DATETIME = null;
		try { EXPECTED_DATETIME = formatter.parse("2015-04-12 09:00:30"); } catch ( ParseException e ) { throw new RuntimeException(e); }
		
		setupBlogPostTestData();
		
		Date datetime = blogPostDao.getDatetimeOfMostRecentComment(-1L);
		Assert.assertEquals(datetime.getTime(), EXPECTED_DATETIME.getTime());
	}
	
	@Test
	public void testGetDatetimeOfMostRecentComment_None() {
		setupBlogPostTestData();
		
		Date datetime = blogPostDao.getDatetimeOfMostRecentComment(-3L);
		Assert.assertNull(datetime);
	}
	
	private static final Long NEW_COMMENT_BLOG_ID = -1L;
	private static final Long NEW_COMMENT_POST_ID = 3L;
	private static final Long NEW_COMMENT_EXPECTED_COMMENT_ID = 5L;
	
	@Test
	public void testSaveNewComment() {
		setupBlogPostTestData();
		
		NewCommentInput input = new NewCommentInput(NEW_COMMENT_BLOG_ID, NEW_COMMENT_POST_ID);
		input.setCommentText("New test comment");
		input.setCommenterUsername("New Poster");
		
		BlogPostComment comment = blogPostDao.saveNewComment(input);
		assertNewComment(comment);
		
		BlogPostComment savedComment = loadBlogPostComment(NEW_COMMENT_BLOG_ID, NEW_COMMENT_POST_ID, NEW_COMMENT_EXPECTED_COMMENT_ID);
		assertNewComment(savedComment);
	}
	
	private void assertNewComment(BlogPostComment comment) {
		Assert.assertEquals(comment.getBlogId(), NEW_COMMENT_BLOG_ID, "blogId");
		Assert.assertEquals(comment.getPostId(), NEW_COMMENT_POST_ID, "postId");
		Assert.assertEquals(comment.getCommentId(), NEW_COMMENT_EXPECTED_COMMENT_ID, "commentId");
		Assert.assertEquals(comment.getCommentText(), "New test comment", "commentText");
		Assert.assertNotNull(comment.getCommentDate(), "commentDate");
		Assert.assertEquals(comment.getCommenterUsername(), "New Poster", "commenterUsername");
		Assert.assertEquals(comment.getActive(), Boolean.TRUE, "active");
	}
	
	private BlogPostComment loadBlogPostComment(Long blogId, Long postId, Long commentId) {
		String sql =
			"SELECT * FROM " + BlogDatabaseConstants.BlogPostCommentTable.NAME + " " +
			"WHERE " +
				BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " = ? AND " +
				BlogDatabaseConstants.BlogPostTable.Column.POST_ID + " = ? AND " +
				BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_ID + " = ? ";
		
		BlogPostComment result = jdbcTemplate.queryForObject(
			sql,
			new BlogPostCommentRowMapper(),
			blogId,
			postId,
			commentId
		);
		return result;
	}
	
}
