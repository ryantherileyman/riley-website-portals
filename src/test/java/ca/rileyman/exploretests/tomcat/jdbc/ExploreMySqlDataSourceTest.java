package ca.rileyman.exploretests.tomcat.jdbc;

import java.sql.Connection;
import java.sql.SQLException;

import org.apache.tomcat.jdbc.pool.DataSource;
import org.apache.tomcat.jdbc.pool.PoolConfiguration;
import org.apache.tomcat.jdbc.pool.PoolProperties;
import org.testng.Assert;
import org.testng.annotations.Test;

import ca.rileyman.exploretests.mysql.LegacyMySqlTestUtils;

@SuppressWarnings("javadoc")
public class ExploreMySqlDataSourceTest
{
	
	@Test
	public void testDataSourceConnection() {
		javax.sql.DataSource dataSource = createDataSource();
		
		Connection conn = null;
		try {
			conn = dataSource.getConnection();
			LegacyMySqlTestUtils.runTestStatement(conn);
		} catch ( SQLException e ) {
			Assert.fail("Could not open Connection", e);
		} finally {
			if ( conn != null ) {
				LegacyMySqlTestUtils.closeConnection(conn);
			}
		}
	}
	
	private javax.sql.DataSource createDataSource() {
		DataSource result = new DataSource();
		result.setPoolProperties(createPoolConfiguration());
		return result;
	}
	
	private PoolConfiguration createPoolConfiguration() {
		PoolConfiguration result = new PoolProperties();
		
		result.setUrl("jdbc:mysql://localhost/test");
		result.setDriverClassName("com.mysql.jdbc.Driver");
		result.setUsername("basictestuser");
		result.setPassword("testpass");
		
		result.setTestOnBorrow(true);
		result.setValidationQuery("SELECT 1");
		
		result.setMaxIdle(5);
		result.setMaxActive(10);
		result.setMinIdle(1);
		
		return result;
	}
	
}
