package ca.rileyman.common.general.dao;

import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests;
import org.testng.Assert;
import org.testng.annotations.Test;

@SuppressWarnings("javadoc")
@ContextConfiguration(value={"/riley-test-datasource-context.xml"})
public class CalendarDaoTest
extends AbstractTransactionalTestNGSpringContextTests
{
	
	@Autowired
	private CalendarDao calendarDao;
	
	@Test
	public void testGetCurrentDatetime() {
		Date now = calendarDao.getCurrentDatetime();
		Assert.assertNotNull(now);
		System.out.println(now);
	}
	
}
