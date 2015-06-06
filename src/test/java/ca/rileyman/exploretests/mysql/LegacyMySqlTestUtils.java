package ca.rileyman.exploretests.mysql;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.testng.Assert;

@SuppressWarnings("javadoc")
public class LegacyMySqlTestUtils
{
	
	public static void runTestStatement(Connection conn) {
		Statement statement = null;
		
		try {
			statement = conn.createStatement();
			runTestQuery(statement);
		} catch ( SQLException e ) {
			Assert.fail("Could not create Statement", e);
		} finally {
			if ( statement != null ) {
				closeStatement(statement);
			}
		}
	}
	
	public static void runTestQuery(Statement statement) {
		ResultSet resultSet = null;
		
		try {
			resultSet = statement.executeQuery("SELECT test_name FROM test_table WHERE test_id = 1");
			assertExpectedResultSet(resultSet);
		} catch ( SQLException e ) {
			Assert.fail("Could not execute query", e);
		} finally {
			if ( resultSet != null ) {
				closeResultSet(resultSet);
			}
		}
	}
	
	public static void assertExpectedResultSet(ResultSet resultSet) {
		try {
			resultSet.next();
			Assert.assertEquals(resultSet.getString("test_name"), "Hello World");
		} catch ( SQLException e ) {
			Assert.fail("Could not retrieve test_name value", e);
		}
	}
	
	public static void closeResultSet(ResultSet resultSet) {
		try {
			resultSet.close();
		} catch ( SQLException e ) {
			Assert.fail("Could not close ResultSet", e);
		}
	}
	
	public static void closeStatement(Statement statement) {
		try {
			statement.close();
		} catch ( SQLException e ) {
			Assert.fail("Could not close Statement", e);
		}
	}
	
	public static void closeConnection(Connection conn) {
		try {
			conn.close();
		} catch ( SQLException e ) {
			Assert.fail("Could not close Connection", e);
		}
	}
	
}
