
-- Target blog will have 3 active posts, 1 cancelled post
INSERT INTO r3_blog (
	blog_id,
	blog_code,
	def_allow_comments_flag,
	internal_comment
) VALUES (
	-1,
	'ZTESTZ_1',
	'Y',
	NULL
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
	-1,
	1,
	'Test Post Title',
	'Test Post Text',
	'2015-04-10 08:20:30',
	'Test Poster',
	'Y',
	'N',
	'2015-04-10 08:40:10',
	'Test Updater'
);

INSERT INTO r3_blog_post_comment (
	blog_id,
	post_id,
	comment_id,
	comment_text,
	comment_date,
	commenter_username,
	active_flag
) VALUES (
	-1,
	1,
	1,
	'Sample comment for Test Post Title',
	'2015-04-10 09:00:30',
	NULL,
	'Y'
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
	-1,
	2,
	'Test Cancelled Post',
	'Cancelled Post Text',
	'2015-04-11 10:20:30',
	'Test Canceller',
	'N',
	'Y',
	'2015-04-11 10:20:30',
	'Test Canceller'
);

INSERT INTO r3_blog_post_comment (
	blog_id,
	post_id,
	comment_id,
	comment_text,
	comment_date,
	commenter_username,
	active_flag
) VALUES (
	-1,
	2,
	1,
	'Sample comment for cancelled post',
	'2015-04-12 09:00:30',
	NULL,
	'Y'
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
	-1,
	3,
	'Test Last Post',
	'This post should be last',
	'2015-04-09 20:10:40',
	'Test Last',
	'Y',
	'Y',
	'2015-04-09 20:10:40',
	'Test Last'
);

INSERT INTO r3_blog_post_comment (
	blog_id,
	post_id,
	comment_id,
	comment_text,
	comment_date,
	commenter_username,
	active_flag
) VALUES (
	-1,
	3,
	1,
	'Sample comment 1 for Test Last Post',
	'2015-04-09 21:12:00',
	'Commenter',
	'Y'
);

INSERT INTO r3_blog_post_comment (
	blog_id,
	post_id,
	comment_id,
	comment_text,
	comment_date,
	commenter_username,
	active_flag
) VALUES (
	-1,
	3,
	2,
	'ZOMG your post SUXXORZ!',
	'2015-04-09 22:05:00',
	NULL,
	'N'
);

INSERT INTO r3_blog_post_comment (
	blog_id,
	post_id,
	comment_id,
	comment_text,
	comment_date,
	commenter_username,
	active_flag
) VALUES (
	-1,
	3,
	3,
	'That anonymous comment was uncalled for!',
	'2015-04-10 08:03:00',
	'Jesus Christ',
	'Y'
);

INSERT INTO r3_blog_post_comment (
	blog_id,
	post_id,
	comment_id,
	comment_text,
	comment_date,
	commenter_username,
	active_flag
) VALUES (
	-1,
	3,
	4,
	'You deleted his comment, but that makes my last comment look foolish.  You\'re making Jesus look foolish!',
	'2015-04-10 10:45:22',
	'Jesus Christ',
	'Y'
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
	-1,
	4,
	'Test First Post',
	'This post should be first',
	'2015-04-12 09:05:11',
	'Test First',
	'Y',
	'Y',
	'2015-04-12 09:05:11',
	'Test First'
);

-- Additional blog will have 1 active post
INSERT INTO r3_blog (
	blog_id,
	blog_code,
	def_allow_comments_flag,
	internal_comment
) VALUES (
	-2,
	'ZTESTZ_2',
	'Y',
	NULL
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
	-2,
	1,
	'Blog 2 Post',
	'This post should not be returned',
	'2015-04-10 07:05:00',
	'Other Blogger',
	'Y',
	'Y',
	'2015-04-10 07:05:00',
	'Other Blogger'
);

INSERT INTO r3_blog_post_comment (
	blog_id,
	post_id,
	comment_id,
	comment_text,
	comment_date,
	commenter_username,
	active_flag
) VALUES (
	-2,
	1,
	1,
	'This comment should not be returned',
	'2015-04-10 09:00:30',
	NULL,
	'Y'
);


-- A test blog with no comments
INSERT INTO r3_blog (
	blog_id,
	blog_code,
	def_allow_comments_flag,
	internal_comment
) VALUES (
	-3,
	'ZTESTZ_3',
	'Y',
	NULL
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
	-3,
	1,
	'Ghost Town',
	'Nobody\'s going to comment',
	'2015-05-09 12:45:00',
	'Lonely Blogger',
	'Y',
	'Y',
	'2015-04-10 12:45:00',
	'Lonely Blogger'
);
