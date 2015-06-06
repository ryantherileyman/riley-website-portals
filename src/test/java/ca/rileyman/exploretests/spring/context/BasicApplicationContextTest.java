package ca.rileyman.exploretests.spring.context;

import org.springframework.context.support.AbstractApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.testng.Assert;
import org.testng.annotations.Test;

@SuppressWarnings("javadoc")
public class BasicApplicationContextTest
{
	
	@Test
	public void testApplicationContextViaXml() {
		AbstractApplicationContext context = new ClassPathXmlApplicationContext("basic-test-context.xml", BasicApplicationContextTest.class);
		
		TestBean testBean = context.getBean("testBean", TestBean.class);
		Assert.assertEquals(testBean.getId(), new Long(1));
		Assert.assertEquals(testBean.getValue(), "Test");
		
		context.close();
	}
	
}
