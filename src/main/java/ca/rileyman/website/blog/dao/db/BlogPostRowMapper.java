package ca.rileyman.website.blog.dao.db;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import ca.rileyman.common.core.dao.RowMapperUtils;
import ca.rileyman.website.blog.model.BlogPost;

/**
 * Database row mapper for blog posts.
 */
public class BlogPostRowMapper
implements
	RowMapper<BlogPost>
{
	
	/**
	 * Maps a database row to a blog post.
	 * 
	 * @return Blog post
	 */
	public BlogPost mapRow(ResultSet rs, int rowNum)
	throws SQLException {
		BlogPost result = new BlogPost(
			RowMapperUtils.mapLong(rs, BlogDatabaseConstants.BlogTable.Column.BLOG_ID),
			RowMapperUtils.mapLong(rs, BlogDatabaseConstants.BlogPostTable.Column.POST_ID)
		);
		result.setPostTitle(RowMapperUtils.mapString(rs, BlogDatabaseConstants.BlogPostTable.Column.POST_TITLE));
		result.setPostText(RowMapperUtils.mapString(rs, BlogDatabaseConstants.BlogPostTable.Column.POST_TEXT));
		result.setPostDate(RowMapperUtils.mapDatetime(rs, BlogDatabaseConstants.BlogPostTable.Column.POST_DATE));
		result.setPosterUsername(RowMapperUtils.mapString(rs, BlogDatabaseConstants.BlogPostTable.Column.POSTER_USERNAME));
		result.setActive(RowMapperUtils.mapFlag(rs, BlogDatabaseConstants.BlogPostTable.Column.ACTIVE));
		result.setAllowComments(RowMapperUtils.mapFlag(rs, BlogDatabaseConstants.BlogPostTable.Column.ALLOW_COMMENTS));
		result.setLastUpdateDate(RowMapperUtils.mapDatetime(rs, BlogDatabaseConstants.BlogPostTable.Column.LAST_UPDATE_DATE));
		result.setLastUpdateUsername(RowMapperUtils.mapString(rs, BlogDatabaseConstants.BlogPostTable.Column.LAST_UPDATE_USERNAME));
		return result;
	}
	
}
