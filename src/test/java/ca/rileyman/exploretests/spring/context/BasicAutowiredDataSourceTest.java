package ca.rileyman.exploretests.spring.context;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.testng.AbstractTestNGSpringContextTests;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.testng.Assert;
import org.testng.annotations.Test;

@ContextConfiguration(value={"/basic-test-datasource-context.xml"})
@SuppressWarnings("javadoc")
public class BasicAutowiredDataSourceTest
extends AbstractTestNGSpringContextTests
{
	
	@Autowired
	private TestTableDao testTableDao;
	
	@Test
	public void testLoadTestName() {
		String test_name = testTableDao.loadTestName(1);
		Assert.assertEquals(test_name, "Hello World");
	}
	
	@Test
	public void testInsertTestName() {
		testTableDao.insertTestName(2, "Just a Test");
	}
	
	@Test
	public void testDontDoIt() {
		try {
			testTableDao.dontDoIt();
			Assert.fail("Expected RuntimeException");
		} catch ( RuntimeException e ) {
		}
	}
	
	@Repository
	public static class TestTableDao
	{
		
		private static final Logger log = LoggerFactory.getLogger(TestTableDao.class);
		
		@Autowired
		private JdbcTemplate basicTestJdbcTemplate;
		
		@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)
		public String loadTestName(int testId) {
			log.debug("Entering with value <{}>", testId);
			
			String sql = "SELECT test_name FROM test_table WHERE test_id = ?";
			String result = basicTestJdbcTemplate.queryForObject(sql, String.class, testId);
			
			log.debug("Exiting with result <{}>", result);
			return result;
		}
		
		@Transactional(propagation=Propagation.REQUIRED, readOnly=false)
		public void insertTestName(int testId, String testName) {
			log.debug("Entering with testId = <{}>", testId);
			log.debug("and testName = <{}>", testName);
			
			basicTestJdbcTemplate.execute("INSERT INTO test_table VALUES (" + testId + ", '" + testName + "')");
			
			log.debug("Exiting");
		}
		
		@Transactional(propagation=Propagation.REQUIRED, readOnly=false)
		public void dontDoIt() {
			log.debug("Entering");
			
			basicTestJdbcTemplate.execute("DELETE FROM test_table");
			
			throw new RuntimeException();
		}
		
	}
	
}
