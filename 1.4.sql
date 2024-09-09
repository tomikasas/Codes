-- Business would like to extract data on all active customers from North America. Only customers that have either ordered no less than 2500 in total amount (with Tax) or ordered 5 + times should be presented.
SELECT *
FROM (
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
        contact.Phone, 
        customer.AccountNumber,
        customer.CustomerType,
        address.city,
        REGEXP_EXTRACT(address.AddressLine1, r'(\d+)') AS address_no, --extracts the numeric part (address number) from address.AddressLine1.
        REGEXP_REPLACE(address.AddressLine1, r'(\d+)', '') AS Address_st, -- REGEXP_REPLACE(address.AddressLine1, r'(\d+)', '') removes the numeric part from address.AddressLine1, leaving only the street.
        address.AddressLine2,
        stateprovince.Name AS State,
        countryregion.Name AS Country,
        COUNT(salesorders.SalesOrderID) AS number_orders,
        ROUND(SUM(salesorders.TotalDue), 3) AS total_amount,
        Max(salesorders.OrderDate) AS last_order,
        IF(CAST(MAX(salesorders.OrderDate) AS DATE) >= DATE_SUB('2004-07-31', INTERVAL 365 DAY), 'Active', 'Inactive') AS customer_status
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
) AS subquery
WHERE
    customer_status = 'Active'
    AND Country IN ('United States','Canada') AND total_amount >= 2500 OR -- filter out 2 conditions. Both of these countries belong to North America region
    Country IN ('United States','Canada') AND number_orders > 5
ORDER BY
Country,State,last_order