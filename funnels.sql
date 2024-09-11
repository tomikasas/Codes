WITH unique_events AS (
    SELECT 
        user_pseudo_id,
        event_name,
        MAX(event_timestamp) AS max_event_timestamp
    FROM `tc-da-1.turing_data_analytics.raw_events`
    GROUP BY user_pseudo_id, event_name
),
latest_events AS (
    SELECT 
        re.*
    FROM `tc-da-1.turing_data_analytics.raw_events` AS re
    JOIN unique_events AS ue
        ON re.user_pseudo_id = ue.user_pseudo_id
        AND re.event_name = ue.event_name
        AND re.event_timestamp = ue.max_event_timestamp
),
filtered_events AS (
    SELECT *
    FROM latest_events
    WHERE event_name IN ('session_start', 'view_item', 'add_to_cart','add_payment_info', 'purchase', 'view_promotion')
),
country_event_counts AS (
    SELECT 
        country,
        COUNT(CASE WHEN event_name = 'session_start' THEN 1 END) AS session_start_count,
        COUNT(CASE WHEN event_name = 'view_item' THEN 1 END) AS view_item_count,
        COUNT(CASE WHEN event_name = 'add_to_cart' THEN 1 END) AS add_to_cart_count,
        COUNT(CASE WHEN event_name = 'add_payment_info' THEN 1 END) AS add_payment_info_count,
        COUNT(CASE WHEN event_name = 'add_shipping_info' THEN 1 END) AS add_shipping_info_count,
        COUNT(CASE WHEN event_name = 'view_promotion' THEN 1 END) AS view_promotion_count,
        COUNT(CASE WHEN event_name = 'purchase' THEN 1 END) AS purchase_count
    FROM filtered_events
    GROUP BY country
)
SELECT 
    country,
    session_start_count,
    ROUND((session_start_count - view_promotion_count) / session_start_count * 100, 2) AS dropoff_prct1,
    view_promotion_count,
    ROUND((session_start_count - view_item_count) / session_start_count * 100, 2) AS dropoff_prct2,
    view_item_count,
    ROUND((session_start_count - add_to_cart_count) / session_start_count * 100, 2) AS dropoff_prct3,
    add_to_cart_count,
    ROUND((session_start_count - add_payment_info_count) / session_start_count * 100, 2) AS dropoff_prct4,
    add_payment_info_count,
    ROUND((session_start_count - purchase_count) / session_start_count * 100, 2) AS dropoff_prct5,
    purchase_count
FROM country_event_counts
ORDER BY session_start_count DESC
LIMIT 5;
