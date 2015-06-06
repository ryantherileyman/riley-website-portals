package ca.rileyman.website.blog.model.input;

/**
 * Input values for saving a new comment.
 */
@SuppressWarnings("javadoc")
public class NewCommentInput
{
	
	private Long blogId;
	private Long postId;
	private String commentText;
	private String commenterUsername;
	
	public NewCommentInput(Long blogId, Long postId) {
		this.blogId = blogId;
		this.postId = postId;
	}
	
	public Long getBlogId() {
		return blogId;
	}
	public Long getPostId() {
		return postId;
	}
	
	public String getCommentText() {
		return commentText;
	}
	
	public void setCommentText(String commentText) {
		this.commentText = commentText;
	}
	
	public String getCommenterUsername() {
		return commenterUsername;
	}
	
	public void setCommenterUsername(String commenterUsername) {
		this.commenterUsername = commenterUsername;
	}
	
}
