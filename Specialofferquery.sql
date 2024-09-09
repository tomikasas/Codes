SELECT DISTINCT
  sh.SalesOrderID AS sales_id, 
  sh.OrderDate AS Order_date,
  sh.DueDate AS due_date,
  sh.CustomerID AS customer_id,
  sh.SalesPersonID AS sales_person_id,
  sh.TotalDue AS total_due,
  MAX(so.DiscountPct) AS DiscountPct,
  MAX(sop.SpecialOfferID) AS specialofferID,
  MAX(so.description) AS description,
  MAX(so.type) AS type,
  MAX(so.Category) AS category
FROM adwentureworks_db.salesorderheader AS sh
  LEFT JOIN adwentureworks_db.salesorderdetail AS sd 
    ON sh.SalesOrderID = sd.SalesOrderID
  LEFT JOIN adwentureworks_db.specialofferproduct AS sop 
    ON sd.ProductID = sop.ProductID
  LEFT JOIN adwentureworks_db.specialoffer AS so 
    ON so.SpecialOfferID = sop.SpecialOfferID
WHERE so.DiscountPct > 0
GROUP BY 
  sh.SalesOrderID, 
  sh.OrderDate,
  sh.DueDate,
  sh.CustomerID,
  sh.SalesPersonID,
  sh.TotalDue;