package ca.rileyman.website.blog.model;

import java.io.Serializable;
import java.util.Date;

/**
 * Represents a single comment against a blog post.
 */
@SuppressWarnings("javadoc")
public class BlogPostComment
implements
	Serializable
{
	
	private static final long serialVersionUID = 889951201789228040L;
	
	private Long blogId;
	private Long postId;
	private Long commentId;
	private String commentText;
	private Date commentDate;
	private String commenterUsername;
	private Boolean active;
	
	public BlogPostComment(Long blogId, Long postId, Long commentId) {
		this.blogId = blogId;
		this.postId = postId;
		this.commentId = commentId;
	}
	
	public Long getBlogId() {
		return blogId;
	}
	
	public Long getPostId() {
		return postId;
	}
	
	public Long getCommentId() {
		return commentId;
	}
	
	public String getCommentText() {
		return commentText;
	}
	
	public void setCommentText(String commentText) {
		this.commentText = commentText;
	}
	
	public Date getCommentDate() {
		return commentDate;
	}
	
	public void setCommentDate(Date commentDate) {
		this.commentDate = commentDate;
	}
	
	public String getCommenterUsername() {
		return commenterUsername;
	}
	
	public void setCommenterUsername(String commenterUsername) {
		this.commenterUsername = commenterUsername;
	}
	
	public Boolean getActive() {
		return active;
	}
	
	public void setActive(Boolean active) {
		this.active = active;
	}
	
}
