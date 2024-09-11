WITH sales AS (
  SELECT 
    promotion,
    location_id,
    ROUND(SUM(sales_in_thousands), 2) AS total_sales
  FROM 
    tc-da-1.turing_data_analytics.wa_marketing_campaign
  GROUP BY 
    promotion, location_id
)
SELECT 
  promotion,
  COUNT(*) AS num_locations,
  ROUND(AVG(total_sales), 2) AS average_sales,
  ROUND(SUM(total_sales), 2) AS total_sales
FROM 
  sales
GROUP BY 
  promotion;
