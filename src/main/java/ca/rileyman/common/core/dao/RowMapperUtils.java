package ca.rileyman.common.core.dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

/**
 * Provides core utility methods for database row mappers.
 */
public final class RowMapperUtils
{
	
	/**
	 * Maps a database column value as a {@link Long}.
	 * 
	 * @param rs Result set
	 * @param columnName Database column name
	 * @return Long value
	 * @throws SQLException If a database access error occurs
	 */
	public static Long mapLong(ResultSet rs, String columnName)
	throws SQLException {
		Long result = rs.getLong(columnName);
		if ( rs.wasNull() ) {
			result = null;
		}
		return result;
	}
	
	/**
	 * Maps a database column value as a {@link String}.
	 * 
	 * @param rs Result set
	 * @param columnName Database column name
	 * @return String value
	 * @throws SQLException If a database access error occurs
	 */
	public static String mapString(ResultSet rs, String columnName)
	throws SQLException {
		String result = rs.getString(columnName);
		return result;
	}
	
	/**
	 * Maps a database column value as a {@link Date}, with both date and time components.
	 * 
	 * @param rs Result set
	 * @param columnName Database column name
	 * @return Date value, with both date and time components
	 * @throws SQLException If a database access error occurs
	 */
	public static Date mapDatetime(ResultSet rs, String columnName)
	throws SQLException {
		Date result = rs.getTimestamp(columnName);
		return result;
	}
	
	/**
	 * Maps a database CHAR(1) column value as a {@link Boolean}.
	 * 
	 * @param rs Result set
	 * @param columnName Database column name
	 * @return Boolean value
	 * @throws SQLException If a database access error occurs
	 */
	public static Boolean mapFlag(ResultSet rs, String columnName)
	throws SQLException {
		String flagValue = rs.getString(columnName);
		Boolean result = null;
		if ( flagValue != null ) {
			result = ( "Y".equals(flagValue) ? Boolean.TRUE : Boolean.FALSE );
		}
		return result;
	}
	
}
