WITH weekly_retention AS (
  SELECT 
    DATE_TRUNC(subscription_start, WEEK(MONDAY)) AS subs_start_week,
    COUNT(user_pseudo_id) AS subscribers,
    COUNT(
      CASE 
        WHEN subscription_end IS NULL OR subscription_end >= DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 1 WEEK) 
        THEN user_pseudo_id 
      END
    ) AS week_1,
    COUNT(
      CASE 
        WHEN subscription_end IS NULL OR subscription_end >= DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 2 WEEK) 
        THEN user_pseudo_id 
      END
    ) AS week_2,
    COUNT(
      CASE 
        WHEN subscription_end IS NULL OR subscription_end >= DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 3 WEEK) 
        THEN user_pseudo_id 
      END
    ) AS week_3,
    COUNT(
      CASE 
        WHEN subscription_end IS NULL OR subscription_end >= DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 4 WEEK) 
        THEN user_pseudo_id 
      END
    ) AS week_4,
    COUNT(
      CASE 
        WHEN subscription_end IS NULL OR subscription_end >= DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 5 WEEK) 
        THEN user_pseudo_id 
      END
    ) AS week_5,
    COUNT(
      CASE 
        WHEN subscription_end IS NULL OR subscription_end >= DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 6 WEEK) 
        THEN user_pseudo_id 
      END
    ) AS week_6,
    COUNT(
      CASE 
        WHEN subscription_end IS NULL OR subscription_end >= DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 7 WEEK) 
        THEN user_pseudo_id 
      END
    ) AS week_7
  FROM 
    `tc-da-1.turing_data_analytics.subscriptions`
  GROUP BY 
    subs_start_week
)
SELECT 
  subs_start_week,
  subscribers,
  week_1,
  week_2,
  week_3,
  week_4,
  week_5,
  week_6,
  week_7
FROM 
  weekly_retention;