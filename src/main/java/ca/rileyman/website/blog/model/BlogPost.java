package ca.rileyman.website.blog.model;

import java.io.Serializable;
import java.util.Collection;
import java.util.Date;

/**
 * Represents a single blog post.
 */
@SuppressWarnings("javadoc")
public class BlogPost
implements
	Serializable
{
	
	private static final long serialVersionUID = -2247647173737533274L;
	
	private Long blogId;
	private Long postId;
	private String postTitle;
	private String postText;
	private Date postDate;
	private String posterUsername;
	private Boolean active;
	private Boolean allowComments;
	private Date lastUpdateDate;
	private String lastUpdateUsername;
	private Collection<BlogPostComment> commentList;
	
	public BlogPost(Long blogId, Long postId) {
		this.blogId = blogId;
		this.postId = postId;
	}
	
	public Long getBlogId() {
		return blogId;
	}
	
	public Long getPostId() {
		return postId;
	}
	
	public String getPostTitle() {
		return postTitle;
	}
	
	public void setPostTitle(String postTitle) {
		this.postTitle = postTitle;
	}
	
	public String getPostText() {
		return postText;
	}
	
	public void setPostText(String postText) {
		this.postText = postText;
	}
	
	public Date getPostDate() {
		return postDate;
	}
	
	public void setPostDate(Date postDate) {
		this.postDate = postDate;
	}
	
	public String getPosterUsername() {
		return posterUsername;
	}
	
	public void setPosterUsername(String posterUsername) {
		this.posterUsername = posterUsername;
	}
	
	public Boolean getActive() {
		return active;
	}
	
	public void setActive(Boolean active) {
		this.active = active;
	}
	
	public Boolean getAllowComments() {
		return allowComments;
	}
	
	public void setAllowComments(Boolean allowComments) {
		this.allowComments = allowComments;
	}
	
	public Date getLastUpdateDate() {
		return lastUpdateDate;
	}
	
	public void setLastUpdateDate(Date lastUpdateDate) {
		this.lastUpdateDate = lastUpdateDate;
	}
	
	public String getLastUpdateUsername() {
		return lastUpdateUsername;
	}
	
	public void setLastUpdateUsername(String lastUpdateUsername) {
		this.lastUpdateUsername = lastUpdateUsername;
	}
	
	public Collection<BlogPostComment> getCommentList() {
		return commentList;
	}
	
	public void setCommentList(Collection<BlogPostComment> commentList) {
		this.commentList = commentList;
	}
	
}
