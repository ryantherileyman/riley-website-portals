package ca.rileyman.common.test;

import java.io.BufferedReader;
import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testng.Assert;

/**
 * Provides utility methods for processing test data SQL files.
 */
public class SqlFileTestUtils
{
	
	private static final Logger log = LoggerFactory.getLogger(SqlFileTestUtils.class);
	
	/**
	 * Loads a test data SQL file from a resource.
	 * 
	 * @param relativeClass Class providing the relative path to the resource
	 * @param filename Resource filename
	 * @return List of SQL strings
	 */
	public static Collection<String> loadSqlStringListFromResource(Class<?> relativeClass, String filename) {
		log.debug("Entering for base class <{}>", relativeClass);
		log.debug("... and filename <{}>", filename);
		
		InputStream inputStream = relativeClass.getResourceAsStream(filename);
		InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
		BufferedReader reader = new BufferedReader(inputStreamReader);
		
		Collection<String> result = null;
		try {
			result = BufferedReaderToSqlBuilder.build(reader);
		} catch ( IOException e ) {
			Assert.fail("Could not read from resource");
		} finally {
			close(reader);
			close(inputStreamReader);
			close(inputStream);
		}
		
		log.debug("Exiting");
		return result;
	}
	
	private static class BufferedReaderToSqlBuilder
	{
		
		public static Collection<String> build(BufferedReader reader)
		throws IOException {
			BufferedReaderToSqlBuilder builder = new BufferedReaderToSqlBuilder(reader);
			builder.readAllLines();
			return( builder.getSqlStringList() );
		}
		
		private BufferedReader reader;
		private List<String> sqlStringList;
		private StringBuilder currSqlString;
		
		private BufferedReaderToSqlBuilder(BufferedReader reader) {
			this.reader = reader;
			this.sqlStringList = new ArrayList<String>();
			this.currSqlString = new StringBuilder();
		}
		
		private void readAllLines()
		throws IOException {
			String currLine;
			do {
				currLine = reader.readLine();
				if ( currLine != null ) {
					processLine(currLine);
				}
			} while ( currLine != null );
		}
		
		private void processLine(String line) {
			log.trace("Entering with line <{}>", line);
			
			String trimmedLine = line.trim();
			if ( trimmedLineContainsSql(trimmedLine) ) {
				if ( currSqlString.length() > 0 ) {
					currSqlString.append(' ');
				}
				currSqlString.append(trimmedLine);
				
				moveToNextSqlStringIfLineHasEnded();
			}
			
			log.trace("Exiting");
		}
		
		private boolean trimmedLineContainsSql(String trimmedLine) {
			boolean result;
			log.trace("Entering with trimmedLine <{}>", trimmedLine);
			
			result =
				( trimmedLine.length() > 0 ) &&
				( !trimmedLine.startsWith("--") );
			
			log.trace("Exiting with result <{}>", result);
			return result;
		}
		
		private void moveToNextSqlStringIfLineHasEnded() {
			log.trace("Entering");
			
			int lastCharPos = currSqlString.length() - 1;
			if ( currSqlString.charAt(lastCharPos) == ';' ) {
				currSqlString.deleteCharAt(lastCharPos);
				
				log.trace("Adding SQL string <{}>", currSqlString);
				sqlStringList.add(currSqlString.toString());
				
				currSqlString.delete(0, lastCharPos);
			}
			
			log.trace("Exiting");
		}
		
		private Collection<String> getSqlStringList() {
			return sqlStringList;
		}
		
	}
	
	private static void close(Closeable stream) {
		try {
			if ( stream != null ) {
				stream.close();
			}
		} catch ( IOException e ) {
			Assert.fail("Could not close stream");
		}
	}
	
	/**
	 * Executes the given SQL strings.  The SQL strings are typically all of the data manipulation variety.
	 * 
	 * @param jdbcTemplate JDBC template
	 * @param sqlStrings Collection of SQL strings
	 */
	public static void executeSqlStrings(JdbcTemplate jdbcTemplate, Iterable<String> sqlStrings) {
		for ( String currSqlString : sqlStrings ) {
			log.debug("Executing SQL string <{}>", currSqlString);
			jdbcTemplate.execute(currSqlString);
		}
	}
	
}
