
SELECT 'Creating foreign keys for table r3_blog_post' AS ' ';
ALTER TABLE r3_blog_post
	ADD CONSTRAINT r3fk_post_to_blog
	FOREIGN KEY r3fk_post_to_blog (
		blog_id
	)
	REFERENCES r3_blog (
		blog_id
	)
;


SELECT 'Creating foreign keys for table r3_blog_post_comment' AS ' ';
ALTER TABLE r3_blog_post_comment
	ADD CONSTRAINT r3fk_comment_to_blog_post
	FOREIGN KEY r3fk_comment_to_blog_post (
		blog_id,
		post_id
	)
	REFERENCES r3_blog_post (
		blog_id,
		post_id
	)
;

