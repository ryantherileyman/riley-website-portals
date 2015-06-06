package ca.rileyman.website.blog.dao.db;

/**
 * Provides database constants for blog tables.
 */
public final class BlogDatabaseConstants
{
	
	@SuppressWarnings("javadoc")
	public final class BlogTable {
		
		public static final String NAME = "r3_blog";
		
		public final class Column {
			public static final String BLOG_ID = "blog_id";
			public static final String BLOG_CODE = "blog_code";
		}
		
	}
	
	@SuppressWarnings("javadoc")
	public final class BlogPostTable {
		
		public static final String NAME = "r3_blog_post";
		
		public final class Column {
			public static final String POST_ID = "post_id";
			public static final String POST_TITLE = "post_title";
			public static final String POST_TEXT = "post_text";
			public static final String POST_DATE = "post_date";
			public static final String POSTER_USERNAME = "poster_username";
			public static final String ACTIVE = "active_flag";
			public static final String ALLOW_COMMENTS = "allow_comments_flag";
			public static final String LAST_UPDATE_DATE = "last_update_date";
			public static final String LAST_UPDATE_USERNAME = "last_update_username";
		}
		
	}
	
	@SuppressWarnings("javadoc")
	public final class BlogPostCommentTable {
		
		public static final String NAME = "r3_blog_post_comment";
		
		public final class Column {
			public static final String COMMENT_ID = "comment_id";
			public static final String COMMENT_TEXT = "comment_text";
			public static final String COMMENT_DATE = "comment_date";
			public static final String COMMENTER_USERNAME = "commenter_username";
			public static final String ACTIVE = "active_flag";
		}
		
	}
	
}
