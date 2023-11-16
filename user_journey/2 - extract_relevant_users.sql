USE user_journey_data;

SELECT * FROM front_interactions LIMIT 1000;
SELECT * FROM front_visitors LIMIT 1000;
SELECT * FROM student_purchases LIMIT 1000;

# CREATE INDEX users ON student_purchases(user_id);
# CREATE INDEX users ON front_visitors(user_id);
# CREATE INDEX users ON front_interactions(visitor_id);

-- The idea of this project is to analyze the sequence of pages visited leading to first purchase.
-- In other words we should extract the user journey of only those users that have purchased a subscription plan.
-- In addition we should only consider users that made their first purchase between 1 January 2023 and 31 March 2023 (inclusive).

-- Consider all paying customers that purchased a subscription plan for the first time between January 1 and March 31 (inclusive), 2023.
-- Select all users with first purchase between this time period
with users_relevant_to_time_period AS ( 
			SELECT user_id, MIN(date_purchased) AS first_purchase_date
			FROM student_purchases
			WHERE purchase_price != 0 AND user_id != 0 -- Eliminate test records 
			GROUP BY user_id
			HAVING MIN(date_purchased) BETWEEN '2023-01-01' AND '2023-03-31'
        ),
        -- Combine 3 tables into a single one
        relevant_data AS ( 
			SELECT front_visitors.user_id, front_interactions.session_id, front_interactions.event_source_url, front_interactions.event_destination_url 
			FROM users_relevant_to_time_period
				INNER JOIN front_visitors USING(user_id)
                -- The analysis is based on the pages a user visited before purchasing for the first time so there is no need to analyze subsequent actions
                -- Joining by event_date <= first_purchase_date is to eliminate all subsequent records after the first purchase
				INNER JOIN front_interactions ON front_visitors.visitor_id = front_interactions.visitor_id AND front_interactions.event_date <= users_relevant_to_time_period.first_purchase_date
		),
        -- Extract subscription type for every user using regexp since we have only 3 types of subscriptions 
        subscription_type AS ( 
			SELECT user_id, MAX(REGEXP_SUBSTR(event_source_url, 'annual|monthly|quarterly')) AS sub_type 
            FROM relevant_data
            GROUP BY user_id
		)
        -- Select all the information required from these CTE 
        select user_id, session_id, sub_type AS subscription_type,
			GROUP_CONCAT( -- Concat all pairs of actions into a single string for each session
				CONCAT( -- Make pairs of actions made on each page 
					CASE IF(INSTR(SUBSTRING_INDEX(event_source_url, '/', 5), 'coupon'), 'coupon',  SUBSTRING_INDEX(SUBSTRING_INDEX(event_source_url, '/', 4), '/', -1)) WHEN '' THEN 'Homepage' WHEN 'login' THEN 'Log in' WHEN 'signup' THEN 'Sign up' 
																							 WHEN 'resources-center' THEN 'Resources center' WHEN 'courses' THEN 'Courses' WHEN 'career-tracks' THEN 'Career tracks' 
                                                                                             WHEN 'upcoming-courses' THEN 'Upcoming courses' WHEN 'career-track-certificate' THEN 'Career track certificate' WHEN 'course_certificate' THEN 'Course certificate' 
                                                                                             WHEN 'success-stories' THEN 'Success stories' WHEN 'blog' THEN 'Blog' WHEN 'pricing' THEN 'Pricing' 
                                                                                             WHEN 'about-us' THEN 'About us' WHEN 'instructors' THEN 'Instructors' WHEN 'coupon' THEN 'Coupon' 
                                                                                             WHEN 'checkout' THEN 'Checkout' ELSE 'Other' END, 
                    '-', -- CONCAT SEPARATOR
					CASE IF(INSTR(SUBSTRING_INDEX(event_destination_url, '/', 5), 'coupon'), 'coupon',  SUBSTRING_INDEX(SUBSTRING_INDEX(event_destination_url, '/', 4), '/', -1)) WHEN '' THEN 'Homepage' WHEN 'login' THEN 'Log in' WHEN 'signup' THEN 'Sign up' 
																							 WHEN 'resources-center' THEN 'Resources center' WHEN 'courses' THEN 'Courses' WHEN 'career-tracks' THEN 'Career tracks' 
                                                                                             WHEN 'upcoming-courses' THEN 'Upcoming courses' WHEN 'career-track-certificate' THEN 'Career track certificate' WHEN 'course_certificate' THEN 'Course certificate' 
                                                                                             WHEN 'success-stories' THEN 'Success stories' WHEN 'blog' THEN 'Blog' WHEN 'pricing' THEN 'Pricing' 
                                                                                             WHEN 'about-us' THEN 'About us' WHEN 'instructors' THEN 'Instructors' WHEN 'coupon' THEN 'Coupon' 
                                                                                             WHEN 'checkout' THEN 'Checkout' ELSE 'Other' END
					) 
				SEPARATOR '-' -- GROUP CONCAT SEPARATOR
				) AS user_journey 
        FROM relevant_data
			INNER JOIN (SELECT * FROM subscription_type WHERE sub_type IS NOT NULL) q1 USING(user_id) -- Add subscription types to this dataset
        GROUP BY user_id, session_id
        ORDER BY 1, 2;
        

        
        
        
        
        
        
        


