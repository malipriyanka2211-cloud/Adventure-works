use advanture_work;
show tables;

select * from fact_internet_sales_new;
select count(*) from fact_internet_sales_new;
select count(*) from factinternetsales;

SELECT *
FROM FactInternetSales
WHERE OrderDate IS NULL
   OR CustomerKey IS NULL
   OR SalesAmount IS NULL;

-- I . Append/Union of Fact Internet sales and Fact internet sales new - SALES

CREATE TABLE fact_sale AS
SELECT *
FROM FactInternetSales
UNION ALL
SELECT *
FROM Fact_Internet_Sales_New;

-- II. Merge Products, ProductCategory and ProductSubCategory Tables
SELECT 
    p.ProductKey,
    p.EnglishProductName,
    p.ListPrice,
    p.Color,
    ps.EnglishProductSubcategoryName,
    pc.EnglishProductCategoryName
FROM dimproduct p
LEFT JOIN dimproductsubcategory ps
ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN dimproductcategory pc
ON ps.ProductCategoryKey = pc.ProductCategoryKey;
 
 DESCRIBE fact_sale;
 
ALTER TABLE fact_sale
CHANGE COLUMN `ï»¿ProductKey` ProductKey INT;
 
 -- 1. Lookup the Productname from the Product sheet to Sales sheet.
SELECT 
    s.ProductKey,
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    p.EnglishProductName
FROM fact_sale s
LEFT JOIN dimproduct p
    ON s.ProductKey = p.ProductKey;
    
-- 2. Lookup the Customerfullname from the Customer Table and Unit Price from Product Table to Sales sheet.
SELECT 
    s.ProductKey,
    s.CustomerKey,
    s.SalesOrderNumber,
    
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    
    p.`Unit price` AS UnitPrice

FROM fact_sale s
LEFT JOIN dimcustomer c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct p
    ON s.ProductKey = p.ProductKey;
    

-- Q.3
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE fact_sale
ADD COLUMN Date DATE;

select * from fact_sale;

UPDATE fact_sale
SET Date = DATE(
    CONCAT(
        LEFT(OrderDateKey,4), '-',
        MID(OrderDateKey,5,2), '-',
        RIGHT(OrderDateKey,2)
    )
);
   
ALTER TABLE fact_sale ADD COLUMN Year INT;
UPDATE fact_sale
SET Year = YEAR(Date);

ALTER TABLE fact_sale ADD COLUMN MonthNo INT;
UPDATE fact_sale
SET MonthNo = MONTH(Date);

ALTER TABLE fact_sale ADD COLUMN MonthFullName VARCHAR(20);
UPDATE fact_sale
SET MonthFullName = MONTHNAME(Date);

ALTER TABLE fact_sale ADD COLUMN Quarter VARCHAR(2);
UPDATE fact_sale
SET Quarter = CONCAT('Q', QUARTER(Date));

ALTER TABLE fact_sale ADD COLUMN YearMonth VARCHAR(10);
UPDATE fact_sale
SET YearMonth = DATE_FORMAT(Date, '%Y-%b');

ALTER TABLE fact_sale ADD COLUMN WeekdayNumber INT;
UPDATE fact_sale
SET WeekdayNumber = DAYOFWEEK(Date);

ALTER TABLE fact_sale ADD COLUMN WeekdayName VARCHAR(20);
UPDATE fact_sale
SET WeekdayName = DAYNAME(Date);

ALTER TABLE fact_sale ADD COLUMN FinancialMonth INT;
UPDATE fact_sale
SET FinancialMonth = 
CASE 
    WHEN MONTH(Date) >= 4 THEN MONTH(Date) - 3
    ELSE MONTH(Date) + 9
END;


ALTER TABLE fact_sale ADD COLUMN FinancialQuarter VARCHAR(2);
UPDATE fact_sale
SET FinancialQuarter =
CASE
    WHEN MONTH(Date) BETWEEN 4 AND 6 THEN 'Q1'
    WHEN MONTH(Date) BETWEEN 7 AND 9 THEN 'Q2'
    WHEN MONTH(Date) BETWEEN 10 AND 12 THEN 'Q3'
    ELSE 'Q4'
END;