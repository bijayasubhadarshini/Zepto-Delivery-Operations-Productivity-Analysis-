CREATE DATABASE ZEPTO_SQL_PROJECT;
USE ZEPTO_SQL_PROJECT;
CREATE TABLE zepto (
  sku_id INT AUTO_INCREMENT PRIMARY KEY,
  category VARCHAR(120),
  name VARCHAR(150) NOT NULL,
  mrp DECIMAL(8,2),
  discountPercent DECIMAL(5,2),
  availableQuantity INT,
  discountedSellingPrice DECIMAL(8,2),
  weightInGms INT,
  outOfStock TINYINT(1),
  quantity INT
);
--------- data exploration 
SELECT * FROM zepto;
---------- count rows
SELECT COUNT(*) FROM zepto;
---------- sample data
SELECT * FROM zepto
LIMIT 10;

------- null values select
SELECT * FROM zepto 
WHERE name IS NULL 
OR
mrp IS NULL 
OR
category IS NULL 
OR
discountPercent IS NULL 
OR
availableQuantity IS NULL 
OR
discountedSellingPrice IS NULL 
OR
weightInGms IS NULL
;    
--------- different product categories distinct so non repetative
SELECT DISTINCT category FROM zepto
ORDER BY category;

---- * product names present multiple times
SELECT name, COUNT(sku_id) AS 'Number of SKUs' 
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) ASC;

------- data cleaning

------- product where price might be zero
SELECT * FROM zepto
WHERE mrp = 0 
OR discountedSellingPrice = 0;
DELETE FROM zepto WHERE mrp = 0;
-- Remove invalid pricing records (MRP cannot be zero)

----------- convert paisa to rupees
SET SQL_SAFE_UPDATES = 0;
-- Disable safe updates temporarily to allow full-table price normalization

UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;
    
SELECT mrp, discountedSellingPrice FROM zepto;

----------- business insights
---- Q1 Find the top 10 best-value products based on the discount percentage
SELECT DISTINCT name, mrp, discountPercent FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
 ------ beneficial customers looking for bargain and for businesses to know which products are being heavily promoted

---- Q2 Calculate estimated revenue for each category
SELECT category, 
SUM(discountedSellingPrice * availableQuantity) AS total_revenue 
-- Estimated revenue assuming full sell-through of available inventory
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

---- Q3 Find all products where mrp is greater than 500 and discount is less than 10%
SELECT DISTINCT name, mrp, discountPercent 
FROM zepto 
WHERE mrp > 500 AND discountPercent < 10;


---- Q4 Identify the top 5 categories offfering the highest average discount percentage
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount 
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

---- Q5 find the price per gram for products above 100g and sort by best value
SELECT DISTINCT name, weightInGms, discountedSellingPrice, 
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
From zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

---- Q6 Group the products into categories like low, medium, bulk.
SELECT DISTINCT name, weightInGms,
CASE 
WHEN weightInGms < 100 
THEN 'Low'
WHEN weightInGms < 5000 
THEN 'Medium'
ELSE 'Bulk'
END AS weight_category
FROM zepto;

---- Q7 What is the total inventory weight per category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto 
GROUP BY category
ORDER BY total_weight DESC;

SET SQL_SAFE_UPDATES = 1;
