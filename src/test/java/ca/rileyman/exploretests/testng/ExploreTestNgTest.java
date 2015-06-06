package ca.rileyman.exploretests.testng;

import org.testng.Assert;
import org.testng.annotations.Test;

@SuppressWarnings("javadoc")
public class ExploreTestNgTest
{
	
	@Test
	public void testAssert() {
		Assert.assertTrue(true, "Just checking");
		Assert.assertEquals(Long.parseLong("10"), 10L);
	}
	
}
