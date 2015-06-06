
INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	1,
	'Blogging About Blogging - Part 3 - HTML to Data Seed Conversion',
	(
		'<p>\n'
		'Not a lot to say, as this seemed to go smoothly so far.\n'
		'I\'ll need to see if any adjustments need to be made once this is actually being served by an AJAX response, but the source code below is what I plan to use as the one-off program for this conversion.\n'
		'When it\'s time to go live, I\'ll just run this and copy-paste the results from the Console into a script that I can run from the MySQL control panel.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.website.blog.conversion;\n'
		'\n'
		'import java.io.BufferedReader;\n'
		'import java.io.FileNotFoundException;\n'
		'import java.io.FileReader;\n'
		'import java.io.IOException;\n'
		'import java.text.ParseException;\n'
		'import java.text.SimpleDateFormat;\n'
		'import java.util.ArrayList;\n'
		'import java.util.Collection;\n'
		'import java.util.Date;\n'
		'import java.util.regex.Matcher;\n'
		'import java.util.regex.Pattern;\n'
		'\n'
		'import org.slf4j.Logger;\n'
		'import org.slf4j.LoggerFactory;\n'
		'\n'
		'/**\n'
		'* Main program used to convert blog post HTML code into SQL data seed scripts.\n'
		'*/\n'
		'public class HtmlToSqlSeedScriptProgram {\n'
		'\n'
		'private static final Logger log = LoggerFactory.getLogger(HtmlToSqlSeedScriptProgram.class);\n'
		'\n'
		'private static final String BLOG_FILE_PATH =\n'
		'"... path hidden ...";\n'
		'\n'
		'private static final String BLOG_POST_OPENING = "&lt;article class=\"blog-entry\"&gt;";\n'
		'private static final String BLOG_POST_CLOSING = "&lt;/article&gt;";\n'
		'\n'
		'private static final Pattern POST_TITLE_PATTERN =\n'
		'Pattern.compile("&lt;h1&gt;(.*)&lt;/h1&gt;");\n'
		'\n'
		'private static final Pattern AUTHOR_LINE_PATTERN =\n'
		'Pattern.compile("&lt;div class=\"author\"&gt;Posted by (.*) on (.*) at (.*)&lt;/div&gt;");\n'
		'\n'
		'private static Collection<String> blogPostStrings;\n'
		'private static boolean insideBlogPost;\n'
		'private static int nextPostId = 1;\n'
		'\n'
		'@SuppressWarnings("javadoc")\n'
		'public static void main(String[] args) {\n'
		'blogPostStrings = new ArrayList<String>();\n'
		'insideBlogPost = false;\n'
		'\n'
		'processHtmlFile(BLOG_FILE_PATH);\n'
		'}\n'
		'\n'
		'private static void processHtmlFile(String path) {\n'
		'log.trace("Entering with <{}>", path);\n'
		'\n'
		'FileReader fileReader = openTextFile(path);\n'
		'BufferedReader bufferedReader = new BufferedReader(fileReader);\n'
		'\n'
		'System.out.println();\n'
		'\n'
		'String currLine;\n'
		'try {\n'
		'do {\n'
		'currLine = bufferedReader.readLine();\n'
		'if ( currLine != null ) {\n'
		'processLine(currLine);\n'
		'}\n'
		'} while ( currLine != null );\n'
		'} catch ( IOException e ) {\n'
		'System.out.println("Error trying to read file");\n'
		'} finally {\n'
		'try { bufferedReader.close(); } catch ( IOException e ) { }\n'
		'try { fileReader.close(); } catch ( IOException e ) { }\n'
		'}\n'
		'\n'
		'log.trace("Exiting");\n'
		'}\n'
		'\n'
		'private static void processLine(String line) {\n'
		'log.trace("Entering with \"{}\"", line);\n'
		'\n'
		'String trimmedLine = line.trim();\n'
		'if ( !insideBlogPost ) {\n'
		'processTrimmedLineOutsideBlogPost(trimmedLine);\n'
		'} else {\n'
		'processTrimmedLineInsideBlogPost(trimmedLine);\n'
		'}\n'
		'\n'
		'log.trace("Exiting");\n'
		'}\n'
		'\n'
		'private static void processTrimmedLineOutsideBlogPost(String trimmedLine) {\n'
		'log.trace("Entering with \"{}\"", trimmedLine);\n'
		'\n'
		'if ( BLOG_POST_OPENING.equals(trimmedLine) ) {\n'
		'insideBlogPost = true;\n'
		'blogPostStrings.clear();\n'
		'\n'
		'log.trace("Cleared for new blog post");\n'
		'} else {\n'
		'log.trace("Line ignored");\n'
		'}\n'
		'\n'
		'log.trace("Exiting");\n'
		'}\n'
		'\n'
		'private static void processTrimmedLineInsideBlogPost(String trimmedLine) {\n'
		'log.trace("Entering with \"{}\"", trimmedLine);\n'
		'\n'
		'if ( BLOG_POST_CLOSING.equals(trimmedLine) ) {\n'
		'insideBlogPost = false;\n'
		'\n'
		'BlogPostStringsProcessor processor = new BlogPostStringsProcessor();\n'
		'System.out.println(processor.createInsertSql());\n'
		'System.out.println();\n'
		'nextPostId++;\n'
		'} else {\n'
		'blogPostStrings.add(trimmedLine);\n'
		'\n'
		'log.trace("Added line to blogPostStrings");\n'
		'}\n'
		'\n'
		'log.trace("Exiting");\n'
		'}\n'
		'\n'
		'private static class BlogPostStringsProcessor\n'
		'{\n'
		'\n'
		'private String title;\n'
		'private String username;\n'
		'private String date;\n'
		'private String time;\n'
		'private Collection<String> postTextStrings = new ArrayList<String>();\n'
		'\n'
		'public String createInsertSql() {\n'
		'processBlogPostStrings();\n'
		'\n'
		'StringBuilder result = new StringBuilder();\n'
		'result.append("INSERT INTO r3_blog_post (\n");\n'
		'result.append("\tblog_id,\n");\n'
		'result.append("\tpost_id,\n");\n'
		'result.append("\tpost_title,\n");\n'
		'result.append("\tpost_text,\n");\n'
		'result.append("\tpost_date,\n");\n'
		'result.append("\tposter_username,\n");\n'
		'result.append("\tactive_flag,\n");\n'
		'result.append("\tallow_comments_flag,\n");\n'
		'result.append("\tlast_update_date,\n");\n'
		'result.append("\tlast_update_username\n");\n'
		'result.append(") VALUES (\n");\n'
		'result.append("\t( SELECT blog_id FROM r3_blog WHERE blog_code = \'RILEY_WEBSITE\' ),\n");\n'
		'result.append("\t" + nextPostId + ",\n");\n'
		'result.append("\t\'" + escapeStringLiteral(title) + "\',\n");\n'
		'result.append(createPostTextLiteral());\n'
		'result.append(createPostDateLiteral());\n'
		'result.append("\t\'" + escapeStringLiteral(username) + "\',\n");\n'
		'result.append("\t\'Y\',\n");\n'
		'result.append("\t\'Y\',\n");\n'
		'result.append(createPostDateLiteral());\n'
		'result.append("\t\'" + escapeStringLiteral(username) + "\'\n");\n'
		'result.append(");");\n'
		'return( result.toString() );\n'
		'}\n'
		'\n'
		'private void processBlogPostStrings() {\n'
		'log.trace("Entering");\n'
		'\n'
		'for ( String currLine : blogPostStrings ) {\n'
		'processBlogPostLine(currLine);\n'
		'}\n'
		'\n'
		'log.trace("Exiting");\n'
		'}\n'
		'\n'
		'private void processBlogPostLine(String line) {\n'
		'log.trace("Entering with line \"{}\"", line);\n'
		'\n'
		'Matcher postTitleMatcher = POST_TITLE_PATTERN.matcher(line);\n'
		'Matcher authorLineMatcher = AUTHOR_LINE_PATTERN.matcher(line);\n'
		'\n'
		'if ( postTitleMatcher.matches() ) {\n'
		'processPostTitle(postTitleMatcher);\n'
		'} else if ( authorLineMatcher.matches() ) {\n'
		'processAuthorLine(authorLineMatcher);\n'
		'} else {\n'
		'postTextStrings.add(line);\n'
		'}\n'
		'\n'
		'log.trace("Exiting");\n'
		'}\n'
		'\n'
		'private void processPostTitle(Matcher matcher) {\n'
		'log.trace("Entering with <{}>", matcher);\n'
		'\n'
		'if ( matcher.groupCount() > 0 ) {\n'
		'title = matcher.group(1);\n'
		'} else {\n'
		'log.info("No title found in header");\n'
		'}\n'
		'\n'
		'log.trace("title = <{}>", title);\n'
		'log.trace("Exiting");\n'
		'}\n'
		'\n'
		'private void processAuthorLine(Matcher matcher) {\n'
		'log.trace("Entering with <{}>", matcher);\n'
		'\n'
		'if ( matcher.groupCount() > 2 ) {\n'
		'username = matcher.group(1);\n'
		'date = matcher.group(2);\n'
		'time = matcher.group(3);\n'
		'} else {\n'
		'log.info("Author line has an invalid format");\n'
		'}\n'
		'\n'
		'log.trace("username = <{}>", username);\n'
		'log.trace("date = <{}>", date);\n'
		'log.trace("time = <{}>", time);\n'
		'log.trace("Exiting");\n'
		'}\n'
		'\n'
		'private String createPostTextLiteral() {\n'
		'StringBuilder result = new StringBuilder();\n'
		'result.append("\t(\n");\n'
		'for ( String currLine : postTextStrings ) {\n'
		'result.append("\t\t\'" + escapeStringLiteral(currLine) + "\\n\'\n");\n'
		'}\n'
		'result.append("\t),\n");\n'
		'return( result.toString() );\n'
		'}\n'
		'\n'
		'private String createPostDateLiteral() {\n'
		'String result = null;\n'
		'\n'
		'SimpleDateFormat inputFormatter = new SimpleDateFormat("MMM d, yyyy KK:mm");\n'
		'try {\n'
		'Date dateValue = inputFormatter.parse(date + " " + time);\n'
		'\n'
		'SimpleDateFormat outputFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");\n'
		'result = "\t\'" + outputFormatter.format(dateValue) + "\',\n";\n'
		'} catch ( ParseException e ) {\n'
		'log.error("Error parsing post date", e);\n'
		'}\n'
		'\n'
		'return result;\n'
		'}\n'
		'\n'
		'private String escapeStringLiteral(String literal) {\n'
		'String result = literal.replace("\'", "\\\'");\n'
		'return result;\n'
		'}\n'
		'\n'
		'}\n'
		'\n'
		'private static FileReader openTextFile(String path) {\n'
		'FileReader result = null;\n'
		'try {\n'
		'result = new FileReader(path);\n'
		'} catch ( FileNotFoundException e ) {\n'
		'System.out.println("File not found");\n'
		'}\n'
		'return result;\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'I just felt like pointing out that the program I\'ll be using to convert these blog posts into the database will now be stored as part of a blog post in the database!\n'
		'This is sort of a... surreal experience.\n'
		'</p>\n'
	),
	'2015-04-15 21:30:00',
	'Riley',
	'Y',
	'Y',
	'2015-04-15 21:30:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	2,
	'Blogging About Blogging - Part 2 - Initial Domain and Data Access',
	(
		'<p>\n'
		'The first iteration for the domain and data access is in place.\n'
		'I updated the <a href="https://docs.google.com/document/d/1396uYGJxM-XWtuW3G8a1M0HhKHJ6uqRazm4JAzpgsxo/pub">published Google Doc</a> detailing the requirements with one small change to the Dao interface.\n'
		'The two Dao methods now include "Active" in their name, to better reflect what they\'re actually doing.\n'
		'</p>\n'
		'<p style="text-align: center;">\n'
		'<figure>\n'
		'<img src="static/images/blog/20150412_initial_blog_dao.png" alt="Initial Blog Domain and Data Access" usemap="#map_20150412_initial_blog_dao"></img>\n'
		'<figcaption>Click on a file to see the source code</figcaption>\n'
		'</figure>\n'
		'</p>\n'
		'<map name="map_20150412_initial_blog_dao">\n'
		'<area shape="rect" coords="60,73,284,90" href="static/src/main/java/ca/rileyman/common/core/dao/RowMapperUtils.java.txt" title="RowMapperUtils.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="60,109,284,126" href="static/src/main/java/ca/rileyman/website/blog/dao/BlogPostDao.java.txt" title="BlogPostDao.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="60,145,284,162" href="static/src/main/java/ca/rileyman/website/blog/dao/db/BlogDatabaseConstants.java.txt" title="BlogDatabaseConstants.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="60,163,284,180" href="static/src/main/java/ca/rileyman/website/blog/dao/db/BlogPostCommentRowMapper.java.txt" title="BlogPostCommentRowMapper.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="60,181,284,198" href="static/src/main/java/ca/rileyman/website/blog/dao/db/BlogPostRowMapper.java.txt" title="BlogPostRowMapper.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="60,217,284,234" href="static/src/main/java/ca/rileyman/website/blog/dao/jdbc/BlogPostDaoImpl.java.txt" title="BlogPostDaoImpl.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="60,253,284,270" href="static/src/main/java/ca/rileyman/website/blog/model/BlogPost.java.txt" title="BlogPost.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="60,271,284,288" href="static/src/main/java/ca/rileyman/website/blog/model/BlogPostComment.java.txt" title="BlogPostComment.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="60,307,284,324" href="static/src/main/java/ca/rileyman/website/blog/search/BlogPostNavSearch.java.txt" title="BlogPostNavSearch.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="386,73,600,90" href="static/src/test/java/ca/rileyman/common/test/SqlFileTestUtils.java.txt" title="SqlFileTestUtils.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="386,108,600,125" href="static/src/test/java/ca/rileyman/website/blog/dao/BlogPostDaoTest.java.txt" title="BlogPostDaoTest.java" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="386,166,600,183" href="static/src/test/resources/ca/rileyman/website/blog/dao/BlogPostDaoTestData.sql.txt" title="BlogPostDaoTestData.sql" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="443,314,632,331" href="static/src/database/impl/2015/blog_initial/create_blog_foreign_keys.sql.txt" title="create_blog_foreign_keys.sql" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="443,332,632,349" href="static/src/database/impl/2015/blog_initial/create_blog_tables.sql.txt" title="create_blog_tables.sql" target="iframe_20150412_initial_blog_dao"></area>\n'
		'<area shape="rect" coords="443,350,632,367" href="static/src/database/impl/2015/blog_initial/drop_blog_tables.sql.txt" title="drop_blog_tables.sql" target="iframe_20150412_initial_blog_dao"></area>\n'
		'</map>\n'
		'<p style="text-align: center;">\n'
		'<iframe name="iframe_20150412_initial_blog_dao" width="95%" height="360" src="static/src/test/java/ca/rileyman/website/blog/dao/BlogPostDaoTest.java.txt"></iframe>\n'
		'</p>\n'
		'<p>\n'
		'When developing this, I followed the principles of test driven development.\n'
		'Class <a href="static/src/main/java/ca/rileyman/website/blog/dao/jdbc/BlogPostDaoImpl.java.txt" target="iframe_20150412_initial_blog_dao">BlogPostDaoImpl</a> began with stub methods, and I wrote BlogPostDaoTest first.\n'
		'I then filled in the implementation, with classes\n'
		'<a href="static/src/main/java/ca/rileyman/common/core/dao/RowMapperUtils.java.txt" target="iframe_20150412_initial_blog_dao">RowMapperUtils</a>,\n'
		'<a href="static/src/main/java/ca/rileyman/website/blog/dao/db/BlogDatabaseConstants.java.txt" target="iframe_20150412_initial_blog_dao">BlogDatabaseConstants</a>,\n'
		'<a href="static/src/main/java/ca/rileyman/website/blog/dao/db/BlogPostRowMapper.java.txt" target="iframe_20150412_initial_blog_dao">BlogPostRowMapper</a>,\n'
		'and <a href="static/src/main/java/ca/rileyman/website/blog/dao/db/BlogPostCommentRowMapper.java.txt" target="iframe_20150412_initial_blog_dao">BlogPostCommentRowMapper</a>\n'
		'all written last.\n'
		'Development of these classes continued in a cycle until all tests passed.\n'
		'</p>\n'
		'<p>\n'
		'A few notes about the overall architectural choices:\n'
		'<ul>\n'
		'<li>\n'
		'In general, my choice is to go with packages named ca.rileyman.&lt;project&gt;.&lt;business-area&gt;.&lt;tier&gt;, with sub-packages as appropriate.\n'
		'The "common" project area reflects classes I would re-use in other projects.\n'
		'The "dao" tier is for data access objects.\n'
		'The "model" tier is for the domain model.\n'
		'The "search" tier can be used by data access or services (coming later).\n'
		'I find this package structure keeps things organized in a way that makes classes easy-to-find, as long as you define each business area with a targeted enough approach.\n'
		'</li>\n'
		'<li>\n'
		'On my local computer, I added the MySQL bin directory to the "Path" environment variable.\n'
		'This lets me open a Windows command prompt, navigate to the folder containing the SQL scripts, run "mysql", and issue commands like "source create_blog_tables.sql".\n'
		'The "drop_blog_tables.sql" script is there in case I want to start over again.\n'
		'I tend to prefer keeping foreign keys in a separate script.\n'
		'</li>\n'
		'<li>\n'
		'Note that <a href="static/src/test/java/ca/rileyman/website/blog/dao/BlogPostDaoTest.java.txt" target="iframe_20150412_initial_blog_dao">BlogPostDaoTest</a> extends a Spring class named AbstractTransactionalTestNGSpringContextTests.\n'
		'In addition to providing the boot-strapping for creating an application context, this also wraps each test in its own transaction.\n'
		'This is what allows each of my tests to insert a bunch of test records, without permanently keeping that data in the database.\n'
		'</li>\n'
		'<li>\n'
		'I chose to go with inserting test data via an SQL script file, rather than incorporating something like <a href="http://dbunit.sourceforge.net/">DBUnit</a> into my project.\n'
		'DBUnit has the advantage of inserting test data in a database independent fashion, but in my experience this does come at a performance cost.\n'
		'On a personal level I also find the XML-based test data setup to be a pain.\n'
		'For my purposes, having to write <a href="static/src/test/java/ca/rileyman/common/test/SqlFileTestUtils.java.txt" target="iframe_20150412_initial_blog_dao">SqlFileTestUtils</a> took less than an hour, which is likely the same amount of time I would\'ve spent remembering how to get DBUnit working.\n'
		'I also like being able to have raw SQL scripts that I can run directly into the MySQL command prompt window.\n'
		'</li>\n'
		'</ul>\n'
		'</p>\n'
		'<p>\n'
		'I encountered two issues along the way.\n'
		'</p>\n'
		'<p>\n'
		'My datasource context XML file initially had component scanning set to base package ca.rileyman.\n'
		'I chose not to include a JdbcTemplate bean, instead deciding to create a new JdbcTemplate object for each Dao.\n'
		'This caused a BeanCreationException in Spring when building the application context, because it was trying to autowire in the JdbcTemplate from the BasicAutowiredDataSourceTest (see my blog post from March 30th).\n'
		'I had to change the base package for component scanning to ca.rileyman.website instead.\n'
		'</p>\n'
		'<p>\n'
		'I got a MySQLSyntaxErrorException (This version of MySQL doesn\'t yet support \'LIMIT & IN/ALL/ANY/SOME subquery\') on my first attempt to load comments.\n'
		'I was trying to do something a little bit fancy in the original SQL statement.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>SELECT\n'
		'blog_id,\n'
		'post_id,\n'
		'comment_id,\n'
		'comment_text,\n'
		'comment_date,\n'
		'commenter_username,\n'
		'active_flag\n'
		'FROM r3_blog_post_comment\n'
		'WHERE\n'
		'blog_id = ( SELECT blog_id FROM r3_blog WHERE blog_code = ? ) AND\n'
		'post_id IN (\n'
		'SELECT post_id\n'
		'FROM r3_blog_post\n'
		'WHERE\n'
		'blog_id = ( SELECT blog_id FROM r3_blog WHERE blog_code = ? )\n'
		'ORDER BY\n'
		'post_date DESC\n'
		'LIMIT ?, ?\n'
		') AND\n'
		'active_flag = \'Y\'\n'
		'ORDER BY comment_date DESC</pre>\n'
		'</div>\n'
		'<p>\n'
		'The above query just isn\'t supported yet in MySQL.\n'
		'So I removed the "post_id IN" portion of the WHERE clause.\n'
		'The drawback is that the query will return all active comments for the blog - including those attached to inactive blog posts, or attached to blog posts not within the desired navigation range.\n'
		'The Dao implementation needed to handle that in the attachCommentToBlogPost and findBlogPost methods.\n'
		'</p>\n'
		'<p>\n'
		'My next post on this topic will be super-exciting, just like this one! :D\n'
		'I need to get all these existing blog posts into the database, so the next post will cover peeling out the HTML found here into an SQL script.\n'
		'</p>\n'
	),
	'2015-04-12 15:00:00',
	'Riley',
	'Y',
	'Y',
	'2015-04-12 15:00:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	3,
	'Blogging About Blogging - Part 1 - Initial Requirements',
	(
		'<p>\n'
		'So here we go, blogging about building custom blog software for my blog page.\n'
		'I\'m fairly certain this will cause a rift in the space-time continuum, but I will boldly go where... uh, probably other people have gone before.\n'
		'</p>\n'
		'<p>\n'
		'I have the full requirements documentation for my initial pass available as a <a href="https://docs.google.com/document/d/1396uYGJxM-XWtuW3G8a1M0HhKHJ6uqRazm4JAzpgsxo/pub">published Google Doc</a>.\n'
		'It\'s all very dry, so here\'s the summary of how the first iteration will work:\n'
		'<ul>\n'
		'<li>Each blog post is made up of a title, text, timestamp, and poster - as you see already.</li>\n'
		'<li>By default, this page will load the 20 most recent posts.  You\'ll be able to gather more of them, in clumps of 20 until they\'re all displayed.</li>\n'
		'<li>You\'ll be able to post comments.</li>\n'
		'</ul>\n'
		'</p>\n'
		'<p>\n'
		'My next post on this topic will provide full source code for the database implementation, domain model, data access, and automated tests.\n'
		'I\'ll be using <a href="http://www.mysql.com/">MySQL</a>, <a href="https://www.oracle.com/java/index.html">Java</a>, and the <a href="http://projects.spring.io/spring-framework/">Spring Framework</a>.\n'
		'</p>\n'
	),
	'2015-04-11 11:05:00',
	'Riley',
	'Y',
	'Y',
	'2015-04-11 11:05:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	4,
	'Restoring My Animated Films - To TMO or Not To TMO',
	(
		'<p>\n'
		'<a href="https://www.youtube.com/watch?v=d04cA0fLbE0">To TMO or Not To TMO</a> was originally produced towards the end of 2007.\n'
		'Steeped in the lore of <a href="http://www.lionhead.com/games/the-movies/">The Movies</a>, follow TMOMovieMaker (voiced by TheMonk) as he attempts to create his first The Movies film.\n'
		'Assisted - and occasionally harrassed - by the narrator (voice by myself), will he complete his film and gain fame, or go completely crazy trying?!\n'
		'</p>\n'
		'<p>\n'
		'Head on over to the <a href="https://www.youtube.com/channel/UCHvoItS_0Nmueb0IuZoLSKg">Riley Entertainment Youtube Channel</a> to check it out!\n'
		'</p>\n'
		'<p>\n'
		'The <a href="static/to-tmo/index.html">To TMO or Not To TMO companion website</a> is also up!\n'
		'It contains complete information about the film - the cast, soundtrack, some screenshots, and a handful of how-to guides for the aspiring The Movies filmmaker!\n'
		'</p>\n'
		'<p style="text-align: center;">\n'
		'<img src="static/to-tmo/2tmo-title.jpg"></img>\n'
		'</p>\n'
	),
	'2015-04-04 12:30:00',
	'Riley',
	'Y',
	'Y',
	'2015-04-04 12:30:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	5,
	'To TMO or Not to TMO - Coming Tomorrow',
	(
		'<p>\n'
		'The second film I produced during my time with <a href="http://www.lionhead.com/games/the-movies/">The Movies</a> was <b>To TMO or Not to TMO</b>.\n'
		'This film acts as a fun tour of the experience users had creating films with The Movies.\n'
		'It was also something of a celebration of problem-solving - and oh, there was plenty of that with the game!\n'
		'Unlike the two I posted prior to this, <b>To TMO or Not to TMO</b> contains additional voice work from other members of The Movies community.\n'
		'Thanks as always to them for lending their voices to this project!\n'
		'</p>\n'
	),
	'2015-04-03 21:55:00',
	'Riley',
	'Y',
	'Y',
	'2015-04-03 21:55:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	6,
	'Exploring the Spring Framework - Episode 3 - Autowiring for Data Access',
	(
		'<p>\n'
		'Way back on March 9th and 10th, I posted what I referred to as a "legacy" database access test.\n'
		'Last week, I posted about the <a href="http://projects.spring.io/spring-framework/">Spring Framework</a>\'s application context and auto-wiring of objects.\n'
		'Today, I\'ll bring those two together to illustrate some of the advantages of "inversion of control" using Spring.\n'
		'</p>\n'
		'<p>\n'
		'Since I\'ll be using Spring\'s JDBC library, I first add yet another dependency for Maven:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;dependency&gt;</div>\n'
		'<div class="tab-1">&lt;groupId&gt;org.springframework&lt;/groupId&gt;</div>\n'
		'<div class="tab-1">&lt;artifactId&gt;spring-jdbc&lt;/artifactId&gt;</div>\n'
		'<div class="tab-1">&lt;version&gt;4.1.5.RELEASE&lt;/version&gt;</div>\n'
		'<div class="tab-0">&lt;/dependency&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'Then I create a new application context XML file that will only be used for this particular test:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>&lt;?xml version="1.0" encoding="UTF-8"?&gt;\n'
		'&lt;beans\n'
		'xmlns="http://www.springframework.org/schema/beans"\n'
		'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n'
		'xmlns:context="http://www.springframework.org/schema/context"\n'
		'xmlns:tx="http://www.springframework.org/schema/tx"\n'
		'xsi:schemaLocation="\n'
		'http://www.springframework.org/schema/beans\n'
		'http://www.springframework.org/schema/beans/spring-beans.xsd\n'
		'http://www.springframework.org/schema/context\n'
		'http://www.springframework.org/schema/context/spring-context.xsd\n'
		'http://www.springframework.org/schema/tx\n'
		'http://www.springframework.org/schema/tx/spring-tx.xsd\n'
		'"\n'
		'&gt;\n'
		'\n'
		'&lt;context:component-scan base-package="ca.rileyman" /&gt;\n'
		'\n'
		'&lt;bean id="basicTestDataSource" class="org.apache.tomcat.jdbc.pool.DataSource"&gt;\n'
		'&lt;property name="url" value="jdbc:mysql://localhost/test" /&gt;\n'
		'&lt;property name="driverClassName" value="com.mysql.jdbc.Driver" /&gt;\n'
		'&lt;property name="username" value="basictestuser" /&gt;\n'
		'&lt;property name="password" value="testpass" /&gt;\n'
		'&lt;property name="testOnBorrow" value="true" /&gt;\n'
		'&lt;property name="validationQuery" value="SELECT 1" /&gt;\n'
		'&lt;property name="maxIdle" value="5" /&gt;\n'
		'&lt;property name="maxActive" value="10" /&gt;\n'
		'&lt;property name="minIdle" value="1" /&gt;\n'
		'&lt;/bean&gt;\n'
		'\n'
		'&lt;bean id="basicTestTransactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager"&gt;\n'
		'&lt;property name="dataSource" ref="basicTestDataSource" /&gt;\n'
		'&lt;/bean&gt;\n'
		'\n'
		'&lt;tx:annotation-driven transaction-manager="basicTestTransactionManager" /&gt;\n'
		'\n'
		'&lt;bean id="basicTestJdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate"&gt;\n'
		'&lt;property name="dataSource" ref="basicTestDataSource" /&gt;\n'
		'&lt;/bean&gt;\n'
		'\n'
		'&lt;/beans&gt;</pre>\n'
		'</div>\n'
		'<p>\n'
		'I actually don\'t care for all the necessary meta-information you need to give this file related to namespaces and schema locations.\n'
		'On the positive side of this, the goal is for the above to be the full extent of XML configuration needed for an entire application.\n'
		'There are a number of things to note about the content of this XML file:\n'
		'<ul>\n'
		'<li>\n'
		'The context:component-scan tag is how we\'re going to tell Spring that it should look for annotated classes to automatically add to the application context.\n'
		'You have to give it the base package, so that it has a starting point to look for classes -- which it will do using reflection.\n'
		'</li>\n'
		'<li>\n'
		'The basicTestDataSource is defined explicitly here, using the Tomcat JDBC pool.\n'
		'Within the web application, I plan on defining this as a JNDI data source.\n'
		'Since the test environment doesn\'t have access to the servlet container, it does need to be explicitly defined for automated tests.\n'
		'</li>\n'
		'<li>\n'
		'Spring provides a standard transaction manager that I intend to use.\n'
		'It\'s perfect for a single-database environment.\n'
		'</li>\n'
		'<li>\n'
		'The tx:annotation-driven tag is how we\'re going to tell Spring to look for transaction annotations.\n'
		'These annotations are placed on individual methods (or on an entire class, which operates as a default for all methods on that class), and provide information about how to behave as it relates to database transactions.\n'
		'When Spring encounters these annotations, it actually creates a sub-class of your class.\n'
		'The code it "injects" at the beginning of the method will either begin a new transaction, or join an existing one.\n'
		'The code it "injects" at the end of the method will either commit (if your method succeeds) or rollback (if your method throws a RuntimeException, or any checked exception that you declare) the transaction; and if this was the outer-most transactional call on the stack, it will release the connection.\n'
		'</li>\n'
		'</ul>\n'
		'</p>\n'
		'<p>\n'
		'I wanted to do more than the original test from March 9th.\n'
		'I also wanted to test out executing a database transaction.\n'
		'Here\'s what the test code looks like:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.spring.context;\n'
		'\n'
		'import org.slf4j.Logger;\n'
		'import org.slf4j.LoggerFactory;\n'
		'import org.springframework.beans.factory.annotation.Autowired;\n'
		'import org.springframework.jdbc.core.JdbcTemplate;\n'
		'import org.springframework.stereotype.Repository;\n'
		'import org.springframework.test.context.ContextConfiguration;\n'
		'import org.springframework.test.context.testng.AbstractTestNGSpringContextTests;\n'
		'import org.springframework.transaction.annotation.Propagation;\n'
		'import org.springframework.transaction.annotation.Transactional;\n'
		'import org.testng.Assert;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'@ContextConfiguration(value={"/basic-test-datasource-context.xml"})\n'
		'@SuppressWarnings("javadoc")\n'
		'public class BasicAutowiredDataSourceTest\n'
		'extends AbstractTestNGSpringContextTests\n'
		'{\n'
		'\n'
		'@Autowired\n'
		'private TestTableDao testTableDao;\n'
		'\n'
		'@Test\n'
		'public void testLoadTestName() {\n'
		'String test_name = testTableDao.loadTestName(1);\n'
		'Assert.assertEquals(test_name, "Hello World");\n'
		'}\n'
		'\n'
		'@Test\n'
		'public void testInsertTestName() {\n'
		'testTableDao.insertTestName(2, "Just a Test");\n'
		'}\n'
		'\n'
		'@Test\n'
		'public void testDontDoIt() {\n'
		'try {\n'
		'testTableDao.dontDoIt();\n'
		'Assert.fail("Expected RuntimeException");\n'
		'} catch ( RuntimeException e ) {\n'
		'}\n'
		'}\n'
		'\n'
		'@Repository\n'
		'public static class TestTableDao\n'
		'{\n'
		'\n'
		'private static final Logger log = LoggerFactory.getLogger(TestTableDao.class);\n'
		'\n'
		'@Autowired\n'
		'private JdbcTemplate basicTestJdbcTemplate;\n'
		'\n'
		'@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)\n'
		'public String loadTestName(int testId) {\n'
		'log.debug("Entering with value <{}>", testId);\n'
		'\n'
		'String sql = "SELECT test_name FROM test_table WHERE test_id = ?";\n'
		'String result = basicTestJdbcTemplate.queryForObject(sql, String.class, testId);\n'
		'\n'
		'log.debug("Exiting with result <{}>", result);\n'
		'return result;\n'
		'}\n'
		'\n'
		'@Transactional(propagation=Propagation.REQUIRED, readOnly=false)\n'
		'public void insertTestName(int testId, String testName) {\n'
		'log.debug("Entering with testId = <{}>", testId);\n'
		'log.debug("and testName = <{}>", testName);\n'
		'\n'
		'basicTestJdbcTemplate.execute("INSERT INTO test_table VALUES (" + testId + ", \'" + testName + "\')");\n'
		'\n'
		'log.debug("Exiting");\n'
		'}\n'
		'\n'
		'@Transactional(propagation=Propagation.REQUIRED, readOnly=false)\n'
		'public void dontDoIt() {\n'
		'log.debug("Entering");\n'
		'\n'
		'basicTestJdbcTemplate.execute("DELETE FROM test_table");\n'
		'\n'
		'throw new RuntimeException();\n'
		'}\n'
		'\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'First, a few things to note about this:\n'
		'<ul>\n'
		'<li>\n'
		'Notice that I\'ve placed the actual data access calls in an inner-class named TestTableDao.\n'
		'It\'s only an inner class for sake of convenience -- real Dao classes will typically implement an interface, and be their own class.\n'
		'The "Dao" postfix is a naming convention that\'s fairly standard, and stands for Data Access Object.\n'
		'</li>\n'
		'<li>\n'
		'The @Repository annotation is one of several available in the org.springframework.stereotype package, and it\'s what Spring is looking for with component-scanning.\n'
		'You can create your own if you wanted (for example, if you wanted one explicitly named @Dao).\n'
		'The other one typically used is @Service.\n'
		'By convention, services are where an application will typically define its top-level transactional methods that the rest of an application uses.\n'
		'</li>\n'
		'<li>\n'
		'I chose to wire in the <a href="http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/jdbc/core/JdbcTemplate.html">JdbcTemplate</a> through the application context, instead of just the DataSource directly.\n'
		'You can do it either way, but JdbcTemplate is thread-safe as far as running queries goes.\n'
		'So long as you don\'t change any of its state (which only has to do with timeouts and other result processing), you can conceivably have a single JdbcTemplate used by your entire application.\n'
		'</li>\n'
		'<li>\n'
		'I chose to specify the <a href="http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/transaction/annotation/Transactional.html">@Transactional</a> annotation explicitly on each method.\n'
		'Note the propagation parameter, which is used to control how Spring will manage this call within the context of a transaction.\n'
		'I typically use either SUPPORTS (for read-only operations), or REQUIRED (for any insert, update, or delete operation).\n'
		'Other options exist, but I suspect would only be useful for special circumstances.\n'
		'</li>\n'
		'<li>\n'
		'I\'d never defined a primary key or unique index on test_table.\n'
		'That way, the second test always passes -- it just inserts an endless supply of "Just a Test" records. :)\n'
		'</li>\n'
		'</ul>\n'
		'</p>\n'
		'<p>\n'
		'Some of the minor hiccups I came across while writing this:\n'
		'<ul>\n'
		'<li>\n'
		'I\'d completely forgotten about the tx:annotation-driven XML tag at first.\n'
		'Very important!\n'
		'</li>\n'
		'<li>\n'
		'At first, I declared TestTableDao to be private.\n'
		'Spring was unable to add the class to the application context - it needs to be public!\n'
		'</li>\n'
		'<li>\n'
		'I had to run a "GRANT INSERT ON test.test_table TO basictestuser;" in MySQL.  Woops!\n'
		'</li>\n'
		'</ul>\n'
		'</p>\n'
		'<p>\n'
		'Turning on debug-level logging for org.springframework can be helpful when you\'re first doing this.\n'
		'You\'ll be able to follow what it\'s doing immediately before and after the code in your Dao.\n'
		'Here\'s what it looks like when running testInsertTestName:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>2015-03-30 19:15:22,178 DEBUG   367 org.springframework.transaction.support.AbstractPlatformTransactionManager.getTransaction - Creating new transaction with name [ca.rileyman.exploretests.spring.context.BasicAutowiredDataSourceTest$TestTableDao.insertTestName]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT; \'\'\n'
		'2015-03-30 19:15:22,414 DEBUG   206 org.springframework.jdbc.datasource.DataSourceTransactionManager.doBegin - Acquired Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@7d3e8655]]] for JDBC transaction\n'
		'2015-03-30 19:15:22,416 DEBUG   223 org.springframework.jdbc.datasource.DataSourceTransactionManager.doBegin - Switching JDBC Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@7d3e8655]]] to manual commit\n'
		'2015-03-30 19:15:22,428 DEBUG    57 ca.rileyman.exploretests.spring.context.BasicAutowiredDataSourceTest$TestTableDao.insertTestName - Entering with testId = &lt;2&gt;\n'
		'2015-03-30 19:15:22,428 DEBUG    58 ca.rileyman.exploretests.spring.context.BasicAutowiredDataSourceTest$TestTableDao.insertTestName - and testName = &lt;Just a Test&gt;\n'
		'2015-03-30 19:15:22,428 DEBUG   427 org.springframework.jdbc.core.JdbcTemplate.execute - Executing SQL statement [INSERT INTO test_table VALUES (2, \'Just a Test\')]\n'
		'2015-03-30 19:15:22,438 DEBUG    62 ca.rileyman.exploretests.spring.context.BasicAutowiredDataSourceTest$TestTableDao.insertTestName - Exiting\n'
		'2015-03-30 19:15:22,438 DEBUG   755 org.springframework.transaction.support.AbstractPlatformTransactionManager.processCommit - Initiating transaction commit\n'
		'2015-03-30 19:15:22,439 DEBUG   269 org.springframework.jdbc.datasource.DataSourceTransactionManager.doCommit - Committing JDBC transaction on Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@7d3e8655]]]\n'
		'2015-03-30 19:15:22,441 DEBUG   327 org.springframework.jdbc.datasource.DataSourceTransactionManager.doCleanupAfterCompletion - Releasing JDBC Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@7d3e8655]]] after transaction\n'
		'2015-03-30 19:15:22,441 DEBUG   327 org.springframework.jdbc.datasource.DataSourceUtils.doReleaseConnection - Returning JDBC Connection to DataSource</pre>\n'
		'</div>\n'
		'<p>\n'
		'And you can see how it handles any RuntimeException by looking at the logs for testDontDoIt:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>2015-03-30 19:26:29,456 DEBUG   367 org.springframework.transaction.support.AbstractPlatformTransactionManager.getTransaction - Creating new transaction with name [ca.rileyman.exploretests.spring.context.BasicAutowiredDataSourceTest$TestTableDao.dontDoIt]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT; \'\'\n'
		'2015-03-30 19:26:29,692 DEBUG   206 org.springframework.jdbc.datasource.DataSourceTransactionManager.doBegin - Acquired Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@7dfd3c81]]] for JDBC transaction\n'
		'2015-03-30 19:26:29,694 DEBUG   223 org.springframework.jdbc.datasource.DataSourceTransactionManager.doBegin - Switching JDBC Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@7dfd3c81]]] to manual commit\n'
		'2015-03-30 19:26:29,705 DEBUG    76 ca.rileyman.exploretests.spring.context.BasicAutowiredDataSourceTest$TestTableDao.dontDoIt - Entering\n'
		'2015-03-30 19:26:29,705 DEBUG   427 org.springframework.jdbc.core.JdbcTemplate.execute - Executing SQL statement [DELETE FROM test_table]\n'
		'2015-03-30 19:26:29,720 DEBUG   847 org.springframework.transaction.support.AbstractPlatformTransactionManager.processRollback - Initiating transaction rollback\n'
		'2015-03-30 19:26:29,721 DEBUG   284 org.springframework.jdbc.datasource.DataSourceTransactionManager.doRollback - Rolling back JDBC transaction on Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@7dfd3c81]]]\n'
		'2015-03-30 19:26:29,723 DEBUG   327 org.springframework.jdbc.datasource.DataSourceTransactionManager.doCleanupAfterCompletion - Releasing JDBC Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@7dfd3c81]]] after transaction\n'
		'2015-03-30 19:26:29,723 DEBUG   327 org.springframework.jdbc.datasource.DataSourceUtils.doReleaseConnection - Returning JDBC Connection to DataSource</pre>\n'
		'</div>\n'
	),
	'2015-03-30 19:30:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-30 19:30:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	7,
	'Quick Update',
	(
		'<p>\n'
		'Just so readers don\'t think I\'ve disappeared, here\'s a quick update!\n'
		'I\'ve been a bit busy cleaning out my old place, and getting things moved into the new.\n'
		'Tonight I worked a bit on getting a DataSource hooked up in Spring, with transaction management, so expect a blog post about that soon.\n'
		'Things are working as expected, though I did encounter a few things along the way -- I want to make sure I detail all those minor hiccups, but need to get to sleep for now. ;)\n'
		'</p>\n'
		'<p>\n'
		'I\'ve also officially begun production on a new machinima film that will be titled <b>The Serpentis Den</b>.\n'
		'It will feature footage from both <a href="http://www.eveonline.com/">Eve Online</a> and <a href="http://www.lionhead.com/games/the-movies/">The Movies</a>, and of course star my Eve character Shaoylaenn.\n'
		'It\'ll be a fun little 3-minute romp as Shaoylaenn takes on some Serpentis pirates who\'ve foolishly set up shop in Gallente high-security space.\n'
		'The Serpentis are one of the game\'s pirate groups -- they take slaves, deal drugs, and are about as accurate and scary as Stormtroopers from Star Wars. ;)\n'
		'The Gallente are one of the four main factions that you choose during character creation.\n'
		'This short film will act as a bit of a screen test for me as far as camera controls go in Eve Online.\n'
		'Thus far, it\'s been a bit of an adventure already...\n'
		'Eve\'s camera controls are tricky to work with; and my character happens to love flying small ships, making it all the more difficult.\n'
		'My hope is that by tackling a short film first, I can iron out the difficulties with the camera before delving into something with a bit more meat on it.\n'
		'</p>\n'
		'<p style="text-align: center;">\n'
		'<img src="static/images/eve-online/the-serpentis-den/title-banner-initial.jpg" />\n'
		'</p>\n'
	),
	'2015-03-29 23:30:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-29 23:30:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	8,
	'Elite: Dangerous - Shaoylaenn\'s First Discoveries',
	(
		'<p>\n'
		'For my first two months or so of gameplay in Elite: Dangerous, I stuck fairly close to "home" - primarily within the region of the galaxy populated by humans.\n'
		'With a hunger to find my own little corner of the galaxy, untouched by other pilots, I flew out in a random direction and spent a week (which, for me, is about 8 hours game-time) exploring 300 light years out from civilization.\n'
		'</p>\n'
		'<p>\n'
		'<a href="https://www.youtube.com/watch?v=rLBPGJ8wa4c">Shaoylaenn\'s First Discoveries</a> is up on Youtube with the highlights from a particularly beautiful solar system.\n'
		'Head on over to the <a href="https://www.youtube.com/channel/UCHvoItS_0Nmueb0IuZoLSKg">Riley Entertainment Youtube Channel</a> to check it out!\n'
		'</p>\n'
		'<p style="text-align: center;">\n'
		'<img src="static/images/elite/first-discoveries/col-359-sector-cq-m-c8-19/Col-359-Sector-CQ-M-C8-19-4.jpg" />\n'
		'</p>\n'
	),
	'2015-03-22 22:30:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-22 22:30:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	9,
	'Restoring My Animated Films - OMG! TMO is Closing!',
	(
		'<p>\n'
		'<a href="https://www.youtube.com/watch?v=-Q0OswDXYEs">OMG! TMO is Closing!</a> was my final film posted to The Movies Online website prior to it shutting down.\n'
		'While rather crude, I had a blast producing this little film, and still laugh at it to this day. ;)\n'
		'Head on over to the <a href="https://www.youtube.com/channel/UCHvoItS_0Nmueb0IuZoLSKg">Riley Entertainment Youtube Channel</a> to check it out!\n'
		'</p>\n'
		'<p>\n'
		'All voices are indeed me.\n'
		'Impressions include: John McCain, Barack Obama, Ash (Bruce Campbell from Evil Dead), George Bush (Butt-head), Dick Cheney (Beavis), Hank Paulson, Joe Biden, and Sarah Palin.\n'
		'</p>\n'
	),
	'2015-03-21 20:25:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-21 20:25:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	10,
	'Exploring the Spring Framework - Episode 2 - Autowiring Beans',
	(
		'\n'
		'<p>\n'
		'&lt;yoda&gt;My status here a quick note about first.&lt;/yoda&gt;\n'
		'I\'m still in the midst of moving in to a new apartment, but am now in a place where I can post to my blog from here.  Hooray!\n'
		'</p>\n'
		'<p>\n'
		'Based on my recollection of how we build automated tests at my workplace, I thought it would be instructive to write the same test from the last episode, but using Spring\'s auto-wiring feature.\n'
		'The type of objects stored in the application content are typically referred to as "singletons" - your application will usually only need one such object for each class.\n'
		'Good examples are a database data source, "data access objects", or "services".\n'
		'</p>\n'
		'<p>\n'
		'First, I bring in the spring-test module in the test scope in Maven:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;dependency&gt;</div>\n'
		'<div class="tab-1">&lt;groupId&gt;org.springframework&lt;/groupId&gt;</div>\n'
		'<div class="tab-1">&lt;artifactId&gt;spring-test&lt;/artifactId&gt;</div>\n'
		'<div class="tab-1">&lt;version&gt;4.1.5.RELEASE&lt;/version&gt;</div>\n'
		'<div class="tab-1">&lt;scope&gt;test&lt;/scope&gt;</div>\n'
		'<div class="tab-0">&lt;/dependency&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'I borrow the exact same XML context file from my previous blog post, along with the TestBean class.\n'
		'I jog my memory about the org.springframework.test package over on the <a href="http://docs.spring.io/spring/docs/current/javadoc-api/">Spring JavaDocs</a>.\n'
		'I\'m using TestNG, so I can extend from the AbstractTestNGSpringContextTests class for my tests.\n'
		'This class provides the bootstrapping necessary to load an application context, and the ContextConfiguration annotation allows me to specify where the configuration file can be found.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.spring.context;\n'
		'\n'
		'import org.springframework.beans.factory.annotation.Autowired;\n'
		'import org.springframework.test.context.ContextConfiguration;\n'
		'import org.springframework.test.context.testng.AbstractTestNGSpringContextTests;\n'
		'import org.testng.Assert;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'@ContextConfiguration(value={"basic-test-context.xml"})\n'
		'@SuppressWarnings("javadoc")\n'
		'public class BasicAutowiredApplicationContextTest\n'
		'extends AbstractTestNGSpringContextTests\n'
		'{\n'
		'\n'
		'@Autowired\n'
		'private TestBean testBean;\n'
		'\n'
		'@Test\n'
		'public void testAutowiredTestBean() {\n'
		'Assert.assertEquals(testBean.getId(), new Long(1));\n'
		'Assert.assertEquals(testBean.getValue(), "Test");\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'When Spring initializes, it looks for member variables, constructor arguments, or setter methods that have the Autowired annotation.\n'
		'It then attempts to find a matching "bean", and injects it so long as one is found.\n'
		'When first using this functionality, I recommend turning on debug logging for the org.springframework package.\n'
		'Experimenting with injecting beans of the same class (but with different values), or the same bean with multiple variable names, can help demystify the "magic" that Spring is doing behind the scenes.\n'
		'</p>\n'
		'<p>\n'
		'My curiosity led me to expand my test a little bit.\n'
		'This reveals that Spring will inject beans by class, if a variable or argument name does not match the bean\'s id.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.spring.context;\n'
		'\n'
		'import org.springframework.beans.factory.annotation.Autowired;\n'
		'import org.springframework.test.context.ContextConfiguration;\n'
		'import org.springframework.test.context.testng.AbstractTestNGSpringContextTests;\n'
		'import org.testng.Assert;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'@ContextConfiguration(value={"basic-test-context.xml"})\n'
		'@SuppressWarnings("javadoc")\n'
		'public class BasicAutowiredApplicationContextTest\n'
		'extends AbstractTestNGSpringContextTests\n'
		'{\n'
		'\n'
		'@Autowired\n'
		'private TestBean testBean;\n'
		'\n'
		'@Autowired\n'
		'private TestBean totallyDifferentName;\n'
		'\n'
		'@Test\n'
		'public void testAutowiredTestBean() {\n'
		'assertTestBeanValues(testBean);\n'
		'}\n'
		'\n'
		'@Test\n'
		'public void testAutowiredTotallyDifferentName() {\n'
		'assertTestBeanValues(totallyDifferentName);\n'
		'}\n'
		'\n'
		'private void assertTestBeanValues(@SuppressWarnings("hiding") TestBean testBean) {\n'
		'Assert.assertEquals(testBean.getId(), new Long(1));\n'
		'Assert.assertEquals(testBean.getValue(), "Test");\n'
		'}\n'
		'\n'
		'@Test\n'
		'public void ensureOnlyOneTestBeanExists() {\n'
		'Assert.assertTrue(testBean == totallyDifferentName);\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'This blog post was brought to you by the worst line ever spoken by Yoda in a Star Wars film.\n'
		'<a href="https://www.youtube.com/watch?v=9QThD0r3hZg&list=PL56E3EB1DFD4B64A2&index=8">&lt;yoda&gt;Around the survivors, a perimeter create.&lt;/yoda&gt;</a>\n'
		'</p>\n'
	),
	'2015-03-21 19:35:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-21 19:35:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	11,
	'Exploring the Spring Framework - Episode 1 - The Application Context',
	(
		'\n'
		'<p>\n'
		'This blog was partially intended to be an exploration of Java-based software development.\n'
		'So I decided to start a little series with a really self-important naming convention as I (re-)explore the <a href="http://projects.spring.io/spring-framework/">Spring Framework</a>. ;)\n'
		'When I first started at my current workplace, Spring was not used at all.\n'
		'Cached data in our web applications were kept in the HttpServletContext.\n'
		'Database access was done manually, by opening connections directly, handling commits and rollbacks, and dealing with SQLException\'s in try-catch-finally blocks.\n'
		'Some self-important bastard (not me, even though that describes me better than him) knew about Spring and decided to come work with us to tell us all about it.\n'
		'He talked about it, then talked about it some more, then our ears bled and fell off, and we caved and introduced Spring into our code base.\n'
		'I was keen, because I could feel that there was "some way out there that was better".\n'
		'The project I was working on was self-contained enough that I had the opportunity to try it out.\n'
		'</p>\n'
		'<p>\n'
		'At the core of Spring is the application context, which their documentation refers to as the <a href="http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/#beans">Inversion of Control container</a>.\n'
		'This ridiculous name just means that you can set up your application to have certain objects created and initialized by Spring, instead of doing it yourself in Java code.\n'
		'One way to do this, is to basically do it yourself in XML files instead of Java code. ;)\n'
		'</p>\n'
		'<p>\n'
		'Note that if all you were using this for is to create some globally-accessible objects, it wouldn\'t be very good to do it this way.\n'
		'There are actual advantages to the concept of "inversion of control":\n'
		'<ul>\n'
		'<li>Externalizing configuration parameters that may change based on where you deploy your application.</li>\n'
		'<li>Injecting common startup and shutdown code on certain methods using aspect-oriented programming.  This is particularly useful when accessing databases -- the common code being the management of a database connection, including exception handling.</li>\n'
		'<li>When writing tests, allowing mock implementations of a dependency to be injected.</li>\n'
		'</ul>\n'
		'</p>\n'
		'<p>\n'
		'When starting to use any framework, I like the idea of writing simple "exploration" tests.\n'
		'Large frameworks like Spring have huge swaths of documentation.\n'
		'I feel it can be helpful to have someone write tests to figure out how to use the framework, and then keep those tests as a reference for other developers that follow.\n'
		'This hopefully reduces the total time spent by a development team reading documentation and learning the framework.\n'
		'</p>\n'
		'<p>\n'
		'So, to start!  I first add the necessary dependency for Maven:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;dependency&gt;</div>\n'
		'<div class="tab-1">&lt;groupId&gt;org.springframework&lt;/groupId&gt;</div>\n'
		'<div class="tab-1">&lt;artifactId&gt;spring-context&lt;/artifactId&gt;</div>\n'
		'<div class="tab-1">&lt;version&gt;4.1.5.RELEASE&lt;/version&gt;</div>\n'
		'<div class="tab-0">&lt;/dependency&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'I create a really basic "bean" class.\n'
		'Beans are just simple classes that have values you can get and/or set through "accessor" methods.\n'
		'This is the test bean class I used to try out the Spring application context.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.spring.context;\n'
		'\n'
		'@SuppressWarnings("javadoc")\n'
		'public class TestBean\n'
		'{\n'
		'\n'
		'private Long id;\n'
		'private String value;\n'
		'\n'
		'public Long getId() {\n'
		'return id;\n'
		'}\n'
		'\n'
		'public void setId(Long id) {\n'
		'this.id = id;\n'
		'}\n'
		'\n'
		'public String getValue() {\n'
		'return value;\n'
		'}\n'
		'\n'
		'public void setValue(String value) {\n'
		'this.value = value;\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'I\'ll also need a configuration file that says that my application wants a specific TestBean.\n'
		'I name the file "basic-test-context.xml", and place it in /src/test/resources/, in the same folder as my test class (package ca.rileyman.exploretests.spring.context).\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>&lt;?xml version="1.0" encoding="UTF-8"?&gt;\n'
		'&lt;beans\n'
		'xmlns="http://www.springframework.org/schema/beans"\n'
		'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n'
		'xsi:schemaLocation="\n'
		'http://www.springframework.org/schema/beans\n'
		'http://www.springframework.org/schema/beans/spring-beans.xsd\n'
		'"\n'
		'&gt;\n'
		'\n'
		'&lt;bean id="testBean" class="ca.rileyman.exploretests.spring.context.TestBean"&gt;\n'
		'&lt;property name="id" value="1" /&gt;\n'
		'&lt;property name="value" value="Test" /&gt;\n'
		'&lt;/bean&gt;\n'
		'\n'
		'&lt;/beans&gt;</pre>\n'
		'</div>\n'
		'<p>\n'
		'Good lord do I ever hate pasting in XML code to this blog, only to realize I need to replace all the &lt; and &gt; characters with HTML entities. :p  Anyway, I then write a simple test to try it out:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.spring.context;\n'
		'\n'
		'import org.springframework.context.ApplicationContext;\n'
		'import org.springframework.context.support.ClassPathXmlApplicationContext;\n'
		'import org.testng.Assert;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'@SuppressWarnings("javadoc")\n'
		'public class BasicApplicationContextTest\n'
		'{\n'
		'\n'
		'@Test\n'
		'public void testApplicationContextViaXml() {\n'
		'ApplicationContext context = new ClassPathXmlApplicationContext("basic-test-context.xml");\n'
		'\n'
		'TestBean testBean = context.getBean("testBean", TestBean.class);\n'
		'Assert.assertEquals(testBean.getId(), new Long(1));\n'
		'Assert.assertEquals(testBean.getValue(), "Test");\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'The first thing I notice before even running the test is that I\'m getting a compiler warning for the context variable: Resource leak: \'context\' is never closed.\n'
		'The Spring documentation talks about registering a <a href="http://docs.spring.io/spring/docs/3.0.x/spring-framework-reference/html/beans.html#beans-factory-shutdown">shutdown hook</a> with the JVM.\n'
		'Wow, that sounds... complicated.\n'
		'For the purpose of this test, I made things really simple by ignoring the shutdown hook blather.\n'
		'Instead, I nosed around and found that you can just close an AbstractApplicationContext.\n'
		'My test changes to:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.spring.context;\n'
		'\n'
		'import org.springframework.context.support.AbstractApplicationContext;\n'
		'import org.springframework.context.support.ClassPathXmlApplicationContext;\n'
		'import org.testng.Assert;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'@SuppressWarnings("javadoc")\n'
		'public class BasicApplicationContextTest\n'
		'{\n'
		'\n'
		'@Test\n'
		'public void testApplicationContextViaXml() {\n'
		'AbstractApplicationContext context = new ClassPathXmlApplicationContext("basic-test-context.xml");\n'
		'\n'
		'TestBean testBean = context.getBean("testBean", TestBean.class);\n'
		'Assert.assertEquals(testBean.getId(), new Long(1));\n'
		'Assert.assertEquals(testBean.getValue(), "Test");\n'
		'\n'
		'context.close();\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'Running this gives me an error:\n'
		'<span style="color: red;">org.springframework.beans.factory.BeanDefinitionStoreException: IOException parsing XML document from class path resource [basic-test-context.xml]; nested exception is java.io.FileNotFoundException: class path resource [basic-test-context.xml] cannot be opened because it does not exist</span>\n'
		'</p>\n'
		'<p>\n'
		'After some grumbling, I realize that it needs to know the full path to the XML file, to which I grumble further.\n'
		'I notice that the constructor for ClassPathXmlApplicationContext is overloaded, so I specify the path by telling it that it\'s in the same location as my test class:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.spring.context;\n'
		'\n'
		'import org.springframework.context.support.AbstractApplicationContext;\n'
		'import org.springframework.context.support.ClassPathXmlApplicationContext;\n'
		'import org.testng.Assert;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'@SuppressWarnings("javadoc")\n'
		'public class BasicApplicationContextTest\n'
		'{\n'
		'\n'
		'@Test\n'
		'public void testApplicationContextViaXml() {\n'
		'AbstractApplicationContext context = new ClassPathXmlApplicationContext("basic-test-context.xml", BasicApplicationContextTest.class);\n'
		'\n'
		'TestBean testBean = context.getBean("testBean", TestBean.class);\n'
		'Assert.assertEquals(testBean.getId(), new Long(1));\n'
		'Assert.assertEquals(testBean.getValue(), "Test");\n'
		'\n'
		'context.close();\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'The test passes, and I\'m satisfied that I\'ve successfully created the world\'s most useless application context!\n'
		'Tune in next week when I create the same useless context through something magical known as auto-wiring.\n'
		'Also, I would like to inform you that I was listening to Star Wars Prequel music while typing all this, and there\'s nothing you can do about it!  Hahahahaha!\n'
		'</p>\n'
	),
	'2015-03-14 23:05:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-14 23:05:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	12,
	'Adventures in Logging',
	(
		'\n'
		'<p>\n'
		'I wanted to the ability to log debug information - something most Java programmers do as a standard practice.\n'
		'My experience the past two nights has left me with the general impression that virtually all Java libraries for logging are universally crappy, at least in terms of how you have to go about "configuring" them.\n'
		'</p>\n'
		'<p>\n'
		'I started out with just the <a href="http://commons.apache.org/proper/commons-logging/">Apache Commons Logging</a> library.\n'
		'Not so much because I planned on actually using it in the end-state of my application; but rather because most frameworks out there include it as a dependency, and I thus wanted to know about it.\n'
		'Simply put, it\'s not kept up-to-date, documentation is kind of poor, and my experience was that examples I found through Google didn\'t even work as they claimed.\n'
		'I was able to get the "SimpleLog" implementation to behave the way I expected, but the "Jdk14Logger" did not.\n'
		'What was strange is that following through a debug session with Jdk14Logger confirmed that it was finding my configuration file and loading in the properties that should work - but apparently it just ignored them (I\'m specifically referring to the simple ".level" property).\n'
		'</p>\n'
		'<p>\n'
		'Ultimately, I gave up on trying to learn how to make the Apache Commons Logging library work as I would expect it to, as I feel I have better things to do with my time. ;)\n'
		'So I started down the path of using the library I know I want to use in the end:  <a href="http://slf4j.org/manual.html">slf4j</a>.\n'
		'Even slf4j is a bit confusing just to get started with it.\n'
		'</p>\n'
		'<p>\n'
		'The first step was to bring in the latest version through Maven:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;dependency&gt;</div>\n'
		'<div class="tab-1">&lt;groupId&gt;org.slf4j&lt;/groupId&gt;</div>\n'
		'<div class="tab-1">&lt;artifactId&gt;slf4j-api&lt;/artifactId&gt;</div>\n'
		'<div class="tab-1">&lt;version&gt;1.7.10&lt;/version&gt;</div>\n'
		'<div class="tab-0">&lt;/dependency&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'I then wrote a simple test class, which I ultimately want to just send some log messages to the console so I can see it working.\n'
		'I actually knew at this point that I was still missing the configuration, but ran it anyway to see what the output would be.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.logging;\n'
		'\n'
		'import org.slf4j.Logger;\n'
		'import org.slf4j.LoggerFactory;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'@SuppressWarnings("javadoc")\n'
		'public class Slf4jLoggerTest\n'
		'{\n'
		'\n'
		'private static final Logger log = LoggerFactory.getLogger(Slf4jLoggerTest.class);\n'
		'\n'
		'@Test\n'
		'public void testLog() {\n'
		'log.debug("This is from log.debug");\n'
		'log.info("This is from log.info");\n'
		'log.error("This is from log.error");\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'Running this at this point generated an error I wasn\'t expecting:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre style="color: red;">SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".\n'
		'SLF4J: Defaulting to no-operation (NOP) logger implementation\n'
		'SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.</pre>\n'
		'</div>\n'
		'<p>\n'
		'The line I frowned at was <span style="color: red;">Defaulting to no-operation (NOP) logger implementation</span>.\n'
		'This is essentially saying that even if it had been configured properly (more on that later), it wouldn\'t have produced any logging.\n'
		'The slf4j library still wants an actual logging library to be in place for it to work.\n'
		'Because, you know, a logging library that doesn\'t actually log anything is super spiffy and awesome.\n'
		'So I follow the <a href="http://slf4j.org/manual.html">user manual</a>, and bring in an additional dependency to tell slf4j which logging library it (as a logging library) should go ahead and use (because obviously it can\'t use itself, as it\'s some sort of non-logging logging library).\n'
		'I chose the log4j binding:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;dependency&gt;</div>\n'
		'<div class="tab-1">&lt;groupId&gt;org.slf4j&lt;/groupId&gt;</div>\n'
		'<div class="tab-1">&lt;artifactId&gt;slf4j-log4j12&lt;/artifactId&gt;</div>\n'
		'<div class="tab-1">&lt;version&gt;1.7.10&lt;/version&gt;</div>\n'
		'<div class="tab-0">&lt;/dependency&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'Running the test again generates the error I was actually expecting:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre style="color: red;">log4j:WARN No appenders could be found for logger (ca.rileyman.exploretests.logging.Slf4jLoggerTest).\n'
		'log4j:WARN Please initialize the log4j system properly.\n'
		'log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.</pre>\n'
		'</div>\n'
		'<p>\n'
		'Now I need to configure log4j, which I choose to do through the log4j.xml file.\n'
		'I place this in /src/main/config, and just go with a basic configuration file for the purpose of testing it out.\n'
		'A google search lands on an <a href="http://wiki.apache.org/logging-log4j/Log4jXmlFormat">Apache Wiki page</a> with a decent example.\n'
		'I didn\'t like the format provided, so I consulted the JavaDocs for <a href="http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html">PatternLayout</a>.\n'
		'I kinda like this conversion pattern: "%d{ISO8601} %-6p %4L %C.%M - %m%n".\n'
		'I re-run the test and get my logging output:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>2015-03-12 22:48:09,310 DEBUG    15 ca.rileyman.exploretests.logging.Slf4jLoggerTest.testLog - This is from log.debug\n'
		'2015-03-12 22:48:09,311 INFO     16 ca.rileyman.exploretests.logging.Slf4jLoggerTest.testLog - This is from log.info\n'
		'2015-03-12 22:48:09,311 ERROR    17 ca.rileyman.exploretests.logging.Slf4jLoggerTest.testLog - This is from log.error</pre>\n'
		'</div>\n'
		'<p>\n'
		'If you\'re wondering why I\'m using slf4j, and not just plain log4j, it\'s really just because it provides some extra convenience logging methods.\n'
		'You can provide simple formatting strings with placeholders for additional arguments, like so:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'log.debug("Enter with value <{}>", inputValue);\n'
		'</div>\n'
		'<p>\n'
		'Which would generate a log message like "Enter with value <5>".\n'
		'</p>\n'
	),
	'2015-03-12 23:00:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-12 23:00:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	13,
	'Elite: Dangerous - Wings Update 1.2 is Crazy Big',
	(
		'\n'
		'<p>\n'
		'Frontier released the Wings Update (version 1.2) today, after what seemed like maybe a week\'s worth of open beta testing.\n'
		'I\'m curious how a week in beta gave them enough time to respond to any feedback from the beta-testers...\n'
		'Not only is the <a href="https://forums.frontier.co.uk/showthread.php?t=123776">change list</a> insanely long, but the update is <b>3.67GB</b> and is estimated to take <b>4 hours</b> with my Internet connection.\n'
		'I guess this means I won\'t be playing my typical hours-worth of Elite tonight.  :(\n'
		'</p>\n'
		'<p>\n'
		'This update is said to bring some enhanced multi-player support.\n'
		'Players can group together in Wings of up to 4 players, and be guaranteed to end up in the same instance for all activities.\n'
		'Multi-player is one area that Elite has been in dire need of enhancements.\n'
		'While I haven\'t tried multi-player myself (too much of a commitment), I\'ve read some of the anecdotes on the forums.\n'
		'Imagine your friend is interdicted by another player, so you follow their frame shift wake.\n'
		'You drop out of warp, and from your perspective they\'re otherwise alone, yet they\'re being damaged by an unseen foe.\n'
		'This is something that Eve Online doesn\'t suffer from at all - in Eve, there is no instancing, so you truly are a part of the same shared universe.\n'
		'I have some <a href="https://www.youtube.com/watch?v=Hy3o2MAJzBw">Youtube videos</a> up from some fleet operations involving many dozens of players.\n'
		'You can really see the strength of Eve when you get into a big fleet - every one of those purple boxes is a friendly player in my fleet, and the oranges are the enemy players.\n'
		'FUN!\n'
		'</p>\n'
	),
	'2015-03-10 21:25:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-10 21:25:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	14,
	'Tomcat Database Connection Pool Test',
	(
		'\n'
		'<p>\n'
		'My next step in getting database access available to my web application is understanding the options available for connection pools.\n'
		'My last blog entry showed a test using the JDBC driver directly.\n'
		'This is sufficient for the low volumes I\'ll be experiencing with this site, of course, but I still want to know about connection pools.\n'
		'At work, this aspect of programming has always just been "there" for me.\n'
		'I\'ve seen the connection properties we use, and code data access objects all the time, but it was never really front-and-center in my attention.\n'
		'</p>\n'
		'<p>\n'
		'My host has provided me with Apache Tomcat 7, and Tomcat provides its own <a href="http://tomcat.apache.org/tomcat-7.0-doc/jdbc-pool.html">JDBC Connection Pool</a> library.\n'
		'According to the Tomcat documentation, their library provides enhancements over the <a href="http://commons.apache.org/proper/commons-dbcp/">Apache Commons DBCP</a> library.\n'
		'Since this is a web-based application, and I don\'t feel like spending loads of time comparing the two, I figure I\'ll just go with the Tomcat connection pool.\n'
		'</p>\n'
		'<p>\n'
		'Tomcat comes standard with its own list of JAR files, which the servlet container always has available for web applications (not that you typically access the majority of these classes from your web applications).\n'
		'My local test environment, however, doesn\'t have direct access to these classes.\n'
		'Since I want to write a simple test to try this out, I first add a Maven dependency for it - but I limit the scope to test-only.\n'
		'This ensures this JAR won\'t be included in my WAR file when I build the project.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;dependency&gt;</div>\n'
		'<div class="tab-1">&lt;groupId&gt;org.apache.tomcat&lt;/groupId&gt;</div>\n'
		'<div class="tab-1">&lt;artifactId&gt;tomcat-jdbc&lt;/artifactId&gt;</div>\n'
		'<div class="tab-1">&lt;version&gt;7.0.59&lt;/version&gt;</div>\n'
		'<div class="tab-1">&lt;scope&gt;test&lt;/scope&gt;</div>\n'
		'<div class="tab-0">&lt;/dependency&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'When I first added this dependency, I chose version 7.0.19 (as per a StackOverflow question I found while googling this).\n'
		'It turns out that at least some of the older versions don\'t have their full dependency list registered properly, because that version neglected to include the tomcat-juli library as well (which tomcat-jdbc uses for logging).\n'
		'</p>\n'
		'<p>\n'
		'Just to add extra confusion, there is also a tomcat-dbcp library.\n'
		'As near as I can figure, this is just a copy of the Apache Commons DBCP, placed in different packages.\n'
		'</p>\n'
		'<p>\n'
		'I then took a large chunk of the code from my last blog post and threw it in a static utility class (everything from runTestStatement down).\n'
		'The only difference between this new test, and the previous test, is how the test will retrieve the database connection.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.tomcat.jdbc;\n'
		'\n'
		'import java.sql.Connection;\n'
		'import java.sql.SQLException;\n'
		'\n'
		'import org.apache.tomcat.jdbc.pool.DataSource;\n'
		'import org.apache.tomcat.jdbc.pool.PoolConfiguration;\n'
		'import org.apache.tomcat.jdbc.pool.PoolProperties;\n'
		'import org.testng.Assert;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'import ca.rileyman.exploretests.mysql.LegacyMySqlTestUtils;\n'
		'\n'
		'@SuppressWarnings("javadoc")\n'
		'public class ExploreMySqlDataSourceTest\n'
		'{\n'
		'\n'
		'@Test\n'
		'public void testDataSourceConnection() {\n'
		'javax.sql.DataSource dataSource = createDataSource();\n'
		'\n'
		'Connection conn = null;\n'
		'try {\n'
		'conn = dataSource.getConnection();\n'
		'LegacyMySqlTestUtils.runTestStatement(conn);\n'
		'} catch ( SQLException e ) {\n'
		'Assert.fail("Could not open Connection", e);\n'
		'} finally {\n'
		'if ( conn != null ) {\n'
		'LegacyMySqlTestUtils.closeConnection(conn);\n'
		'}\n'
		'}\n'
		'}\n'
		'\n'
		'private javax.sql.DataSource createDataSource() {\n'
		'DataSource result = new DataSource();\n'
		'result.setPoolProperties(createPoolConfiguration());\n'
		'return result;\n'
		'}\n'
		'\n'
		'private PoolConfiguration createPoolConfiguration() {\n'
		'PoolConfiguration result = new PoolProperties();\n'
		'\n'
		'result.setUrl("jdbc:mysql://localhost/test");\n'
		'result.setDriverClassName("com.mysql.jdbc.Driver");\n'
		'result.setUsername("basictestuser");\n'
		'result.setPassword("testpass");\n'
		'\n'
		'result.setTestOnBorrow(true);\n'
		'result.setValidationQuery("SELECT 1");\n'
		'\n'
		'result.setMaxIdle(5);\n'
		'result.setMaxActive(10);\n'
		'result.setMinIdle(1);\n'
		'\n'
		'return result;\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'The particulars on the database pool properties are something that can be tweaked on an ongoing basis.\n'
		'This gets me one step closer to how I\'ll be accessing the database in this web application.\n'
		'I also want to be able to mimic the same connection pool in my tests.\n'
		'My next blog post will externalize the DataSource in the test environment using dependency injection within the <a href="http://projects.spring.io/spring-framework/">Spring Framework</a>.\n'
		'</p>\n'
	),
	'2015-03-10 20:50:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-10 20:50:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	15,
	'Legacy MySQL Database Access Test',
	(
		'\n'
		'<p>\n'
		'I thought it might be interesting and/or instructive to write some test code that accesses my local MySQL database, using what most would consider "legacy code".\n'
		'This test shows how we all used to code database access using the core java.sql package.\n'
		'First, I open up the MySQL command line (logged in as root) to create a test table and populate it with test data:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">USE test;</div>\n'
		'<div class="tab-0">&nbsp;</div>\n'
		'<div class="tab-0">CREATE TABLE test_table (</div>\n'
		'<div class="tab-1">test_id INTEGER NOT NULL,</div>\n'
		'<div class="tab-1">test_name VARCHAR(50) NOT NULL</div>\n'
		'<div class="tab-0">);</div>\n'
		'<div class="tab-0">&nbsp;</div>\n'
		'<div class="tab-0">INSERT INTO test_table VALUES (1, \'Hello World\');</div>\n'
		'<div class="tab-0">&nbsp;</div>\n'
		'<div class="tab-0">CREATE USER basictestuser IDENTIFIED BY \'testpass\';</div>\n'
		'<div class="tab-0">GRANT SELECT ON test.test_table TO basictestuser;</div>\n'
		'</div>\n'
		'<p>\n'
		'I then add the Maven dependency for the MySQL JDBC driver:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;dependency&gt;</div>\n'
		'<div class="tab-1">&lt;groupId&gt;mysql&lt;/groupId&gt;</div>\n'
		'<div class="tab-1">&lt;artifactId&gt;mysql-connector-java&lt;/artifactId&gt;</div>\n'
		'<div class="tab-1">&lt;version&gt;5.1.34&lt;/version&gt;</div>\n'
		'<div class="tab-0">&lt;/dependency&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'And here is what I mean by writing a "legacy" test.\n'
		'This accesses the database the old-fashioned way, through the driver manager.\n'
		'While this is throw-away code for me, I thought it would be instructive to go through the motions so that potential readers could see the difference when I write the same test using the Spring framework.\n'
		'I still try to follow good programming practices by keeping methods short, concise, and well-named.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<pre>package ca.rileyman.exploretests.mysql;\n'
		'\n'
		'import java.sql.Connection;\n'
		'import java.sql.DriverManager;\n'
		'import java.sql.ResultSet;\n'
		'import java.sql.SQLException;\n'
		'import java.sql.Statement;\n'
		'\n'
		'import org.testng.Assert;\n'
		'import org.testng.annotations.Test;\n'
		'\n'
		'@SuppressWarnings("javadoc")\n'
		'public class ExploreLegacyMySqlDriverTest\n'
		'{\n'
		'\n'
		'@Test\n'
		'public void testDriverManagerConnection() {\n'
		'ensureMySqlDriverIsRegistered();\n'
		'\n'
		'Connection conn = null;\n'
		'try {\n'
		'conn = DriverManager.getConnection(\n'
		'"jdbc:mysql://localhost/test?" +\n'
		'"user=basictestuser&password=testpass"\n'
		');\n'
		'runTestStatement(conn);\n'
		'} catch ( SQLException e ) {\n'
		'Assert.fail("Could not open Connection", e);\n'
		'} finally {\n'
		'if ( conn != null ) {\n'
		'closeConnection(conn);\n'
		'}\n'
		'}\n'
		'}\n'
		'\n'
		'private void ensureMySqlDriverIsRegistered() {\n'
		'try {\n'
		'Class.forName("com.mysql.jdbc.Driver").newInstance();\n'
		'} catch ( Exception e ) {\n'
		'Assert.fail("Could not register MySQL driver");\n'
		'}\n'
		'}\n'
		'\n'
		'private void runTestStatement(Connection conn) {\n'
		'Statement statement = null;\n'
		'\n'
		'try {\n'
		'statement = conn.createStatement();\n'
		'runTestQuery(statement);\n'
		'} catch ( SQLException e ) {\n'
		'Assert.fail("Could not create Statement", e);\n'
		'} finally {\n'
		'if ( statement != null ) {\n'
		'closeStatement(statement);\n'
		'}\n'
		'}\n'
		'}\n'
		'\n'
		'private void runTestQuery(Statement statement) {\n'
		'ResultSet resultSet = null;\n'
		'\n'
		'try {\n'
		'resultSet = statement.executeQuery("SELECT test_name FROM test_table WHERE test_id = 1");\n'
		'assertExpectedResultSet(resultSet);\n'
		'} catch ( SQLException e ) {\n'
		'Assert.fail("Could not execute query", e);\n'
		'} finally {\n'
		'if ( resultSet != null ) {\n'
		'closeResultSet(resultSet);\n'
		'}\n'
		'}\n'
		'}\n'
		'\n'
		'private void assertExpectedResultSet(ResultSet resultSet) {\n'
		'try {\n'
		'resultSet.next();\n'
		'Assert.assertEquals(resultSet.getString("test_name"), "Hello World");\n'
		'} catch ( SQLException e ) {\n'
		'Assert.fail("Could not retrieve test_name value", e);\n'
		'}\n'
		'}\n'
		'\n'
		'private void closeResultSet(ResultSet resultSet) {\n'
		'try {\n'
		'resultSet.close();\n'
		'} catch ( SQLException e ) {\n'
		'Assert.fail("Could not close ResultSet", e);\n'
		'}\n'
		'}\n'
		'\n'
		'private void closeStatement(Statement statement) {\n'
		'try {\n'
		'statement.close();\n'
		'} catch ( SQLException e ) {\n'
		'Assert.fail("Could not close Statement", e);\n'
		'}\n'
		'}\n'
		'\n'
		'private void closeConnection(Connection conn) {\n'
		'try {\n'
		'conn.close();\n'
		'} catch ( SQLException e ) {\n'
		'Assert.fail("Could not close Connection", e);\n'
		'}\n'
		'}\n'
		'\n'
		'}</pre>\n'
		'</div>\n'
		'<p>\n'
		'Update:  There, that\'s much better just wrapped up in a pre tag. ;)\n'
		'You can copy-paste it now, and the max-height CSS property ensures big code snippets won\'t dominate my blog!\n'
		'</p>\n'
	),
	'2015-03-09 19:55:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-09 19:55:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	16,
	'Tomcat Default Context',
	(
		'\n'
		'<p>\n'
		'First off, just a note on my absence for the past 2 weeks...\n'
		'I\'m currently moving out of my place, so these past two weeks have involved lots of apartment hunting.\n'
		'This weekend I also had some family stuff going on.\n'
		'I\'ve found my new home, and next weekend will be the first bit of moving in.\n'
		'Once I\'m all settled in, things here should start cooking. ;)\n'
		'</p>\n'
		'<p>\n'
		'I had a small adventure here trying to get Tomcat to recognize the setup I wanted.\n'
		'My host provides a dual hosting approach, with Apache serving static content, and Tomcat serving dynamic content.\n'
		'I wanted to effectively mimic this setup on my local machine, except that since I don\'t have the Apache web server (and don\'t particularly want it), I decided to try to setup Tomcat so that I\'d have two contexts.\n'
		'The root context would serve the static portion that you\'re seeing now, and a "portals" context would serve all my dynamic Java-based content.\n'
		'This should be possible with a small addition to the conf/server.xml file:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;Context path="/" docBase="base_war_filename" reloadable="true" /&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'This, of course, didn\'t work at all after stopping and starting Tomcat.\n'
		'So I yelled at my computer for a few minutes asking it why it wasn\'t working. :p\n'
		'There\'s just one extra trick:\n'
		'Out-of-the-box, Tomcat comes with a ROOT context that is already pre-installed.\n'
		'This folder first needed to be removed, and the server restarted with my WAR file in place.\n'
		'</p>\n'
		'<p>\n'
		'However, I\'m finding that this solution has several problems:\n'
		'<ul>\n'
		'<li>\n'
		'Tomcat is deciding to deploy my WAR file to two contexts:\n'
		'the root, and its normal location based on the WAR\'s base filename.\n'
		'</li>\n'
		'<li>\n'
		'In the Tomcat manager, I now see <i>three</i> contexts!\n'
		'Two of them are for the root, and the third is its normal location.\n'
		'</li>\n'
		'<li>\n'
		'Replacing the WAR file in the /webapps folder is only automatically redeploying the context in its normal location.\n'
		'Worse, in order to redeploy the root, I have to stop Tomcat, delete the ROOT folder, and start Tomcat again.\n'
		'</li>\n'
		'</ul>\n'
		'</p>\n'
		'<p>\n'
		'I then thought that maybe the path="/" was causing this, so I changed it to just path="":\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;Context path="" docBase="base_war_filename" reloadable="true" /&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'This solves the issue of Tomcat showing three contexts (it now only shows two, which I still consider to be incorrect).\n'
		'However, it does not solve the deployment issue.\n'
		'</p>\n'
		'<p>\n'
		'So, I decided to bite the bullet, and just name my damned WAR file "ROOT.war", and remove that Context entry from server.xml.\n'
		'Voila, Tomcat lets me redeploy it while it\'s running; and it correctly only shows the single root context.\n'
		'In Maven, this amounts to an update to the POM file:\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;build&gt;</div>\n'
		'<div class="tab-1">&lt;finalName&gt;ROOT&lt;/finalName&gt;</div>\n'
		'<div class="tab-0">&lt;/build&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'I actually despise this as a solution, because it\'s forcing me to name my WAR file a particular way.\n'
		'But it works for what I\'m trying to achieve, and I don\'t have any other need on my local machine for a root context.\n'
		'</p>\n'
	),
	'2015-03-08 15:10:00',
	'Riley',
	'Y',
	'Y',
	'2015-03-08 15:10:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	17,
	'Mesh Reconstruction Utilities for The Movies Game',
	(
		'\n'
		'<p>\n'
		'Years ago, while making machinima films and being part of <a href="http://www.lionhead.com/games/the-movies/">The Movies game</a> community, I was also very active in building little applications useful for the modding side of the community.\n'
		'The "Mesh Reconstruction Utilities" is a series of command-line applications used to extract and reconstruct props from existing sets, and to build new combined props that could be used on the blue screen set.\n'
		'Being driven off the command-line, they\'re a little bit difficult to use - but I did write up a fairly detailed user document, and running the applications with no input parameters does provide some decent information on how to get started.\n'
		'They were written in C/C++.\n'
		'</p>\n'
		'<p>\n'
		'<ul>\n'
		'<li>\n'
		'<b>Mesh Reports</b> :\n'
		'Outputs information about a given mesh file.\n'
		'This also performs analysis on the mesh data, resolving where each 3D object can be found.\n'
		'Use the information from this utility to figure out your commands for the Prop Extraction utility.\n'
		'</li>\n'
		'<li>\n'
		'<b>Prop Extraction</b> :\n'
		'Extracts props from a given mesh file.\n'
		'This is the most complex, but most powerful, of all these utilities.\n'
		'Make texture and material changes, isolate individual 3D objects, perform 3D transformations, and apply rectangular clipping regions.\n'
		'A "modder\'s tool" through and through.\n'
		'</li>\n'
		'<li>\n'
		'<b>Prop Transformation</b> :\n'
		'Performs basic transformations to an entire prop.\n'
		'Make global texture changes, alter light-maps, and center, scale, or rotate a prop.\n'
		'</li>\n'
		'<li>\n'
		'<b>Set Dressing to Prop</b> :\n'
		'Take a saved set dressing file and combine its contents into a single prop, for easy use on any of the various Blue Screen sets.\n'
		'</li>\n'
		'<li>\n'
		'<b>Room Builder</b> :\n'
		'Creates new room interiors, or building exteriors, based on script files.\n'
		'Features include the ability to "cut out" sections of a wall to insert doors or windows, add set dressing, and create "cutout and room libraries" that can be stitched together like lego pieces!\n'
		'</li>\n'
		'</ul>\n'
		'</p>\n'
		'<p>\n'
		'The Room Builder is particularly cool. ;)\n'
		'I plan on using it soon to build the interior set of Shaoylaenn\'s Ishkur.\n'
		'Yes, I\'m making a short little space movie!\n'
		'</p>\n'
		'<p>\n'
		'Download the <a href="static/downloads/the-movies/modding/r3-tm-mesh-recon-v0023a.zip">Mesh Reconstruction Utilities</a> (ZIP file).\n'
		'Extract to any folder of your choice, open up a command-line prompt, navigate to that folder, and away you go!\n'
		'</p>\n'
		'<p>\n'
		'View or download the <a href="static/downloads/the-movies/modding/r3-tm-mesh-recon-user-guide.pdf">User\'s Guide</a> (Adobe PDF file).\n'
		'</p>\n'
	),
	'2015-02-24 19:24:00',
	'Riley',
	'Y',
	'Y',
	'2015-02-24 19:24:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	18,
	'Using Apache Maven for the Build Process',
	(
		'\n'
		'<p>\n'
		'For managing this website\'s build process, I decided to start out by trying <a href="http://maven.apache.org/">Apache Maven</a>.\n'
		'In the past, I had used an Eclipse Tomcat plugin - it\'s been a long while, but I recall it not being terribly difficult to generate the WAR file at the time.\n'
		'The place where I work professionally uses Apache Ant, with a fairly complicated and out-dated build process - this was something I wanted to avoid.  ;)\n'
		'</p>\n'
		'<p>\n'
		'The general process for creating a servlet-based application using Apache Maven seems to follow these steps:\n'
		'<ol>\n'
		'<li>Run a Maven command to generate your project.  Maven uses what it calls "archetypes" to set up the initial folder structure, and generate its default project settings.</li>\n'
		'<li>In Eclipse, create a Java Project pointing at the root folder.  Change its default output folder to a new "target" directory off the root.</li>\n'
		'<li>Right-click the project, and go to Configure -> Convert to Maven Project.</li>\n'
		'<li>To generate the WAR file in Eclipse, go to Run As -> Maven Install.</li>\n'
		'</ol>\n'
		'</p>\n'
		'<p>\n'
		'Unfortunately, my Eclipse hung and then spazzed out completely when I tried using the Maven plugin to create a new Maven project.\n'
		'So for the first step above, I used the command-line.\n'
		'The command-line arguments you need to get things going are fairly verbose, so I created a little DOS batch file for myself so that all I need as an input is the project name.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'mvn archetype:generate -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-webapp -DgroupId=ca.rileyman -DartifactId=%1\n'
		'</div>\n'
		'<p>\n'
		'The particularly nice thing about Maven is how it handles external dependencies for you.\n'
		'Most Java frameworks out there today support Maven, and will provide you with the XML blurb you need to add it to your project.\n'
		'Maven will go ahead and automatically download the JAR file for you, and add it to your project automatically.\n'
		'If you want to update to a new version, it can be as easy as updating the version number in your project\'s POM file, so long as the framework\'s API hasn\'t deprecated anything out of existence.\n'
		'Out of the box, Maven adds a dependency to JUnit into your project, using the standard web application archetype.\n'
		'I wanted to change that, so I took out the JUnit dependency, and replaced it with TestNG.\n'
		'</p>\n'
		'<div class="code-snippet">\n'
		'<div class="tab-0">&lt;dependency&gt;</div>\n'
		'<div class="tab-1">&lt;groupId&gt;org.testng&lt;/groupId&gt;</div>\n'
		'<div class="tab-1">&lt;artifactId&gt;testng&lt;/artifactId&gt;</div>\n'
		'<div class="tab-1">&lt;version&gt;6.1.1&lt;/version&gt;</div>\n'
		'<div class="tab-1">&lt;scope&gt;test&lt;/scope&gt;</div>\n'
		'<div class="tab-0">&lt;/dependency&gt;</div>\n'
		'</div>\n'
		'<p>\n'
		'I\'ll keep going with Maven for the time-being, but I do plan on trying out <a href="https://gradle.org/">Gradle</a> in the not-too-distant future.\n'
		'Several of my co-workers have raved about Gradle.\n'
		'It\'s new, being kept up-to-date, and sounds like they\'re hitting the right balance of convention and flexibility.\n'
		'(For some reason, everytime someone brings up Gradle, <a href="http://southpark.wikia.com/wiki/Dreidel,_Dreidel,_Dreidel">this</a> pops into my head.)\n'
		'</p>\n'
	),
	'2015-02-23 21:10:00',
	'Riley',
	'Y',
	'Y',
	'2015-02-23 21:10:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	19,
	'Shaoylaenn\'s "First Discovery"',
	(
		'\n'
		'<figure class="floatRight">\n'
		'<a href="static/images/elite/first-discoveries/herculis-sector-gr-w-c1-13/herculis-sector-gr-w-c1-13-10e-full.jpg"><img src="static/images/elite/first-discoveries/herculis-sector-gr-w-c1-13/herculis-sector-gr-w-c1-13-10e-icon-200.jpg" width="200" /></a>\n'
		'<figcaption>First Discovery Tag - Click for Screenshot</figcaption>\n'
		'</figure>\n'
		'<p>\n'
		'Exploration in Elite: Dangerous, beginning in version 1.1, has the concept of "First Discovery".\n'
		'The entire galaxy is up for grabs in a persistent universe - if you\'re the first to perform a detailed surface scan of a planetary body, and then sell that data, you\'ll get credit for it.\n'
		'I had resigned myself to the notion that it would be a long while before I found any planet or moon first:  I play rather methodically, don\'t have tons of time for games, and have yet to leave the populated regions of space.\n'
		'</p>\n'
		'<p>\n'
		'This all changed when I turned in my exploration data for <b>Herculis Sector GR-W c1-13</b>.\n'
		'My first discovery is moon E, of planet 10, a Class I Gas Giant with two rings and 7 moons.\n'
		'How exciting!!  An icy moon with a thin Methane atmosphere!\n'
		'My single discovery in a system of over 40 planetary bodies!\n'
		'</p>\n'
		'<p>\n'
		'Heh - special thanks go to Veyor and H.H. Walther, who have the First Discovery tags on every other planetary body in the system.\n'
		'Your combined effort to avoid scanning that single moon has given me my very first, FIRST DISCOVERY!  LOL!\n'
		'</p>\n'
	),
	'2015-02-21 08:20:00',
	'Riley',
	'Y',
	'Y',
	'2015-02-21 08:20:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	20,
	'Restoring My Animated Films',
	(
		'<figure class="floatRight">\n'
		'<img src="static/images/the-movies/ode-to-a-sten-gun/sten-gun-blog-icon.jpg" width="60px" />\n'
		'<figcaption>Soldiers firing STEN guns</figcaption>\n'
		'</figure>\n'
		'<p>\n'
		'As mentioned over on the Home page, years ago I was heavily involved in producing short animated films using Lionhead Studios\' <a href="http://www.lionhead.com/games/the-movies/">The Movies</a>.\n'
		'The shortest of the lot was a video interpretation of a World War 2 poem by S.N. Teed titled <a href="https://www.youtube.com/watch?v=0bht5XE3Gm0">Ode to a STEN Gun</a>.\n'
		'Head on over to the <a href="https://www.youtube.com/channel/UCHvoItS_0Nmueb0IuZoLSKg">Riley Entertainment Youtube Channel</a> to check it out!\n'
		'</p>\n'
		'<p>\n'
		'I have three other animated films I\'ll be restoring in the coming weeks.\n'
		'Along with each, I\'ll also be restoring their companion websites that gave some insight on how the films were produced, and what inspired me to create them.\n'
		'</p>\n'
	),
	'2015-02-19 21:50:00',
	'Riley',
	'Y',
	'Y',
	'2015-02-19 21:50:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	21,
	'Getting Set Up with Kattare',
	(
		'<p>\n'
		'The site you\'re seeing is currently hosted by <a href="http://www.kattare.com/">Kattare</a>, who are known as being focused on Java-based hosting.\n'
		'So far, things are going well.\n'
		'The staff there seem extremely responsive, and they do all the setup for you, which for me is a big plus.\n'
		'</p>\n'
		'<p>\n'
		'The one disappointment I have with Kattare is with the disk space quota - my plan has 500 MB, which I would exceed easily just with a few of the animated films I plan on posting.\n'
		'Even the corporate plans at 2GB seems rather small to me, but I guess their typical client is more focused on database usage and functionality over downloadable content.\n'
		'For the near-term, I\'ll be using social media sites like <a href="http://www.youtube.com/">Youtube</a> and <a href="http://www.imgur.com/">Imgur</a>.\n'
		'Longer term, I may look to set up a downloads.riley-man.com site on another host for large content files.\n'
		'</p>\n'
	),
	'2015-02-18 19:50:00',
	'Riley',
	'Y',
	'Y',
	'2015-02-18 19:50:00',
	'Riley'
);

