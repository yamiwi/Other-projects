USE data_scientist_project;

SELECT * FROM student_certificates LIMIT 100;
SELECT * FROM student_info LIMIT 100;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM student_purchases LIMIT 1000;

DROP VIEW IF EXISTS purchases_info;
CREATE VIEW purchases_info AS 
	WITH student_subscription AS (
			SELECT purchase_id, student_id, 
				CASE plan_id 
					WHEN 0 THEN 'Monthly' 
					WHEN 1 THEN 'Quarterly' 
					WHEN 2 THEN 'Annual' 
					WHEN 3 THEN 'Lifetime' END AS plan, 
				date_purchased AS date_start, 
				--  If date_refunded is not null then subscription plan was refunded and we have to keep this date, else calculate subscription plan end date by adding corresponding time period to subscription plan start date.
				IF(date_refunded IS NOT NULL, date_refunded, CASE plan_id 
																WHEN 0 THEN ADDDATE(date_purchased, INTERVAL 1 MONTH) 
																WHEN 1 THEN ADDDATE(date_purchased, INTERVAL 3 MONTH) 
																WHEN 2 THEN ADDDATE(date_purchased, INTERVAL 12 MONTH) 
																WHEN 3 THEN ADDDATE(date_purchased, INTERVAL 500 YEAR) END) AS date_end
			FROM student_purchases),
		relevant_user_subscription AS (
			SELECT *,
				-- If subscription plan falls inside Q2 2021 (1 April - 30 June (inclusive))
				IF(date_start <= '2021-06-30' AND date_end >= '2021-04-01', 1, 0) AS paid_q2_2021,
				-- If subscription plan falls inside Q2 2022 (1 April - 30 June (inclusive))
				IF(date_start <= '2022-06-30' AND date_end >= '2022-04-01', 1, 0) AS paid_q2_2022
			FROM student_subscription) 
	SELECT * FROM relevant_user_subscription;

SELECT * FROM purchases_info;
    
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   
    
SELECT * FROM student_video_watched LIMIT 100;

-- Student who watched a lecture in Q2 2021
SELECT student_id, ROUND(SUM(seconds_watched)/60, 2) AS minutes_watched
FROM student_video_watched
WHERE date_watched BETWEEN '2021-04-01' AND '2021-06-30'
GROUP BY student_id;

-- Student who watched a lecture in Q2 2022
SELECT student_id, ROUND(SUM(seconds_watched)/60, 2) AS minutes_watched
FROM student_video_watched
WHERE date_watched BETWEEN '2022-04-01' AND '2022-06-30'
GROUP BY student_id;    

-- Students engaged in Q2 2021 who haven’t had a paid subscription in Q2 2021 (minutes_watched_2021_paid_0.csv)
with cte as (
	SELECT student_id, ROUND(SUM(seconds_watched)/60, 2) AS minutes_watched
	FROM student_video_watched
	WHERE date_watched BETWEEN '2021-04-01' AND '2021-06-30' 
	GROUP BY student_id
)
SELECT student_id, MAX(minutes_watched) AS minutes_watched, MAX(COALESCE(paid_q2_2021, 0)) AS paid_q2_2021
FROM cte a
	LEFT JOIN purchases_info b USING(student_id)
GROUP BY student_id
HAVING MAX(COALESCE(paid_q2_2021, 0)) = 0;

-- Students engaged in Q2 2021 who have been paid subscribers in Q2 2021 (minutes_watched_2021_paid_1.csv)
with cte as (
	SELECT student_id, ROUND(SUM(seconds_watched)/60, 2) AS minutes_watched
	FROM student_video_watched
	WHERE date_watched BETWEEN '2021-04-01' AND '2021-06-30' 
	GROUP BY student_id
)
SELECT student_id, MAX(minutes_watched) AS minutes_watched, MAX(COALESCE(paid_q2_2021, 0)) AS paid_q2_2021
FROM cte a
	LEFT JOIN purchases_info b USING(student_id)
GROUP BY student_id
HAVING MAX(COALESCE(paid_q2_2021, 0)) = 1;

-- Students engaged in Q2 2022 who haven’t had a paid subscription in Q2 2022 (minutes_watched_2022_paid_0.csv)
with cte as (
	SELECT student_id, ROUND(SUM(seconds_watched)/60, 2) AS minutes_watched
	FROM student_video_watched
	WHERE date_watched BETWEEN '2022-04-01' AND '2022-06-30' 
	GROUP BY student_id
)
SELECT student_id, MAX(minutes_watched) AS minutes_watched, MAX(COALESCE(paid_q2_2022, 0)) AS paid_q2_2022
FROM cte a
	LEFT JOIN purchases_info b USING(student_id)
GROUP BY student_id
HAVING MAX(COALESCE(paid_q2_2022, 0)) = 0;

-- Students engaged in Q2 2022 who have been paid subscribers in Q2 2022 (minutes_watched_2022_paid_1.csv)
with cte as (
	SELECT student_id, ROUND(SUM(seconds_watched)/60, 2) AS minutes_watched
	FROM student_video_watched
	WHERE date_watched BETWEEN '2022-04-01' AND '2022-06-30' 
	GROUP BY student_id
)
SELECT student_id, MAX(minutes_watched) AS minutes_watched, MAX(COALESCE(paid_q2_2022, 0)) AS paid_q2_2022
FROM cte a
	LEFT JOIN purchases_info b USING(student_id)
GROUP BY student_id
HAVING MAX(COALESCE(paid_q2_2022, 0)) = 1;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Retrieve information about the certificates issued and minutes watched by a student, consider only those students who have received certificate. (certificates_and_minutes.csv) 
SELECT student_id, 
	COUNT(DISTINCT certificate_id) AS certificates_issued, 
    ROUND(SUM(COALESCE(seconds_watched, 0))/60, 2) AS minutes_watched 
FROM student_certificates 
	LEFT JOIN student_video_watched USING(student_id)
GROUP BY student_id;