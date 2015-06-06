package ca.rileyman.website.blog.search;

import java.io.Serializable;

/**
 * Provides navigation-based search parameters for blog posts within some given blog.
 */
@SuppressWarnings("javadoc")
public class BlogPostNavSearch
implements
	Serializable
{
	
	private static final long serialVersionUID = -3677162719324608146L;
	
	private String blogCode;
	private Integer startPos;
	private Integer count;
	
	public String getBlogCode() {
		return blogCode;
	}
	
	public void setBlogCode(String blogCode) {
		this.blogCode = blogCode;
	}
	
	public Integer getStartPos() {
		return startPos;
	}
	
	public void setStartPos(Integer startPos) {
		if (
			( startPos != null ) &&
			( startPos < 1 )
		) {
			throw new IllegalArgumentException();
		}
		
		this.startPos = startPos;
	}
	
	public Integer getCount() {
		return count;
	}
	
	public void setCount(Integer count) {
		if (
			( count != null ) &&
			( count < 0 )
		) {
			throw new IllegalArgumentException();
		}
		
		this.count = count;
	}
	
	public String debugString() {
		String result = "{ " +
			"blogCode = <" + blogCode + ">, " +
			"startPos = <" + startPos + ">, " +
			"count = <" + count + ">" +
			"}";
		return result;
	}
	
}
