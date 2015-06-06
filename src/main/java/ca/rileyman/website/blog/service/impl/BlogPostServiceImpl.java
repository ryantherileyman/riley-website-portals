package ca.rileyman.website.blog.service.impl;

import java.util.Calendar;
import java.util.Collection;
import java.util.Date;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import ca.rileyman.common.general.dao.CalendarDao;
import ca.rileyman.website.blog.dao.BlogPostDao;
import ca.rileyman.website.blog.model.BlogPost;
import ca.rileyman.website.blog.model.BlogPostComment;
import ca.rileyman.website.blog.model.input.NewCommentInput;
import ca.rileyman.website.blog.search.BlogPostNavSearch;
import ca.rileyman.website.blog.service.BlogPostService;
import ca.rileyman.website.blog.service.result.InitialBlogPostListResult;
import ca.rileyman.website.blog.service.result.SaveNewCommentResult;

/**
 * Application implementation of the blog post service.
 */
@Service
public class BlogPostServiceImpl
implements BlogPostService
{
	
	private static final Logger log = LoggerFactory.getLogger(BlogPostServiceImpl.class);
	
	private CalendarDao calendarDao;
	private BlogPostDao blogPostDao;
	
	@SuppressWarnings("javadoc")
	@Autowired
	public BlogPostServiceImpl(
		CalendarDao calendarDao,
		BlogPostDao blogPostDao
	) {
		this.calendarDao = calendarDao;
		this.blogPostDao = blogPostDao;
	}
	
	@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)
	public InitialBlogPostListResult loadInitialBlogPosts(String blogCode, int count) {
		log.debug("Entering with blogCode = <{}>", blogCode);
		log.debug("and count = <{}>", count);
		
		int blogPostCount = blogPostDao.getActiveBlogPostCount(blogCode);
		
		BlogPostNavSearch search = createInitialBlogPostNavSearch(blogCode, count);
		Collection<BlogPost> blogPostList = blogPostDao.loadActiveBlogPostsByNavSearch(search);
		
		InitialBlogPostListResult result = new InitialBlogPostListResult(blogPostCount, blogPostList);
		
		log.debug("Exiting");
		return result;
	}
	
	private BlogPostNavSearch createInitialBlogPostNavSearch(String blogCode, int count) {
		log.debug("Entering");
		
		BlogPostNavSearch result = new BlogPostNavSearch();
		result.setBlogCode(blogCode);
		result.setStartPos(1);
		result.setCount(count);
		
		if ( log.isDebugEnabled() ) {
			log.debug("Exiting with result = <{}>", result);
		}
		return result;
	}
	
	@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)
	public Collection<BlogPost> loadActiveBlogPostsByNavSearch(BlogPostNavSearch search) {
		if ( log.isDebugEnabled() ) {
			log.debug("Entering with <{}>", search);
		}
		
		Collection<BlogPost> result = blogPostDao.loadActiveBlogPostsByNavSearch(search);
		
		log.debug("Exiting");
		return result;
	}
	
	@Transactional(propagation=Propagation.REQUIRED, readOnly=false)
	public SaveNewCommentResult saveNewComment(NewCommentInput input) {
		SaveNewCommentResult result;
		log.debug("Entering");
		
		if ( !validatePostAcceptsComments(input) ) {
			result = SaveNewCommentResult.createFailure(SaveNewCommentResult.FailureReason.POST_NOT_ACCEPTING_COMMENTS);
		} else if ( !validateCommentNotEmpty(input.getCommentText()) ) {
			result = SaveNewCommentResult.createFailure(SaveNewCommentResult.FailureReason.COMMENT_EMPTY);
		} else if ( !validateCommentLength(input.getCommentText()) ) {
			result = SaveNewCommentResult.createFailure(SaveNewCommentResult.FailureReason.COMMENT_TOO_LONG);
		} else if ( !validateMostRecentPostNotTooSoon(input.getBlogId()) ) {
			result = SaveNewCommentResult.createFailure(SaveNewCommentResult.FailureReason.SPAM_DETECTION);
		} else {
			BlogPostComment comment = blogPostDao.saveNewComment(input);
			result = SaveNewCommentResult.createSuccess(comment);
		}
		
		log.debug("Exiting");
		return result;
	}
	
	private boolean validatePostAcceptsComments(NewCommentInput input) {
		log.debug("Entering");
		
		boolean result = blogPostDao.getBlogPostAcceptsComments(input.getBlogId(), input.getPostId());
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private boolean validateCommentNotEmpty(String comment) {
		log.debug("Entering with comment = <{}>", comment);
		
		boolean result =
			( comment != null ) &&
			( comment.trim().length() > 0 );
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private boolean validateCommentLength(String comment) {
		log.debug("Entering with comment = <{}>", comment);
		
		boolean result = ( comment.length() < 65535 );
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private boolean validateMostRecentPostNotTooSoon(Long blogId) {
		log.debug("Entering with blogId = <{}>", blogId);
		
		Date now = calendarDao.getCurrentDatetime();
		Date datetimeOfMostRecentComment = blogPostDao.getDatetimeOfMostRecentComment(blogId);
		log.debug("datetimeOfMostRecentComment = <{}>", datetimeOfMostRecentComment);
		
		Calendar threshold = Calendar.getInstance();
		threshold.setTime(now);
		threshold.add(Calendar.SECOND, -2);
		log.debug("threshold = <{}>", threshold.getTime());
		
		boolean result =
			( datetimeOfMostRecentComment == null ) ||
			( datetimeOfMostRecentComment.before(threshold.getTime()) );
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
}
