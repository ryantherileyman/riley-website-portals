package ca.rileyman.exploretests.logging;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.annotations.Test;

@SuppressWarnings("javadoc")
public class Slf4jLoggerTest
{
	
	private static final Logger log = LoggerFactory.getLogger(Slf4jLoggerTest.class);
	
	@Test
	public void testLog() {
		log.debug("This is from log.debug");
		log.info("This is from log.info");
		log.error("This is from log.error");
	}
	
}
