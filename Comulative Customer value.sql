WITH weeks AS (
    SELECT 
        DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS event_week,
        MIN(DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK)) OVER(PARTITION BY user_pseudo_id) AS registration_week,
        user_pseudo_id AS users,
        purchase_revenue_in_usd AS revenue
    FROM 
        `tc-da-1.turing_data_analytics.raw_events`
),
weekly_revenue AS (
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
)
SELECT 
registration_week,
    week_0 + week_1 AS cumulative_week_1,
    week_0 + week_1 + week_2 AS cumulative_week_2,
    week_0 + week_1 + week_2 + week_3 AS cumulative_week_3,
    week_0 + week_1 + week_2 + week_3 + week_4 AS cumulative_week_4,
    week_0 + week_1 + week_2 + week_3 + week_4 + week_5 AS cumulative_week_5,
    week_0 + week_1 + week_2 + week_3 + week_4 + week_5 + week_6 AS cumulative_week_6,
    week_0 + week_1 + week_2 + week_3 + week_4 + week_5 + week_6 + week_7 AS cumulative_week_7,
    week_0 + week_1 + week_2 + week_3 + week_4 + week_5 + week_6 + week_7 + week_8 AS cumulative_week_8,
    week_0 + week_1 + week_2 + week_3 + week_4 + week_5 + week_6 + week_7 + week_8 + week_9 AS cumulative_week_9,
    week_0 + week_1 + week_2 + week_3 + week_4 + week_5 + week_6 + week_7 + week_8 + week_9 + week_10 AS cumulative_week_10,
    week_0 + week_1 + week_2 + week_3 + week_4 + week_5 + week_6 + week_7 + week_8 + week_9 + week_10 + week_11 AS cumulative_week_11,
    week_0 + week_1 + week_2 + week_3 + week_4 + week_5 + week_6 + week_7 + week_8 + week_9 + week_10 + week_11 + week_12 AS cumulative_week_12
    FROM
    weekly_revenue