package ca.rileyman.website.blog.service.result;

import java.io.Serializable;

import ca.rileyman.website.blog.model.BlogPostComment;

/**
 * Results of attempting to save a new blog post comment.
 */
@SuppressWarnings("javadoc")
public class SaveNewCommentResult
implements
	Serializable
{
	
	private static final long serialVersionUID = -7575954025975071989L;
	
	public static enum FailureReason {
		
		POST_NOT_ACCEPTING_COMMENTS,
		COMMENT_EMPTY,
		COMMENT_TOO_LONG,
		SPAM_DETECTION,
		;
		
	}
	
	private boolean success;
	private FailureReason failureReason;
	private BlogPostComment comment;
	
	public static SaveNewCommentResult createFailure(FailureReason failureReason) {
		SaveNewCommentResult result = new SaveNewCommentResult();
		result.success = false;
		result.failureReason = failureReason;
		return result;
	}
	
	public static SaveNewCommentResult createSuccess(BlogPostComment comment) {
		SaveNewCommentResult result = new SaveNewCommentResult();
		result.success = true;
		result.comment = comment;
		return result;
	}
	
	private SaveNewCommentResult() {
	}
	
	public boolean getSuccess() {
		return success;
	}
	
	public FailureReason getFailureReason() {
		return failureReason;
	}
	
	public BlogPostComment getComment() {
		return comment;
	}
	
}
