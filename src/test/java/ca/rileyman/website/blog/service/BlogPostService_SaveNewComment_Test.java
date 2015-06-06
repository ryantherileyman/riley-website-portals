package ca.rileyman.website.blog.service;

import java.util.Calendar;
import java.util.Collection;
import java.util.Date;

import org.testng.Assert;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import ca.rileyman.common.general.dao.CalendarDao;
import ca.rileyman.website.blog.dao.BlogPostDao;
import ca.rileyman.website.blog.model.BlogPost;
import ca.rileyman.website.blog.model.BlogPostComment;
import ca.rileyman.website.blog.model.input.NewCommentInput;
import ca.rileyman.website.blog.search.BlogPostNavSearch;
import ca.rileyman.website.blog.service.impl.BlogPostServiceImpl;
import ca.rileyman.website.blog.service.result.SaveNewCommentResult;
import ca.rileyman.website.blog.service.result.SaveNewCommentResult.FailureReason;

@SuppressWarnings("javadoc")
public class BlogPostService_SaveNewComment_Test
{
	
	private static final Long TEST_BLOG_ID = 1L;
	private static final Long TEST_POST_ID = 1L;
	
	@Test
	public void testSaveNewComment_PostNotAcceptingComments() {
		BlogPostService blogPostService = new BlogPostServiceImpl(new MockCalendarDao(), new NotAcceptingCommentsMockBlogPostDao());
		
		NewCommentInput newCommentInput = new NewCommentInput(TEST_BLOG_ID, TEST_POST_ID);
		newCommentInput.setCommentText("Test post not accepting comments");
		
		SaveNewCommentResult saveNewCommentResult = blogPostService.saveNewComment(newCommentInput);
		
		Assert.assertFalse(saveNewCommentResult.getSuccess(), "success");
		Assert.assertEquals(saveNewCommentResult.getFailureReason(), SaveNewCommentResult.FailureReason.POST_NOT_ACCEPTING_COMMENTS, "failureReason");
		Assert.assertNull(saveNewCommentResult.getComment(), "comment");
	}
	
	@DataProvider(name="CommentEmpty")
	public Object[][] dataProvider_CommentEmpty() {
		return( new Object[][] {
			{ null },
			{ "" },
			{ " " },
		});
	}
	
	@Test(dataProvider="CommentEmpty")
	public void testSaveNewComment_CommentEmpty(String commentText) {
		BlogPostService blogPostService = new BlogPostServiceImpl(new MockCalendarDao(), new SuccessfulMockBlogPostDao());
		
		NewCommentInput newCommentInput = new NewCommentInput(TEST_BLOG_ID, TEST_POST_ID);
		newCommentInput.setCommentText(commentText);
		
		SaveNewCommentResult saveNewCommentResult = blogPostService.saveNewComment(newCommentInput);
		
		Assert.assertFalse(saveNewCommentResult.getSuccess(), "success");
		Assert.assertEquals(saveNewCommentResult.getFailureReason(), FailureReason.COMMENT_EMPTY, "failureReason");
		Assert.assertNull(saveNewCommentResult.getComment(), "comment");
	}
	
	@Test
	public void testSaveNewComment_CommentTooLong() {
		BlogPostService blogPostService = new BlogPostServiceImpl(new MockCalendarDao(), new SuccessfulMockBlogPostDao());
		
		StringBuilder longCommentText = new StringBuilder();
		for ( int i = 0; i < 65536; i++ ) {
			longCommentText.append('a');
		}
		
		NewCommentInput newCommentInput = new NewCommentInput(TEST_BLOG_ID, TEST_POST_ID);
		newCommentInput.setCommentText(longCommentText.toString());
		
		SaveNewCommentResult saveNewCommentResult = blogPostService.saveNewComment(newCommentInput);
		
		Assert.assertFalse(saveNewCommentResult.getSuccess(), "success");
		Assert.assertEquals(saveNewCommentResult.getFailureReason(), FailureReason.COMMENT_TOO_LONG, "failureReason");
		Assert.assertNull(saveNewCommentResult.getComment(), "comment");
	}
	