INSERT INTO r3_blog_post (
	blog_id,
	post_id,
	post_title,
	post_text,
	post_date,
	poster_username,
	active_flag,
	allow_comments_flag,
	last_update_date,
	last_update_username
) VALUES (
	( SELECT blog_id FROM r3_blog WHERE blog_code = 'RILEY_WEBSITE' ),
	22,
	'A New Beginning',
	(
		'<p>\n'
		'The Riley Programming Site is making a long-overdue comeback!\n'
		'As mentioned on the <a href="index.html">Home</a> page, I\'ll be building this site from the ground-up as I explore a variety of Java-based web frameworks.\n'
		'Take a look at the Goals section to see what\'s coming, and stay tuned in this space for ongoing updates!\n'
		'</p>\n'
		'<p>\n'
		'I\'ll also be restoring some of my old content at a reasonable pace - as much as my free time allows while still keeping my sanity. ;)\n'
		'In particular, you should start to see some of my past short animated films reappear very soon.\n'
		'Along with the old, I\'m also working on some new content along those lines.\n'
		'Here\'s to crossing my fingers that I can entertain you enough to come back for more!\n'
		'</p>\n'
	),
	'2015-02-17 19:10:00',
	'Riley',
	'Y',
	'Y',
	'2015-02-17 19:10:00',
	'Riley'
);
