
SELECT 'Creating table r3_blog_tag_type_category' AS ' ';
CREATE TABLE r3_blog_tag_type_category (
	tag_type_category_id INTEGER NOT NULL AUTO_INCREMENT,
	tag_type_category_name VARCHAR(64) NOT NULL,
	active_flag CHAR(1) NOT NULL,
	CONSTRAINT r3pk_blogtagtypecategory PRIMARY KEY (
		tag_type_category_id
	)
)
ENGINE=InnoDB
;

SELECT 'Creating table r3_blog_tag_type' AS ' ';
CREATE TABLE r3_blog_tag_type (
	tag_type_id INTEGER NOT NULL AUTO_INCREMENT,
	tag_type_category_id INTEGER,
	tag_type_name VARCHAR(64) NOT NULL,
	active_flag CHAR(1) NOT NULL,
	CONSTRAINT r3pk_blogtagtype PRIMARY KEY (
		tag_type_id
	),
	INDEX r3idx_blogtagtype_name (
		tag_type_name
	)
)
ENGINE=InnoDB
;

SELECT 'Creating table r3_blog_post_tag' AS ' ';
CREATE TABLE r3_blog_post_tag (
	blog_id INTEGER NOT NULL,
	post_id INTEGER NOT NULL,
	tag_type_id INTEGER NOT NULL,
	active_flag CHAR(1) NOT NULL,
	tag_order_num INTEGER,
	CONSTRAINT r3pk_blogposttag PRIMARY KEY (
		blog_id,
		post_id,
		tag_type_id
	)
)
ENGINE=InnoDB
;

