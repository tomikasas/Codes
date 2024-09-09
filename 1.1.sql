-- You’ve been tasked to create a detailed overview of all individual customers (these are defined by customerType = ‘I’ and/or stored in an individual table). Write a query that provides: Identity information : CustomerId, Firstname, Last Name, FullName (First Name & Last Name).An Extra column called addressing_title i.e. (Mr. Achong), if the title is missing - Dear Achong. Contact information : Email, phone, account number, CustomerType. Location information : City, State & Country, address. Sales: number of orders, total amount (with Tax), date of the last order.
SELECT 
  customer.CustomerID, 
  contact.FirstName, 
  contact.LastName, 
  CONCAT(contact.FirstName, ' ', contact.LastName) AS FullName, 
  CONCAT(
    IFNULL(contact.title, 'Dear'), -- if the title was missing [NULL] then it would be dear rather than NULL
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
  Max(salesorders.OrderDate) AS last_order
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
  total_amount
  LIMIT 200;