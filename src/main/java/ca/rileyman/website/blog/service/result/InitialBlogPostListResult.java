package ca.rileyman.website.blog.service.result;

import java.io.Serializable;
import java.util.Collection;

import ca.rileyman.website.blog.model.BlogPost;

/**
 * Results of loading the initial list of blog posts.
 */
@SuppressWarnings("javadoc")
public class InitialBlogPostListResult
implements
	Serializable
{
	
	private static final long serialVersionUID = 1808550441876945216L;
	
	private int blogPostCount;
	private Collection<BlogPost> initialBlogPostList;
	
	public InitialBlogPostListResult(
		int blogPostCount,
		Collection<BlogPost> initialBlogPostList
	) {
		this.blogPostCount = blogPostCount;
		this.initialBlogPostList = initialBlogPostList;
	}
	
	public int getBlogPostCount() {
		return blogPostCount;
	}
	
	public Collection<BlogPost> getInitialBlogPostList() {
		return initialBlogPostList;
	}
	
}
