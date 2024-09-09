-- Business finds the original query valuable to analyze customers and now want to get the data from the first query for the top 200 customers with the highest total amount (with tax) who have not ordered for the last 365 days. How would you identify this segment?
SELECT 
  sub.CustomerID, 
  sub.FirstName, 
  sub.LastName, 
  CONCAT(sub.FirstName, ' ', sub.LastName) AS FullName,
  CONCAT(
    IFNULL(sub.title, 'Dear'),
    ' ',
    sub.LastName
  ) AS addressing_title,
  sub.EmailAddress,
  sub.Phone, 
  sub.AccountNumber,
  sub.CustomerType,
  sub.city,
  sub.AddressLine1,
  sub.AddressLine2,
  sub.State,
  sub.Country,
  sub.number_orders,
  sub.total_amount
FROM (
  SELECT 
    customer.CustomerID, 
    contact.FirstName, 
    contact.LastName, 
    contact.title,
    contact.EmailAddress,
    contact.Phone, 
    customer.AccountNumber,
    customer.CustomerType,
    address.city,
    address.AddressLine1,
    address.AddressLine2,
    stateprovince.Name AS State,
    countryregion.Name AS Country,
    COUNT(salesorders.SalesOrderID) AS number_orders,
    ROUND(SUM(salesorders.TotalDue), 3) AS total_amount,
    MAX(salesorders.OrderDate) AS date_last
  FROM 
    adwentureworks_db.customer AS customer
  INNER JOIN 
    adwentureworks_db.individual AS individual
    ON 
      customer.customerID = individual.CustomerID
  INNER JOIN
    adwentureworks_db.contact AS contact
    ON  
      contact.ContactId = individual.ContactID
  INNER JOIN 
    adwentureworks_db.customeraddress AS customeraddress
    ON  
      customeraddress.CustomerID = Customer.CustomerID
  INNER JOIN 
    adwentureworks_db.address AS address
    ON  
      address.AddressID = CustomerAddress.AddressID
  INNER JOIN 
    adwentureworks_db.stateprovince AS stateprovince
    ON  
      stateprovince.StateProvinceID = address.StateProvinceID
  INNER JOIN 
    adwentureworks_db.countryregion AS countryregion
    ON  
      countryregion.CountryRegionCode = stateprovince.CountryRegionCode
  LEFT JOIN 
    adwentureworks_db.salesorderheader AS salesorders
    ON  
      salesorders.CustomerID = customer.CustomerID
  GROUP BY
    customer.CustomerID, 
    contact.FirstName, 
    contact.LastName, 
    contact.title,
    address.city,
    address.AddressLine1,
    address.AddressLine2,
    stateprovince.Name,
    countryregion.Name,
    customer.AccountNumber,
    customer.CustomerType,
    contact.EmailAddress,
    contact.Phone
  HAVING
    MAX(salesorders.OrderDate) <= '2004-07-31' OR MAX(salesorders.OrderDate) IS NULL -- filtered the aggregate (MAX) value
) AS sub
ORDER BY 
  sub.total_amount DESC
LIMIT 200;