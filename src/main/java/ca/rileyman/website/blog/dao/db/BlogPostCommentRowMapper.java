package ca.rileyman.website.blog.dao.db;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import ca.rileyman.common.core.dao.RowMapperUtils;
import ca.rileyman.website.blog.model.BlogPostComment;

/**
 * Database row mapper for blog post comments.
 */
public class BlogPostCommentRowMapper
implements
	RowMapper<BlogPostComment>
{
	
	/**
	 * Maps a database row to a blog post comment.
	 * 
	 * @return Blog post comment
	 */
	public BlogPostComment mapRow(ResultSet rs, int rowNum)
	throws SQLException {
		BlogPostComment result = new BlogPostComment(
			RowMapperUtils.mapLong(rs, BlogDatabaseConstants.BlogTable.Column.BLOG_ID),
			RowMapperUtils.mapLong(rs, BlogDatabaseConstants.BlogPostTable.Column.POST_ID),
			RowMapperUtils.mapLong(rs, BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_ID)
		);
		result.setCommentText(RowMapperUtils.mapString(rs, BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_TEXT));
		result.setCommentDate(RowMapperUtils.mapDatetime(rs, BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENT_DATE));
		result.setCommenterUsername(RowMapperUtils.mapString(rs, BlogDatabaseConstants.BlogPostCommentTable.Column.COMMENTER_USERNAME));
		result.setActive(RowMapperUtils.mapFlag(rs, BlogDatabaseConstants.BlogPostCommentTable.Column.ACTIVE));
		return result;
	}
	
}