	@Test
	public void testSaveNewComment_SpamDetection() {
		BlogPostService blogPostService = new BlogPostServiceImpl(new MockCalendarDao(), new SpamDetectionMockBlogPostDao());
		
		NewCommentInput newCommentInput = new NewCommentInput(TEST_BLOG_ID, TEST_POST_ID);
		newCommentInput.setCommentText("Test comment");
		
		SaveNewCommentResult saveNewCommentResult = blogPostService.saveNewComment(newCommentInput);
		
		Assert.assertFalse(saveNewCommentResult.getSuccess(), "success");
		Assert.assertEquals(saveNewCommentResult.getFailureReason(), FailureReason.SPAM_DETECTION, "failureReason");
		Assert.assertNull(saveNewCommentResult.getComment(), "comment");
	}
	
	@Test
	public void testSaveNewComment_Success() {
		BlogPostService blogPostService = new BlogPostServiceImpl(new MockCalendarDao(), new SuccessfulMockBlogPostDao());
		
		NewCommentInput newCommentInput = new NewCommentInput(TEST_BLOG_ID, TEST_POST_ID);
		newCommentInput.setCommentText("Test comment");
		
		SaveNewCommentResult saveNewCommentResult = blogPostService.saveNewComment(newCommentInput);
		
		Assert.assertTrue(saveNewCommentResult.getSuccess(), "success");
		Assert.assertNull(saveNewCommentResult.getFailureReason(), "failureReason");
		Assert.assertNotNull(saveNewCommentResult.getComment(), "comment");
	}
	
	private static class MockCalendarDao
	implements CalendarDao
	{
		
		public Date getCurrentDatetime() {
			Calendar mockDatetime = Calendar.getInstance();
			mockDatetime.set(2015, 4, 16, 7, 58, 30);
			
			Date result = mockDatetime.getTime();
			return result;
		}
		
	}
	
	private static class SuccessfulMockBlogPostDao
	implements BlogPostDao
	{
		
		public int getActiveBlogPostCount(String blogCode) {
			return 0;
		}
		
		public Collection<BlogPost> loadActiveBlogPostsByNavSearch(BlogPostNavSearch search) {
			return null;
		}
		
		public boolean getBlogPostAcceptsComments(Long blogId, Long postId) {
			return true;
		}
		
		public Date getDatetimeOfMostRecentComment(Long blogId) {
			Calendar mockDatetime = Calendar.getInstance();
			mockDatetime.set(2015, 4, 16, 7, 58, 27);
			
			Date result = mockDatetime.getTime();
			return result;
		}
		
		public BlogPostComment saveNewComment(NewCommentInput input) {
			Calendar now = Calendar.getInstance();
			now.set(2015, 4, 16, 7, 58, 30);
			
			BlogPostComment result = new BlogPostComment(input.getBlogId(), input.getPostId(), 1L);
			result.setActive(true);
			result.setCommentText(input.getCommentText());
			result.setCommenterUsername(input.getCommenterUsername());
			result.setCommentDate(now.getTime());
			
			return result;
		}
		
	}
	
	private static class NotAcceptingCommentsMockBlogPostDao
	extends SuccessfulMockBlogPostDao
	{
		
		public boolean getBlogPostAcceptsComments(Long blogId, Long postId) {
			return false;
		}
		
	}
	
	private static class SpamDetectionMockBlogPostDao
	extends SuccessfulMockBlogPostDao
	{
		
		public Date getDatetimeOfMostRecentComment(Long blogId) {
			Calendar mockDatetime = Calendar.getInstance();
			mockDatetime.set(2015, 4, 16, 7, 58, 28);
			
			Date result = mockDatetime.getTime();
			return result;
		}
		
	}
	
}
