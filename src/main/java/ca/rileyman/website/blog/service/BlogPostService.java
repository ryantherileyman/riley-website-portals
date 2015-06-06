package ca.rileyman.website.blog.service;

import java.util.Collection;

import ca.rileyman.website.blog.model.BlogPost;
import ca.rileyman.website.blog.model.input.NewCommentInput;
import ca.rileyman.website.blog.search.BlogPostNavSearch;
import ca.rileyman.website.blog.service.result.InitialBlogPostListResult;
import ca.rileyman.website.blog.service.result.SaveNewCommentResult;

/**
 * Service for blog posts.
 */
public interface BlogPostService
{
	
	/**
	 * Loads the initial group of active blog posts in the given blog.
	 * 
	 * @param blogCode
	 * @param count
	 * @return Initial blog post list result
	 */
	InitialBlogPostListResult loadInitialBlogPosts(String blogCode, int count);
	
	/**
	 * Loads all active blog posts, using the given navigation-based search criteria.
	 * 
	 * @param search Navigation-based search criteria
	 * @return Collection of blog posts, with the most recent first
	 */
	Collection<BlogPost> loadActiveBlogPostsByNavSearch(BlogPostNavSearch search);
	
	/**
	 * Attempts to save a new blog post comment.
	 * 
	 * @param input Inputs
	 * @return Save result
	 */
	SaveNewCommentResult saveNewComment(NewCommentInput input);
	
}
