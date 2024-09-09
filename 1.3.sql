-- Enrich your original 1.1 SELECT by creating a new column in the view that marks active & inactive customers based on whether they have ordered anything during the last 365 days.
SELECT 
  customer.CustomerID, 
  contact.FirstName, 
  contact.LastName, 
  CONCAT(contact.FirstName, ' ', contact.LastName) AS FullName,
  CONCAT(
    IFNULL(contact.title, 'Dear'),
    ' ',
    contact.LastName
  ) AS addressing_title,
  contact.EmailAddress,
  contact.Phone, customer.AccountNumber,
  customer.CustomerType,
  address.city,
  address.AddressLine1,
  address.AddressLine2,
  stateprovince.Name AS State,
  countryregion.Name AS Country,
  COUNT(salesorders.SalesOrderID) AS number_orders,
  ROUND(SUM(salesorders.TotalDue), 3) AS total_amount,
  salesorders.OrderDate AS date_last,
  IF(CAST(MAX(salesorders.OrderDate) AS DATE) >= DATE_SUB('2004-07-31', INTERVAL 365 DAY), 'Active', 'Inactive') AS customer_status -- Got the results for the customers that have ordered something  (active or inactive) since the last order, last order was done '2004-07-31', i checked the activity during 365 days. 
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
INNER JOIN 
  adwentureworks_db.salesorderheader AS salesorders
  ON  
    salesorders.CustomerID = customer.CustomerID
 INNER JOIN (
  SELECT 
    CustomerID,
    MAX(OrderDate) AS max_order_date
  FROM 
    adwentureworks_db.salesorderheader
  GROUP BY 
    CustomerID
) AS latest_order_date
ON 
  customer.CustomerID = latest_order_date.CustomerID
  AND salesorders.OrderDate = latest_order_date.max_order_date
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
  contact.Phone,
  salesorders.OrderDate
ORDER BY 
  customer.CustomerID DESC
  
LIMIT 500;