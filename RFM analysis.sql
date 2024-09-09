WITH t0 AS(
SELECT
CustomerID,
Country,
InvoiceDate,
InvoiceNo,
UnitPrice,
Quantity
FROM  `tc-da-1.turing_data_analytics.rfm`
WHERE CustomerID IS NOT NULL
AND Quantity > 0
AND UnitPrice > 0 
),
t1 AS (
    SELECT  
    CustomerID,
    Country,
    MAX(InvoiceDate) AS last_purchase_date,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    round(SUM(UnitPrice * quantity),2) AS monetary 
    FROM t0
    WHERE InvoiceDate BETWEEN '2010-12-01' AND '2011-12-01'
    GROUP BY CustomerID, Country
    
),
t2 AS (
    SELECT *,
           DATE_DIFF(reference_date, last_purchase_date, DAY) AS recency
    FROM (
        SELECT *,
                DATE_ADD(MAX(last_purchase_date) OVER (), INTERVAL 1 DAY) AS reference_date
        FROM t1
    )
),
t3 AS (
SELECT 
    a.*,
    b.percentiles[offset(25)] AS m25, 
    b.percentiles[offset(50)] AS m50,
    b.percentiles[offset(75)] AS m75,
    b.percentiles[offset(100)] AS m100,
    c.percentiles[offset(25)] AS f25, 
    c.percentiles[offset(50)] AS f50,
    c.percentiles[offset(75)] AS f75, 
    c.percentiles[offset(100)] AS f100,
    d.percentiles[offset(25)] AS r25, 
    d.percentiles[offset(50)] AS r50,
    d.percentiles[offset(75)] AS r75,
    d.percentiles[offset(100)] AS r100
FROM 
    t2 a,
    (SELECT APPROX_QUANTILES(monetary, 100) percentiles FROM
    t2) b,
    (SELECT APPROX_QUANTILES(frequency, 100) percentiles FROM
    t2) c,
    (SELECT APPROX_QUANTILES(recency, 100) percentiles FROM
    t2) d
),
t4 AS (
    SELECT *, 
    CAST(ROUND((f_score + m_score) / 2, 0) AS INT64) AS fm_score
    FROM (
        SELECT *, 
        CASE WHEN monetary <= m25 THEN 1
            WHEN monetary <= m50 AND monetary > m25 THEN 2 
            WHEN monetary <= m75 AND monetary > m50 THEN 3  
            WHEN monetary <= m100 AND monetary > m75 THEN 4
        END AS m_score,
        CASE WHEN frequency <= f25 THEN 1
            WHEN frequency <= f50 AND frequency > f25 THEN 2 
            WHEN frequency <= f75 AND frequency > f50 THEN 3  
            WHEN frequency <= f100 AND frequency > f75 THEN 4
        END AS f_score,
        --Recency scoring is reversed
        CASE WHEN recency <= r25 THEN 4
            WHEN recency <= r50 AND recency > r25 THEN 3 
            WHEN recency <= r75 AND recency > r50 THEN 2 
            WHEN recency <= r100 AND recency > r75 THEN 1
        END AS r_score,
        FROM t3
        )
),
t5 AS (
    SELECT 
        CustomerID, 
        Country,
        recency,
        frequency, 
        monetary,
        r_score,
        f_score,
        m_score,
        fm_score,
        CASE WHEN (r_score = 4 AND fm_score = 4) 
            OR (r_score = 4 AND fm_score = 3) 
        THEN 'Best Customers'
        WHEN (r_score = 4 AND fm_score =2) 
            OR (r_score = 3 AND fm_score = 3)
            OR (r_score = 2 AND fm_score = 3)
        THEN 'Loyal Customers'
        WHEN (r_score = 2 AND fm_score = 4) 
            OR (r_score = 3 AND fm_score = 4)
        THEN 'Big spenders'
        WHEN (r_score = 4 AND fm_score = 2) 
            OR (r_score = 4 AND fm_score = 2)
            OR (r_score = 3 AND fm_score = 3)
            OR (r_score = 4 AND fm_score = 3)
        THEN 'Potential Loyalists'
        WHEN r_score = 4 AND fm_score = 1 THEN 'Recent Customers'
        WHEN (r_score = 3 AND fm_score = 1) 
            OR (r_score = 2 AND fm_score = 1)
        THEN 'Promising'
        WHEN (r_score = 2 AND fm_score = 1) 
            OR (r_score = 1 AND fm_score = 2)
            OR (r_score = 1 AND fm_score = 1)
        THEN 'Customers Needing Attention'
        WHEN r_score = 1 AND fm_score = 1 THEN 'About to Sleep'
        WHEN (r_score = 1 AND fm_score = 4) 
            OR (r_score = 1 AND fm_score = 3)
            OR (r_score = 1 AND fm_score = 2)
        THEN 'At Risk'
        WHEN (r_score = 1 AND fm_score = 4)
            OR (r_score = 1 AND fm_score = 3)        
        THEN 'Cant Lose Them'
        WHEN r_score = 1 AND fm_score = 1 THEN 'Hibernating'
        WHEN r_score = 1 AND fm_score = 1 THEN 'Lost Customers'
        WHEN (r_score = 3 AND fm_score = 2)
        OR (r_score = 2 AND fm_score = 2) THEN 'At Risk Low Spenders'
        END AS rfm_segment 
    FROM t4
)
SELECT * 
FROM t5