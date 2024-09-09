-- Enrich 2.2 query by adding ‘sales_rank’ column that ranks rows from best to worst for each country based on total amount with tax earned each month. I.e. the month where the (US, Southwest) region made the highest total amount with tax earned will be ranked 1 for that region and vice versa.

WITH Sales_CTE AS (
    SELECT 
        LAST_DAY(DATE(salesorder.orderdate)) AS Order_month, 
        salesterritory.CountryRegionCode AS CountryRegion,
        salesterritory.name AS Region,
        COUNT(salesorder.SalesOrderID) AS number_salesorders,
        COUNT(DISTINCT salesorder.customerID) AS number_customers,
        COUNT(DISTINCT salesorder.SalesPersonID) AS no_salesperson,
        ROUND(SUM(salesorder.TotalDue)) AS TOTAL,
        RANK() OVER (PARTITION BY salesterritory.CountryRegionCode ORDER BY SUM(salesorder.TotalDue) DESC) AS sales_rank, -- [ranks rows from best to worst] this was made possible because of DESC and of course RANK(); [for each country] helped me devide 'TotalDue' data into partitions based on CountryRegion; [total amount with tax earned each month] this was done by ORDER BY clause
    FROM
        `adwentureworks_db.salesorderheader` AS salesorder 
    LEFT JOIN 
        `adwentureworks_db.salesterritory` AS salesterritory
        ON
        salesterritory.TerritoryID = salesorder.TerritoryID
    GROUP BY 
        Order_month, salesterritory.CountryRegionCode, Region
)
SELECT 
Order_month, 
CountryRegion,
Region,
number_salesorders,
number_customers,
no_salesperson,
TOTAL,
sales_rank,
ROUND(SUM(TOTAL) OVER (PARTITION BY CountryRegion, Region ORDER BY Order_month)) AS cumulative_sum 
FROM
Sales_CTE
WHERE 
Region = 'France'
ORDER BY 
sales_rank;