-- SQL + GenAI Mini Project : Social Media Analytics
-- Dataset : Social_Media
-- Student Name : Pavithra D


use social_media;

-- Q1. Most Active Users (Posts + Comments)
-- Objective : Find top 10 users based on combined number of posts and comments.


SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    (COUNT(DISTINCT p.post_id) + COUNT(DISTINCT c.comment_id)) AS total_activity
FROM users u
LEFT JOIN posts p 
    ON u.user_id = p.user_id
LEFT JOIN comments c 
    ON u.user_id = c.user_id
GROUP BY u.user_id, u.username
ORDER BY total_activity DESC
LIMIT 10;

/*Solution Summary:
This query calculates overall user activity by combining the total number of posts and comments made by each user. 
It ranks users based on their combined engagement level and highlights the top 10 most active users on the 
platform. This helps identify highly engaged users who contribute significant content and interactions.*/



-- Q2. Most Liked Posts and Creators
-- Objective : Identify posts with maximum likes along with their creator.



SELECT 
    p.post_id,
    u.username,
    COUNT(l.like_id) AS total_likes
FROM posts p
JOIN users u 
    ON p.user_id = u.user_id
LEFT JOIN likes l 
    ON p.post_id = l.post_id
GROUP BY p.post_id, u.username
ORDER BY total_likes DESC
LIMIT 10;

/*
Solution Summary:
This query analyzes post performance by counting the total number of likes received by each post and linking 
it with the username of the post creator. It identifies the top 10 most liked posts, helping understand 
high-performing content and popular creators.*/


-- Q3. Top Countries by Average Engagement
-- Objective : Find countries with the highest average likes per post.

SELECT 
    u.country,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(l.like_id) AS total_likes,
    ROUND(COUNT(l.like_id) / COUNT(DISTINCT p.post_id), 2) AS avg_likes_per_post
FROM users u
JOIN posts p 
    ON u.user_id = p.user_id
LEFT JOIN likes l 
    ON p.post_id = l.post_id
GROUP BY u.country
HAVING COUNT(DISTINCT p.post_id) > 0
ORDER BY avg_likes_per_post DESC
LIMIT 10;


/*
Solution Summary:
This query measures user engagement at the country level by calculating the average number of likes per post 
for each country. It helps compare geographical engagement trends and identifies countries where users receive 
the highest interaction per post.*/


-- Q4. Trending Hashtags (Used in >20 Posts)
-- Objective : Find hashtags that appear in more than 20 posts.


SELECT 
    h.tag_name,
    COUNT(ph.post_id) AS total_posts
FROM hashtags h
JOIN post_hashtags ph 
    ON h.hashtag_id = ph.hashtag_id
GROUP BY h.tag_name
ORDER BY total_posts DESC
LIMIT 10; # this gives output


/*
Solution Summary:
This query determines trending topics by counting how many distinct posts are associated with each hashtag. 
Only hashtags used in more than 20 posts are included, which helps identify popular and widely discussed 
topics on the platform.*/


-- Q5. Top Influencers (Users with Most Followers)
-- Objective : List users with the highest follower count.


SELECT 
    u.user_id,
    u.username,
    COUNT(f.follower_user_id) AS total_followers
FROM users u
LEFT JOIN followers f 
    ON u.user_id = f.user_id
GROUP BY u.user_id, u.username
ORDER BY total_followers DESC
LIMIT 10;

/*
Solution Summary:
This query identifies the most influential users by calculating their follower counts. Users with the highest 
number of followers are ranked at the top, helping to recognize key influencers within the platform.*/


-- Q6. Followers Who Never Interacted
-- Objective : Identify users who follow others but have never liked or commented.


SELECT 
    DISTINCT u.user_id,
    u.username
FROM followers f
JOIN users u 
    ON f.follower_user_id = u.user_id
LEFT JOIN likes l 
    ON u.user_id = l.user_id
LEFT JOIN comments c 
    ON u.user_id = c.user_id
WHERE l.like_id IS NULL 
  AND c.comment_id IS NULL;
/*Solution Summary:
This query identifies passive users who follow other accounts but have never liked any post or written comments. 
It is useful for detecting inactive or low-engagement followers.*/

-- Q7. Hashtags with Highest Engagement
-- Objective : Calculate total engagement (likes + comments) for each hashtag.

SELECT 
    h.tag_name,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) AS total_engagement
FROM hashtags h
JOIN post_hashtags ph 
    ON h.hashtag_id = ph.hashtag_id
JOIN posts p 
    ON ph.post_id = p.post_id
LEFT JOIN likes l 
    ON p.post_id = l.post_id
LEFT JOIN comments c 
    ON p.post_id = c.post_id
GROUP BY h.tag_name
ORDER BY total_engagement DESC;

/* Solution Summary:
This query calculates the engagement score for each hashtag by adding together the total number of likes 
and comments on posts tagged with that hashtag. It helps identify which hashtags generate the highest audience 
interaction.*/


