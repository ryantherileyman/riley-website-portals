
SELECT 'Creating table r3_blog' AS ' ';
CREATE TABLE r3_blog (
	blog_id INTEGER NOT NULL AUTO_INCREMENT,
	blog_code VARCHAR(16) NOT NULL,
	def_allow_comments_flag CHAR(1) NOT NULL,
	internal_comment TEXT,
	CONSTRAINT r3pk_blog PRIMARY KEY (
		blog_id
	),
	CONSTRAINT r3ak_blog_code UNIQUE INDEX r3ak_blog_code (
		blog_code
	)
)
ENGINE=InnoDB
;

SELECT 'Creating table r3_blog_post' AS ' ';
CREATE TABLE r3_blog_post (
	blog_id INTEGER NOT NULL,
	post_id INTEGER NOT NULL,
	post_title TEXT NOT NULL,
	post_text MEDIUMTEXT NOT NULL,
	post_date DATETIME NOT NULL,
	poster_username VARCHAR(30) NOT NULL,
	active_flag CHAR(1) NOT NULL,
	allow_comments_flag CHAR(1) NOT NULL,
	last_update_date DATETIME,
	last_update_username VARCHAR(30),
	CONSTRAINT r3pk_blogpost PRIMARY KEY (
		blog_id,
		post_id
	),
	INDEX r3idx_blogpost_date (
		post_date
	)
)
ENGINE=InnoDB
;

SELECT 'Creating table r3_blog_post_comment' AS ' ';
CREATE TABLE r3_blog_post_comment (
	blog_id INTEGER NOT NULL,
	post_id INTEGER NOT NULL,
	comment_id INTEGER NOT NULL,
	comment_text TEXT NOT NULL,
	comment_date DATETIME NOT NULL,
	commenter_username VARCHAR(30),
	active_flag CHAR(1) NOT NULL,
	CONSTRAINT r3pk_blogpostcomment PRIMARY KEY (
		blog_id,
		post_id,
		comment_id
	)
)
ENGINE=InnoDB
;
