package ca.rileyman.exploretests.mysql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import org.testng.Assert;
import org.testng.annotations.Test;

@SuppressWarnings("javadoc")
public class ExploreLegacyMySqlDriverTest
{
	
	@Test
	public void testDriverManagerConnection() {
		ensureMySqlDriverIsRegistered();
		
		Connection conn = null;
		try {
			conn = DriverManager.getConnection(
				"jdbc:mysql://localhost/test?" +
				"user=basictestuser&password=testpass"
			);
			LegacyMySqlTestUtils.runTestStatement(conn);
		} catch ( SQLException e ) {
			Assert.fail("Could not open Connection", e);
		} finally {
			if ( conn != null ) {
				LegacyMySqlTestUtils.closeConnection(conn);
			}
		}
	}
	
	private void ensureMySqlDriverIsRegistered() {
		try {
			Class.forName("com.mysql.jdbc.Driver").newInstance();
		} catch ( Exception e ) {
			Assert.fail("Could not register MySQL driver");
		}
	}
	
}