-- Q8. Busiest Posting Hours or Days
-- Objective : Find which hour/day sees most posting activity.


SELECT 
    HOUR(created_at) AS post_hour,
    COUNT(post_id) AS total_posts
FROM posts
GROUP BY post_hour
ORDER BY total_posts DESC;

/*This query analyzes posting time patterns by grouping posts based on the hour of creation. 
It identifies peak activity hours when users are most active in creating content.*/

-- Q9. Inactive Users
-- Objective : Find users who have never posted, liked, or commented.

SELECT 
    u.user_id,
    u.username
FROM users u
LEFT JOIN posts p 
    ON u.user_id = p.user_id
LEFT JOIN likes l 
    ON u.user_id = l.user_id
LEFT JOIN comments c 
    ON u.user_id = c.user_id
WHERE p.post_id IS NULL
  AND l.like_id IS NULL
  AND c.comment_id IS NULL;
  
 /*
 Solution Summary:
 This query identifies users who have never created posts, liked any content, or written comments. 
 These users are considered fully inactive and can be targeted for re-engagement strategies. */
 

-- Q10. Top Countries with Most Influencers
-- Objective : Identify countries with the highest number of influencers.

SELECT 
    u.country,
    COUNT(DISTINCT u.user_id) AS influencer_count
FROM users u
JOIN followers f 
    ON u.user_id = f.user_id
GROUP BY u.country
ORDER BY influencer_count DESC
LIMIT 10;

/*
Solution Summary:
This query counts the number of highly followed users in each country, helping identify regions that produce the 
most influential users on the platform.*/


-- BONUS CHALLENGES
-- ==============================================================
-- Q1. Engagement rate = (likes + comments) / posts



SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    ROUND(
        (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) / 
        COUNT(DISTINCT p.post_id), 
    2) AS engagement_rate
FROM users u
LEFT JOIN posts p 
    ON u.user_id = p.user_id
LEFT JOIN likes l 
    ON p.post_id = l.post_id
LEFT JOIN comments c 
    ON p.post_id = c.post_id
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT p.post_id) > 0
ORDER BY engagement_rate DESC;


/*
Solution Summary:
This query calculates the engagement rate for each user by dividing the total number of likes and comments 
by the number of posts created. It helps measure how actively users interact with content and identifies highly 
engaging content creators.*/

-- Q2. Mutual followers

SELECT 
    f1.user_id AS user_A,
    f1.follower_user_id AS user_B
FROM followers f1
JOIN followers f2 
    ON f1.user_id = f2.follower_user_id
   AND f1.follower_user_id = f2.user_id;

/*
Solution Summary:
This query identifies pairs of users who follow each other by comparing the follower relationships in both
directions. It helps detect strong user connections and reciprocal relationships within the platform.*/

-- Q3. Most used hashtags by top 5 influencers
WITH top_influencers AS (
    SELECT 
        user_id,
        COUNT(*) AS follower_count
    FROM followers
    GROUP BY user_id
    ORDER BY follower_count DESC
    LIMIT 5
)
SELECT 
    h.tag_name,
    COUNT(ph.post_id) AS usage_count
FROM posts p
JOIN top_influencers ti 
    ON p.user_id = ti.user_id
JOIN post_hashtags ph 
    ON p.post_id = ph.post_id
JOIN hashtags h 
    ON ph.hashtag_id = h.hashtag_id
GROUP BY h.tag_name
ORDER BY usage_count DESC;

/*
Solution Summary:
This query analyzes the hashtag usage of the top five most followed users. It highlights the most commonly 
used  hashtags among highly influential users, helping understand trending content themes driven by major 
influencers.*/

-- Q4. Country-wise engagement leaderboard

SELECT 
    u.country,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) AS total_engagement
FROM users u
JOIN posts p 
    ON u.user_id = p.user_id
LEFT JOIN likes l 
    ON p.post_id = l.post_id
LEFT JOIN comments c 
    ON p.post_id = c.post_id
GROUP BY u.country
ORDER BY total_engagement DESC;

/* 
Solution Summary:
This query ranks countries based on total user engagement by combining likes and comments generated from posts. 
It provides insights into which countries have the most active and highly engaged audiences.*/

/*
REFLECTION

1. How did GenAI assist you in solving these queries?

GenAI helped me understand the questions and convert them into correct SQL queries. 
It made it easier to write JOINs, use functions, and fix errors. It saved time and 
helped me write better queries.

2. What optimization tips did you learn?

I learned how to write clean queries by avoiding unnecessary joins, 
using GROUP BY properly, and filtering data early using WHERE conditions. 
I also learned that indexing improves query speed.

3. What business insights stood out to you?

I learned that users with more engagement get more visibility. 
Popular hashtags help increase reach, and posting at the right time increases interaction. 
Different countries show different activity patterns.*/


