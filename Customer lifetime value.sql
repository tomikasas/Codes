WITH weeks AS (
    SELECT 
        DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS event_week,
        MIN(DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK)) OVER(PARTITION BY user_pseudo_id) AS registration_week,
        user_pseudo_id AS users,
        purchase_revenue_in_usd AS revenue
    FROM 
        `tc-da-1.turing_data_analytics.raw_events`
)
SELECT 
registration_week,
SUM(CASE 
    WHEN registration_week = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_0,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 1 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_1,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 2 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_2,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 3 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_3,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 4 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_4,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 5 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_5,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 6 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_6,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 7 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_7,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 8 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_8,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 9 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_9,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 10 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_10,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 11 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_11,

SUM(CASE 
    WHEN DATE_ADD(registration_week, INTERVAL 12 WEEK) = event_week THEN revenue 
    ELSE 0 
END) / COUNT(DISTINCT users) AS week_12
FROM 
    weeks
    group by registration_week
    order by registration_week