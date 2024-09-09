-- Create a query of monthly sales numbers in each Country & region. Include in the query a number of orders, customers and sales persons in each month with a total amount with tax earned. Sales numbers from all types of customers are required.

SELECT 
  LAST_DAY(DATE(salesorder.orderdate)) AS Order_month,
  salesterritory.CountryRegionCode,
  salesterritory.name AS Region,
  COUNT(salesorder.SalesOrderID) AS number_salesorders,
  COUNT(DISTINCT salesorder.customerID) AS number_customers,
  COUNT(DISTINCT salesorder.SalesPersonID) AS no_salesperson,
  ROUND(SUM(salesorder.TotalDue), 2) AS TOTAL
FROM 
  `adwentureworks_db.salesorderheader` AS salesorder
LEFT JOIN 
  `adwentureworks_db.salesterritory` AS salesterritory
ON 
  salesterritory.TerritoryID = salesorder.TerritoryID
GROUP BY 
  Order_month, 
  salesterritory.CountryRegionCode, 
  Region;