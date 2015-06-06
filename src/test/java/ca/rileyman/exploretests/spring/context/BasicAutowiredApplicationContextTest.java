package ca.rileyman.exploretests.spring.context;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.testng.AbstractTestNGSpringContextTests;
import org.testng.Assert;
import org.testng.annotations.Test;

@ContextConfiguration(value={"basic-test-context.xml"})
@SuppressWarnings("javadoc")
public class BasicAutowiredApplicationContextTest
extends AbstractTestNGSpringContextTests
{
	
	@Autowired
	private TestBean testBean;
	
	@Autowired
	private TestBean totallyDifferentName;
	
	@Test
	public void testAutowiredTestBean() {
		assertTestBeanValues(testBean);
	}
	
	@Test
	public void testAutowiredTotallyDifferentName() {
		assertTestBeanValues(totallyDifferentName);
	}
	
	private void assertTestBeanValues(TestBean testBean) {
		Assert.assertEquals(testBean.getId(), new Long(1));
		Assert.assertEquals(testBean.getValue(), "Test");
	}
	
	@Test
	public void ensureOnlyOneTestBeanExists() {
		Assert.assertTrue(testBean == totallyDifferentName);
	}
	
}
