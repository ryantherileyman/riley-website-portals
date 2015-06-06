package ca.rileyman.website.blog.dao;

import java.util.Collection;
import java.util.Date;

import ca.rileyman.website.blog.model.BlogPost;
import ca.rileyman.website.blog.model.BlogPostComment;
import ca.rileyman.website.blog.model.input.NewCommentInput;
import ca.rileyman.website.blog.search.BlogPostNavSearch;

/**
 * Provides data access for blog posts.
 */
public interface BlogPostDao {
	
	/**
	 * Retrieves the number of active blog posts in the given blog.
	 * 
	 * @param blogCode
	 * @return Number of active blog posts
	 */
	int getActiveBlogPostCount(String blogCode);
	
	/**
	 * Loads all active blog posts, using the given navigation-based search criteria.
	 * 
	 * @param search Navigation-based search criteria
	 * @return Collection of blog posts, with the most recent first
	 */
	Collection<BlogPost> loadActiveBlogPostsByNavSearch(BlogPostNavSearch search);
	
	/**
	 * Determines if the given blog post is currently accepting comments.
	 * 
	 * @param blogId
	 * @param postId
	 * @return <code>true</code> if the given blog post is currently accepting comments
	 */
	boolean getBlogPostAcceptsComments(Long blogId, Long postId);
	
	/**
	 * Retrieves the date and time of the most recent comment on the given blog.
	 * 
	 * @param blogId
	 * @return Date and time of the most recent comment
	 */
	Date getDatetimeOfMostRecentComment(Long blogId);
	
	/**
	 * Saves a new blog post comment.
	 * 
	 * @param input Input values
	 * @return Newly saved blog post comment
	 */
	BlogPostComment saveNewComment(NewCommentInput input);
	
}
