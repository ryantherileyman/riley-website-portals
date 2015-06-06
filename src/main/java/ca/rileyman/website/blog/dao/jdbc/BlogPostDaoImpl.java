package ca.rileyman.website.blog.dao.jdbc;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import ca.rileyman.website.blog.dao.BlogPostDao;
import ca.rileyman.website.blog.dao.db.BlogDatabaseConstants;
import ca.rileyman.website.blog.dao.db.BlogPostCommentRowMapper;
import ca.rileyman.website.blog.dao.db.BlogPostRowMapper;
import ca.rileyman.website.blog.model.BlogPost;
import ca.rileyman.website.blog.model.BlogPostComment;
import ca.rileyman.website.blog.model.input.NewCommentInput;
import ca.rileyman.website.blog.search.BlogPostNavSearch;

/**
 * JDBC-based implementation of the blog post data access object.
 */
@Repository
public class BlogPostDaoImpl
implements
	BlogPostDao
{
	
	private static final Logger log = LoggerFactory.getLogger(BlogPostDaoImpl.class);
	
	private JdbcTemplate jdbcTemplate;
	
	@SuppressWarnings("javadoc")
	@Autowired
	public BlogPostDaoImpl(DataSource dataSource) {
		this.jdbcTemplate = new JdbcTemplate(dataSource);
	}
	
	@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)
	public int getActiveBlogPostCount(String blogCode) {
		String sql;
		Integer result;
		log.debug("Enter with blogCode = <{}>", blogCode);
		
		sql = getSqlForActiveBlogPostCount();
		result = jdbcTemplate.queryForObject(sql, Integer.class, blogCode);
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private String getSqlForActiveBlogPostCount() {
		String result =
			"SELECT " +
				"COUNT(post." + BlogDatabaseConstants.BlogPostTable.Column.POST_ID + ") AS post_count " +
			"FROM " +
				BlogDatabaseConstants.BlogTable.NAME + " blog " +
				"LEFT JOIN " + BlogDatabaseConstants.BlogPostTable.NAME + " post ON " +
					"blog." + BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " = post." + BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " " +
			"WHERE " +
				"blog." + BlogDatabaseConstants.BlogTable.Column.BLOG_CODE + " = ? AND " +
				"post." + BlogDatabaseConstants.BlogPostTable.Column.ACTIVE + " = 'Y' ";
		return result;
	}
	
	@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)
	public Collection<BlogPost> loadActiveBlogPostsByNavSearch(BlogPostNavSearch search) {
		log.debug("Entering");
		
		BlogPostByNavSearchLoader loader = new BlogPostByNavSearchLoader(search);
		loader.loadActiveBlogPosts();
		loader.loadActiveComments();
		
		Collection<BlogPost> result = loader.getBlogPostList();
		
		log.debug("Exiting");
		return result;
	}
	
	private class BlogPostByNavSearchLoader {
		
		private BlogPostNavSearch search;
		private int actualStartPos;
		private int actualCount;
		private Collection<BlogPost> blogPostList;
		
		public BlogPostByNavSearchLoader(BlogPostNavSearch search) {
			if ( log.isDebugEnabled() ) {
				log.debug("Entering with search = <{}>", search.debugString());
			}
			
			this.search = search;
			
			this.actualStartPos = ( search.getStartPos() == null ? 0 : search.getStartPos() - 1 );
			log.debug("actualStartPos = <{}>", actualStartPos);
			
			this.actualCount = ( search.getCount() == null ? Integer.MAX_VALUE : search.getCount() );
			log.debug("actualCount = <{}>", actualCount);
			
			log.debug("Exiting");
		}
		
		public void loadActiveBlogPosts() {
			log.debug("Entering");
			
			blogPostList = jdbcTemplate.query(
				getSqlForActiveBlogPosts(),
				new BlogPostRowMapper(),
				search.getBlogCode(),
				actualStartPos,
				actualCount
			);
			
			for ( BlogPost currBlogPost : blogPostList ) {
				currBlogPost.setCommentList(new ArrayList<BlogPostComment>());
			}
			
			log.debug("Exiting");
		}
		
		private String getSqlForActiveBlogPosts() {
			final String result =
				"SELECT " +
					BlogDatabaseConstants.BlogTable.Column.BLOG_ID + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.POST_ID + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.POST_TITLE + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.POST_TEXT + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.POST_DATE + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.POSTER_USERNAME + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.ACTIVE + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.ALLOW_COMMENTS + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.LAST_UPDATE_DATE + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.LAST_UPDATE_USERNAME + " " +
				"FROM " + BlogDatabaseConstants.BlogPostTable.NAME + " " +
				"WHERE " +
					BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " = ( " +
						"SELECT " + BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " " +
						"FROM " + BlogDatabaseConstants.BlogTable.NAME + " " +
						"WHERE " + BlogDatabaseConstants.BlogTable.Column.BLOG_CODE + " = ? " +
					") AND " +
					BlogDatabaseConstants.BlogPostTable.Column.ACTIVE + " = 'Y' " +
				"ORDER BY " +
					BlogDatabaseConstants.BlogPostTable.Column.POST_DATE + " DESC " +
				"LIMIT ?, ? ";
			return result;
		}
		
		public void loadActiveComments() {
			log.debug("Entering");
			
			Collection<BlogPostComment> commentList = jdbcTemplate.query(
				getSqlForActiveBlogPostComments(),
				new BlogPostCommentRowMapper(),
				search.getBlogCode()
			);
			
			attachCommentsToBlogPosts(commentList);
			
			log.debug("Exiting");
		}
		
		private String getSqlForActiveBlogPostComments() {
			final String result =
				"SELECT " +
					BlogDatabaseConstants.BlogTable.Column.BLOG_ID + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.POST_ID + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_ID + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_TEXT + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_DATE + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENTER_USERNAME + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.ACTIVE + " " +
				"FROM " + BlogDatabaseConstants.BlogPostCommentTable.NAME + " " +
				"WHERE " +
					BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " = ( " +
						"SELECT " + BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " " +
						"FROM " + BlogDatabaseConstants.BlogTable.NAME + " " +
						"WHERE " + BlogDatabaseConstants.BlogTable.Column.BLOG_CODE + " = ? " +
					") AND " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.ACTIVE + " = 'Y' " +
				"ORDER BY " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_DATE + " DESC ";
			return result;
		}
		
		private void attachCommentsToBlogPosts(Collection<BlogPostComment> commentList) {
			log.debug("Entering");
			
			for ( BlogPostComment currComment : commentList ) {
				attachCommentToBlogPost(currComment);
			}
			
			log.debug("Exiting");
		}
		
		private void attachCommentToBlogPost(BlogPostComment comment) {
			log.debug("Entering with <{}>", comment.getCommentId());
			
			BlogPost blogPost = findBlogPost(comment.getPostId());
			if ( blogPost != null ) {
				blogPost.getCommentList().add(comment);
			}
			
			log.debug("Exiting");
		}
		
		private BlogPost findBlogPost(Long postId) {
			log.debug("Entering with postId = <{}>", postId);
			
			BlogPost result = null;
			for ( BlogPost currBlogPost : blogPostList ) {
				if ( postId.equals(currBlogPost.getPostId()) ) {
					result = currBlogPost;
					break;
				}
			}
			
			if ( result == null ) {
				log.debug("Exiting with no blogPost");
			} else {
				log.debug("Exiting with postId = <{}>", result.getPostId());
			}
			return result;
		}
		
		public Collection<BlogPost> getBlogPostList() {
			return blogPostList;
		}
		
	}
	
	@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)
	public boolean getBlogPostAcceptsComments(Long blogId, Long postId) {
		Integer blogPostCount;
		boolean result;
		log.debug("Entering with blogId = <{}>", blogId);
		log.debug("... and postId = <{}>", postId);
		
		blogPostCount = jdbcTemplate.queryForObject(
			getSqlForBlogPostAcceptsComments(),
			Integer.class,
			blogId,
			postId
		);
		result = ( blogPostCount > 0 );
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private String getSqlForBlogPostAcceptsComments() {
		String result =
			"SELECT COUNT(" + BlogDatabaseConstants.BlogPostTable.Column.POST_ID + ") " +
			"FROM " + BlogDatabaseConstants.BlogPostTable.NAME + " " +
			"WHERE " +
				BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " = ? AND " +
				BlogDatabaseConstants.BlogPostTable.Column.POST_ID + " = ? AND " +
				BlogDatabaseConstants.BlogPostTable.Column.ACTIVE + " = 'Y' AND " +
				BlogDatabaseConstants.BlogPostTable.Column.ALLOW_COMMENTS + " = 'Y'";
		return result;
	}
	
	@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)
	public Date getDatetimeOfMostRecentComment(Long blogId) {
		Date result;
		log.debug("Entering with blogId = <{}>", blogId);
		
		result = jdbcTemplate.queryForObject(
			getSqlForDatetimeOfMostRecentComment(),
			Date.class,
			blogId
		);
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private String getSqlForDatetimeOfMostRecentComment() {
		String result =
			"SELECT MAX(" + BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_DATE + ") " +
			"FROM " + BlogDatabaseConstants.BlogPostCommentTable.NAME + " " +
			"WHERE " +
				BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " = ?";
		return result;
	}
	
	@Transactional(propagation=Propagation.REQUIRED, readOnly=false)
	public BlogPostComment saveNewComment(NewCommentInput input) {
		NewCommentSaver saver;
		log.debug("Entering");
		
		saver = new NewCommentSaver(input);
		saver.save();
		
		BlogPostComment result = jdbcTemplate.queryForObject(
			getSqlForBlogPostComment(),
			new BlogPostCommentRowMapper(),
			input.getBlogId(),
			input.getPostId(),
			saver.getCommentId()
		);
		
		log.debug("Exiting");
		return result;
	}
	
	private class NewCommentSaver {
		
		private NewCommentInput input;
		private Long commentId;
		
		public NewCommentSaver(NewCommentInput input) {
			this.input = input;
		}
		
		public void save() {
			commentId = jdbcTemplate.queryForObject(
				getSqlForNewCommentId(),
				Long.class,
				input.getBlogId(),
				input.getPostId()
			);
			
			jdbcTemplate.update(
				getInsertSql(),
				input.getBlogId(),
				input.getPostId(),
				commentId,
				input.getCommentText(),
				input.getCommenterUsername()
			);
		}
		
		private String getSqlForNewCommentId() {
			String result =
				"SELECT IFNULL(MAX(" + BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_ID + "), 0) + 1 AS next_comment_id " +
				"FROM " + BlogDatabaseConstants.BlogPostCommentTable.NAME + " " +
				"WHERE " +
					BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " = ? AND " +
					BlogDatabaseConstants.BlogPostTable.Column.POST_ID + " = ? ";
			return result;
		}
		
		private String getInsertSql() {
			String result =
				"INSERT INTO " + BlogDatabaseConstants.BlogPostCommentTable.NAME + " ( " +
					BlogDatabaseConstants.BlogTable.Column.BLOG_ID + ", " +
					BlogDatabaseConstants.BlogPostTable.Column.POST_ID + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_ID + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_TEXT + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_DATE + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENTER_USERNAME + ", " +
					BlogDatabaseConstants.BlogPostCommentTable.Column.ACTIVE + " " +
				") VALUES ( ?, ?, ?, ?, NOW(), ?, 'Y' )";
			return result;
		}
		
		public Long getCommentId() {
			return commentId;
		}
		
	}
	
	private String getSqlForBlogPostComment() {
		String result =
			"SELECT " +
				BlogDatabaseConstants.BlogTable.Column.BLOG_ID + ", " +
				BlogDatabaseConstants.BlogPostTable.Column.POST_ID + ", " +
				BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_ID + ", " +
				BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_TEXT + ", " +
				BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_DATE + ", " +
				BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENTER_USERNAME + ", " +
				BlogDatabaseConstants.BlogPostCommentTable.Column.ACTIVE + " " +
			"FROM " + BlogDatabaseConstants.BlogPostCommentTable.NAME + " " +
			"WHERE " +
				BlogDatabaseConstants.BlogTable.Column.BLOG_ID + " = ? AND " +
				BlogDatabaseConstants.BlogPostTable.Column.POST_ID + " = ? AND " +
				BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_ID + " = ? ";
		return result;
	}
	
}
