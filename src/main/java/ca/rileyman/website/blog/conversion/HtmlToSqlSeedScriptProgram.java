package ca.rileyman.website.blog.conversion;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Main program used to convert blog post HTML code into SQL data seed scripts.
 */
public class HtmlToSqlSeedScriptProgram {
	
	private static final Logger log = LoggerFactory.getLogger(HtmlToSqlSeedScriptProgram.class);
	
	private static final String BLOG_FILE_PATH =
		"E:\\Riley\\DevData\\MavenProjects\\riley-website\\src\\main\\webapp\\nextblogpost.html";
	
	private static final String BLOG_POST_OPENING = "<article class=\"blog-entry\">";
	private static final String BLOG_POST_CLOSING = "</article>";
	
	private static final Pattern POST_TITLE_PATTERN =
		Pattern.compile("<h2>(.*)</h2>");
	
	private static final Pattern AUTHOR_LINE_PATTERN =
		Pattern.compile("<div class=\"author\">Posted by (.*) on (.*) at (.*)</div>");
	
	private static Collection<String> blogPostStrings;
	private static boolean insideBlogPost;
	private static int nextPostId = 37;
	
	@SuppressWarnings("javadoc")
	public static void main(String[] args) {
		blogPostStrings = new ArrayList<String>();
		insideBlogPost = false;
		
		processHtmlFile(BLOG_FILE_PATH);
	}
	
	private static void processHtmlFile(String path) {
		log.trace("Entering with <{}>", path);
		
		FileReader fileReader = openTextFile(path);
		BufferedReader bufferedReader = new BufferedReader(fileReader);
		
		System.out.println();
		
		String currLine;
		try {
			do {
				currLine = bufferedReader.readLine();
				if ( currLine != null ) {
					processLine(currLine);
				}
			} while ( currLine != null );
		} catch ( IOException e ) {
			System.out.println("Error trying to read file");
		} finally {
			try { bufferedReader.close(); } catch ( IOException e ) { }
			try { fileReader.close(); } catch ( IOException e ) { }
		}
		
		log.trace("Exiting");
	}
	
	private static void processLine(String line) {
		log.trace("Entering with \"{}\"", line);
		
		if ( !insideBlogPost ) {
			processLineOutsideBlogPost(line);
		} else {
			processLineInsideBlogPost(line);
		}
		
		log.trace("Exiting");
	}
	
	private static void processLineOutsideBlogPost(String line) {
		log.trace("Entering with \"{}\"", line);
		
		if ( BLOG_POST_OPENING.equals(line.trim()) ) {
			insideBlogPost = true;
			blogPostStrings.clear();
			
			log.trace("Cleared for new blog post");
		} else {
			log.trace("Line ignored");
		}
		
		log.trace("Exiting");
	}
	
	private static void processLineInsideBlogPost(String line) {
		log.trace("Entering with \"{}\"", line);
		
		if ( BLOG_POST_CLOSING.equals(line.trim()) ) {
			insideBlogPost = false;
			
			BlogPostStringsProcessor processor = new BlogPostStringsProcessor();
			System.out.println(processor.createInsertSql());
			System.out.println();
			nextPostId++;
		} else {
			blogPostStrings.add(line);
			
			log.trace("Added line to blogPostStrings");
		}
		
		log.trace("Exiting");
	}
	
	private static class BlogPostStringsProcessor
	{
		
		private String title;
		private String username;
		private String date;
		private String time;
		private Collection<String> postTextStrings = new ArrayList<String>();
		
		public String createInsertSql() {
			processBlogPostStrings();
			
			StringBuilder result = new StringBuilder();
			result.append("INSERT INTO r3_blog_post (\n");
			result.append("\tblog_id,\n");
			result.append("\tpost_id,\n");
			result.append("\tpost_title,\n");
			result.append("\tpost_text,\n");
			result.append("\tpost_date,\n");
			result.append("\tposter_username,\n");
			result.append("\tactive_flag,\n");
			result.append("\tallow_comments_flag,\n");
			result.append("\tlast_update_date,\n");
			result.append("\tlast_update_username\n");
			result.append(") VALUES (\n");
			result.append("\t( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),\n");
			result.append("\t" + nextPostId + ",\n");
			result.append("\t'" + escapeStringLiteral(title) + "',\n");
			result.append(createPostTextLiteral());
			result.append(createPostDateLiteral());
			result.append("\t'" + escapeStringLiteral(username) + "',\n");
			result.append("\t'Y',\n");
			result.append("\t'Y',\n");
			result.append(createPostDateLiteral());
			result.append("\t'" + escapeStringLiteral(username) + "'\n");
			result.append(");");
			return( result.toString() );
		}
		
		private void processBlogPostStrings() {
			log.trace("Entering");
			
			for ( String currLine : blogPostStrings ) {
				processBlogPostLine(currLine);
			}
			
			log.trace("Exiting");
		}
		
		private void processBlogPostLine(String line) {
			log.trace("Entering with line \"{}\"", line);
			
			Matcher postTitleMatcher = POST_TITLE_PATTERN.matcher(line.trim());
			Matcher authorLineMatcher = AUTHOR_LINE_PATTERN.matcher(line.trim());
			
			if ( postTitleMatcher.matches() ) {
				processPostTitle(postTitleMatcher);
			} else if ( authorLineMatcher.matches() ) {
				processAuthorLine(authorLineMatcher);
			} else {
				postTextStrings.add(line);
			}
			
			log.trace("Exiting");
		}
		
		private void processPostTitle(Matcher matcher) {
			log.trace("Entering with <{}>", matcher);
			
			if ( matcher.groupCount() > 0 ) {
				title = matcher.group(1);
			} else {
				log.info("No title found in header");
			}
			
			log.trace("title = <{}>", title);
			log.trace("Exiting");
		}
		
		private void processAuthorLine(Matcher matcher) {
			log.trace("Entering with <{}>", matcher);
			
			if ( matcher.groupCount() > 2 ) {
				username = matcher.group(1);
				date = matcher.group(2);
				time = matcher.group(3);
			} else {
				log.info("Author line has an invalid format");
			}
			
			log.trace("username = <{}>", username);
			log.trace("date = <{}>", date);
			log.trace("time = <{}>", time);
			log.trace("Exiting");
		}
		
		private String createPostTextLiteral() {
			StringBuilder result = new StringBuilder();
			result.append("\t(\n");
			for ( String currLine : postTextStrings ) {
				result.append("\t\t'" + escapeStringLiteral(currLine) + "\\n'\n");
			}
			result.append("\t),\n");
			return( result.toString() );
		}
		
		private String createPostDateLiteral() {
			String result = null;
			
			SimpleDateFormat inputFormatter = new SimpleDateFormat("MMM d, yyyy h:mma");
			try {
				Date dateValue = inputFormatter.parse(date + " " + time);
				
				SimpleDateFormat outputFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				result = "\t'" + outputFormatter.format(dateValue) + "',\n";
			} catch ( ParseException e ) {
				log.error("Error parsing post date", e);
			}
			
			return result;
		}
		
		private String escapeStringLiteral(String literal) {
			String result = literal
				.replace("\\", "\\\\")
				.replace("'", "\\'")
				;
			return result;
		}
		
	}
	
	private static FileReader openTextFile(String path) {
		FileReader result = null;
		try {
			result = new FileReader(path);
		} catch ( FileNotFoundException e ) {
			System.out.println("File not found");
		}
		return result;
	}
	
}
