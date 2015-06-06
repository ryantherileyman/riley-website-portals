package ca.rileyman.website.blog.web.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collection;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.util.HtmlUtils;

import ca.rileyman.website.blog.model.BlogPost;
import ca.rileyman.website.blog.model.BlogPostComment;
import ca.rileyman.website.blog.model.input.NewCommentInput;
import ca.rileyman.website.blog.search.BlogPostNavSearch;
import ca.rileyman.website.blog.service.BlogPostService;
import ca.rileyman.website.blog.service.result.InitialBlogPostListResult;
import ca.rileyman.website.blog.service.result.SaveNewCommentResult;

/**
 * Servlet used to generate blog post output.
 */
public class BlogPostServlet
extends HttpServlet
{
	
	private static final long serialVersionUID = -4201919215095378844L;
	
	private static final Logger log = LoggerFactory.getLogger(BlogPostServlet.class);
	
	private static final String DEFAULT_BLOG_POST_CODE = "RILEY_WEBSITE";
	private static final int DEFAULT_BLOG_POSTS_PER_PAGE = 20;
	
	@SuppressWarnings("javadoc")
	public enum Operation {
		
		LOAD_INITIAL_BLOG_POSTS,
		LOAD_BY_NAV_SEARCH,
		SAVE_NEW_COMMENT,
		;
		
	}
	
	public void doGet(
		HttpServletRequest request,
		HttpServletResponse response
	)
	throws IOException
	{
		processRequest(request, response);
	}
	
	public void doPost(
		HttpServletRequest request,
		HttpServletResponse response
	)
	throws IOException
	{
		processRequest(request, response);
	}
	
	private void processRequest(
		HttpServletRequest request,
		HttpServletResponse response
	)
	throws IOException
	{
		response.setContentType("text/xml");
		
		Operation operation = getOperationFromRequest(request);
		switch ( operation ) {
			case LOAD_INITIAL_BLOG_POSTS:
				executeLoadInitialBlogPosts(request, response);
				break;
			case LOAD_BY_NAV_SEARCH:
				executeLoadByNavSearch(request, response);
				break;
			case SAVE_NEW_COMMENT:
				executeSaveNewComment(request, response);
				break;
		}
	}
	
	private Operation getOperationFromRequest(HttpServletRequest request) {
		log.debug("Entering");
		
		String operationCode = request.getParameter("operation");
		
		Operation result = Operation.LOAD_INITIAL_BLOG_POSTS;
		if ( operationCode != null ) {
			try {
				result = Operation.valueOf(operationCode);
			} catch ( IllegalArgumentException e ) {
				log.warn("operation <{}> is invalid.  Using default instead.", operationCode);
			}
			
		}
		
		log.debug("Exiting with <{}>", result);
		return result;
	}
	
	private void executeLoadInitialBlogPosts(
		HttpServletRequest request,
		HttpServletResponse response
	)
	throws IOException
	{
		log.debug("Entering");
		
		PrintWriter out = response.getWriter();
		
		BlogPostService blogPostService = getBlogPostService(request);
		InitialBlogPostListResult blogPostListResult = blogPostService.loadInitialBlogPosts(
			getBlogPostCodeFromRequest(request),
			getCountFromRequest(request)
		);
		
		out.println("<initialBlogPostListResult blogPostCount=\"" + blogPostListResult.getBlogPostCount() + "\">");
		for ( BlogPost currBlogPost : blogPostListResult.getInitialBlogPostList() ) {
			outputBlogPost(out, currBlogPost);
		}
		out.println("</initialBlogPostListResult>");
		
		out.close();
		
		log.debug("Exiting");
	}
	
	private void executeLoadByNavSearch(
		HttpServletRequest request,
		HttpServletResponse response
	)
	throws IOException
	{
		log.debug("Entering");
		
		PrintWriter out = response.getWriter();
		
		BlogPostService blogPostService = getBlogPostService(request);
		Collection<BlogPost> blogPostList = blogPostService.loadActiveBlogPostsByNavSearch(getBlogPostNavSearchFromRequest(request));
		
		out.println("<blogPostList count=\"" + blogPostList.size() + "\">");
		for ( BlogPost currBlogPost : blogPostList ) {
			outputBlogPost(out, currBlogPost);
		}
		out.println("</blogPostList>");
		
		out.close();
		
		log.debug("Exiting");
	}
	
	private void executeSaveNewComment(
		HttpServletRequest request,
		HttpServletResponse response
	)
	throws IOException
	{
		log.debug("Entering");
		
		PrintWriter out = response.getWriter();
		
		BlogPostService blogPostService = getBlogPostService(request);
		NewCommentInput newCommentInput = getNewCommentInputFromRequest(request);
		SaveNewCommentResult saveNewCommentResult = blogPostService.saveNewComment(newCommentInput);
		
		out.print("<saveNewCommentResult");
		out.print(" success=\"" + saveNewCommentResult.getSuccess() + "\"");
		if ( !saveNewCommentResult.getSuccess() ) {
			out.print(" failureReason=\"" + saveNewCommentResult.getFailureReason().toString() + "\"");
		}
		out.println(">");
		if ( saveNewCommentResult.getSuccess() ) {
			outputBlogPostComment(out, saveNewCommentResult.getComment());
		}
		out.println("</saveNewCommentResult>");
		
		out.close();
		
		log.debug("Exiting");
	}
	
	private BlogPostService getBlogPostService(HttpServletRequest request) {
		log.debug("Entering");
		
		WebApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(request.getServletContext());
		BlogPostService result = context.getBean(BlogPostService.class);
		
		log.debug("Exiting");
		return result;
	}
	
	private BlogPostNavSearch getBlogPostNavSearchFromRequest(HttpServletRequest request) {
		log.debug("Entering");
		
		BlogPostNavSearch result = new BlogPostNavSearch();
		result.setBlogCode(getBlogPostCodeFromRequest(request));
		result.setStartPos(getStartPosFromRequest(request));;
		result.setCount(getCountFromRequest(request));
		
		if ( log.isDebugEnabled() ) {
			log.debug("Exiting with <{}>", result.debugString());
		}
		return result;
	}
	
	private String getBlogPostCodeFromRequest(HttpServletRequest request) {
		log.debug("Entering");
		
		String result = request.getParameter("blogCode");
		if ( result == null ) {
			result = DEFAULT_BLOG_POST_CODE;
		}
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private Integer getStartPosFromRequest(HttpServletRequest request) {
		log.debug("Entering");
		
		String startPosFromRequest = request.getParameter("startPos");
		
		Integer result = null;
		if ( startPosFromRequest != null ) {
			try {
				result = Integer.parseInt(startPosFromRequest);
				if ( result < 1 ) {
					result = 1;
					log.warn("startPos <{}> from request is out of bounds.  Using 1 instead.", startPosFromRequest);
				}
			} catch ( NumberFormatException e ) {
				result = 1;
				log.warn("Error parsing startPos <{}> from request.  Using 1 instead.", startPosFromRequest);
			}
		}
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private Integer getCountFromRequest(HttpServletRequest request) {
		log.debug("Entering");
		
		String countFromRequest = request.getParameter("count");
		
		Integer result = DEFAULT_BLOG_POSTS_PER_PAGE;
		if ( countFromRequest != null ) {
			try {
				result = Integer.parseInt(countFromRequest);
				if ( result < 0 ) {
					result = DEFAULT_BLOG_POSTS_PER_PAGE;
					log.warn("count <{}> from request is out of bounds.  Using default count instead.", countFromRequest);
				}
			} catch ( NumberFormatException e ) {
				result = DEFAULT_BLOG_POSTS_PER_PAGE;
				log.warn("Error parsing count <{}> from request.  Using default count instead.", countFromRequest);
			}
		}
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private void outputBlogPost(PrintWriter out, BlogPost blogPost) {
		log.debug("Entering with <{}>", blogPost);
		
		out.println("\t<blogPost>");
		out.println("\t\t<blogId>" + blogPost.getBlogId() + "</blogId>");
		out.println("\t\t<postId>" + blogPost.getPostId() + "</postId>");
		out.println("\t\t<postTitle>" + blogPost.getPostTitle() + "</postTitle>");
		out.println("\t\t<postText><![CDATA[" + blogPost.getPostText() + "]]></postText>");
		out.println("\t\t<postDate>" + blogPost.getPostDate().getTime() + "</postDate>");
		out.println("\t\t<posterUsername>" + blogPost.getPosterUsername() + "</posterUsername>");
		out.println("\t\t<allowCommentsFlag>" + blogPost.getAllowComments() + "</allowCommentsFlag>");
		out.println("\t\t<commentList count=\"" + blogPost.getCommentList().size() + "\">");
		for ( BlogPostComment currComment : blogPost.getCommentList() ) {
			outputBlogPostComment(out, currComment);
		}
		out.println("\t\t</commentList>");
		out.println("\t</blogPost>");
		
		log.debug("Exiting");
	}
	
	private void outputBlogPostComment(PrintWriter out, BlogPostComment comment) {
		log.debug("Entering with <{}>", comment);
		
		out.println("\t\t\t<comment>");
		out.println("\t\t\t\t<commentId>" + comment.getCommentId() + "</commentId>");
		out.println("\t\t\t\t<commentText><![CDATA[" + comment.getCommentText() + "]]></commentText>");
		out.println("\t\t\t\t<commentDate>" + comment.getCommentDate().getTime() + "</commentDate>");
		if ( comment.getCommenterUsername() != null ) {
			out.println("\t\t\t\t<commenterUsername>" + comment.getCommenterUsername() + "</commenterUsername>");
		}
		out.println("\t\t\t</comment>");
		
		log.debug("Exiting");
	}
	
	private NewCommentInput getNewCommentInputFromRequest(HttpServletRequest request) {
		log.debug("Entering");
		
		NewCommentInput result = new NewCommentInput(
			getBlogIdFromRequest(request),
			getPostIdFromRequest(request)
		);
		result.setCommentText(HtmlUtils.htmlEscape(request.getParameter("commentText")));
		result.setCommenterUsername(HtmlUtils.htmlEscape(request.getParameter("commenterUsername")));
		
		log.debug("Exiting");
		return result;
	}
	
	private Long getBlogIdFromRequest(HttpServletRequest request) {
		log.debug("Entering");
		
		String blogIdFromRequest = request.getParameter("blogId");
		
		Long result = null;
		if ( blogIdFromRequest != null ) {
			try {
				result = Long.parseLong(blogIdFromRequest);
			} catch ( NumberFormatException e ) {
				log.warn("Error parsing blogId <{}> from request", blogIdFromRequest);
			}
		}
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
	private Long getPostIdFromRequest(HttpServletRequest request) {
		log.debug("Entering");
		
		String postIdFromRequest = request.getParameter("postId");
		
		Long result = null;
		if ( postIdFromRequest != null ) {
			try {
				result = Long.parseLong(postIdFromRequest);
			} catch ( NumberFormatException e ) {
				log.warn("Error parsing postId <{}> from request", postIdFromRequest);
			}
		}
		
		log.debug("Exiting with result <{}>", result);
		return result;
	}
	
}
