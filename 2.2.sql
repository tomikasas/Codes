-- Enrich 2.1 query with the cumulative_sum of the total amount with tax earned per country & region.

WITH Sales_CTE AS ( --used a cte here in to create a temp table for an easier aproach in my main SELECT clause
    SELECT 
        LAST_DAY(DATE(salesorder.orderdate)) AS Order_month, 
        salesterritory.CountryRegionCode AS CountryRegion,
        salesterritory.name AS Region,
        COUNT(salesorder.SalesOrderID) AS number_salesorders,
        COUNT(DISTINCT salesorder.customerID) AS number_customers,
        COUNT(DISTINCT salesorder.SalesPersonID) AS no_salesperson,
        ROUND(SUM(salesorder.TotalDue)) AS TOTAL,
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
SUM(TOTAL) OVER (PARTITION BY CountryRegion, Region ORDER BY Order_month) AS cumulative_sum -- used PARTITION to help me devide 'TotalDue' data into partitions based on both CountryRegion and Region, SUM() function then calculates the running total of 'TotalDue' within each partition, ordered by the 'TotalDue' date
FROM
Sales_CTE;