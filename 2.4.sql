-- Enrich 2.3 query by adding taxes on a country level:

-- As taxes can vary in country based on province, the needed column is ‘mean_tax_rate’ -> average tax rate in a country.
-- Also, as not all regions have data on taxes, you also want to be transparent and show the ‘perc_provinces_w_tax’ -> a column representing the percentage of provinces with available tax rates for each country (i.e. If US has 53 provinces, and 10 of them have tax rates, then for US it should show 0,19)


WITH 
  sales_data AS (
    SELECT 
      LAST_DAY(DATE(salesorder.orderdate)) AS Order_month,
      salesterritory.CountryRegionCode AS CountryRegion,
      salesterritory.name AS Region,
      COUNT(salesorder.SalesOrderID) AS number_salesorders,
      COUNT(DISTINCT salesorder.customerID) AS number_customers,
      COUNT(DISTINCT salesorder.SalesPersonID) AS no_salesperson,
      ROUND(SUM(salesorder.TotalDue)) AS TOTAL,
      RANK() OVER (PARTITION BY salesterritory.CountryRegionCode ORDER BY SUM(salesorder.TotalDue) DESC) AS sales_rank
    FROM 
      `adwentureworks_db.salesorderheader` AS salesorder
    LEFT JOIN 
      `adwentureworks_db.salesterritory` AS salesterritory
    ON 
      salesterritory.TerritoryID = salesorder.TerritoryID
    GROUP BY 
      Order_month, 
      salesterritory.CountryRegionCode, 
      Region
  ),
  cumulative_sales AS (
    SELECT 
      Order_month, 
      CountryRegion,
      Region,
      SUM(TOTAL) OVER (PARTITION BY CountryRegion, Region ORDER BY Order_month) AS cumulative_sum
    FROM 
      sales_data
  ),
  tax_data AS (
    SELECT 
      stateprovince.CountryRegionCode AS CountryRegionCode,
      COUNT(stateprovince.StateProvinceID) AS count_all,
      COUNT(staxrate.TaxRate) AS tax,
      ROUND(AVG(staxrate.TaxRate), 2) AS mean_tax_rate
    FROM 
      `adwentureworks_db.stateprovince` stateprovince
    LEFT JOIN 
      `adwentureworks_db.salestaxrate` staxrate
    ON 
      staxrate.stateprovinceid = stateprovince.stateprovinceid
    GROUP BY 
      stateprovince.CountryRegionCode
  ),
  percentage_tax AS (
    SELECT 
      CountryRegionCode,
      ROUND((tax / count_all), 2) AS perc_provinces_w_tax
    FROM 
      tax_data
  )
SELECT 
  sd.Order_month, 
  sd.CountryRegion,
  sd.Region,
  sd.number_salesorders,
  sd.number_customers,
  sd.no_salesperson,
  sd.TOTAL,
  sd.sales_rank,
  cs.cumulative_sum,
  td.CountryRegionCode,
  td.count_all,
  td.mean_tax_rate,
  pt.perc_provinces_w_tax
FROM 
  sales_data sd
JOIN 
  cumulative_sales cs 
  ON sd.Order_month = cs.Order_month 
  AND sd.CountryRegion = cs.CountryRegion 
  AND sd.Region = cs.Region
JOIN 
  tax_data td 
  ON sd.CountryRegion = td.CountryRegionCode
JOIN 
  percentage_tax pt 
  ON td.CountryRegionCode = pt.CountryRegionCode
WHERE 
  sd.CountryRegion = 'US'
ORDER BY 
  sd.sales_rank;