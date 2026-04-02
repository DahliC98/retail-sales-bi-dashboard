USE retail_db;
DESCRIBE orders;

-- Cleaning
UPDATE orders
SET order_date =
  CASE
    WHEN order_date IS NULL OR order_date = '' THEN NULL
    WHEN CAST(LEFT(order_date, 2) AS UNSIGNED) > 12 THEN STR_TO_DATE(order_date, '%d-%m-%Y')
    ELSE STR_TO_DATE(order_date, '%m-%d-%Y')
  END;
  UPDATE orders
SET ship_date =
  CASE
    WHEN ship_date IS NULL OR ship_date = '' THEN NULL
    WHEN CAST(LEFT(ship_date, 2) AS UNSIGNED) > 12 THEN STR_TO_DATE(ship_date, '%d-%m-%Y')
    ELSE STR_TO_DATE(ship_date, '%m-%d-%Y')
  END;
ALTER TABLE orders MODIFY order_date DATE;
ALTER TABLE orders MODIFY ship_date DATE;
CREATE TABLE orders_backup AS
SELECT * FROM orders;

-- Total Revenue, Profit, Orders, Avg Order Value
SELECT
    COUNT(*) AS total_orders, 
    SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(AVG(sales), 2) AS avg_order_value
FROM orders;

-- Monthly Sales Trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(sales) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

-- Revenue by Region
SELECT region, SUM(sales) AS revenue
FROM orders
GROUP BY region
ORDER BY revenue DESC;

-- Top 10 Products
SELECT product_name, SUM(sales) AS total_sales
FROM orders
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;


-- Top 10 Customers
SELECT customer_name, SUM(sales) AS total_spent
FROM orders
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 10;

-- Profit by Category
SELECT category, SUM(profit) AS total_profit
FROM orders
GROUP BY category
ORDER BY total_profit DESC;

-- Loss-Making Products
SELECT product_name, SUM(profit) AS total_profit
FROM orders
GROUP BY product_name
HAVING total_profit < 0
ORDER BY total_profit ASC
LIMIT 10;

-- Total Sales, Profit, Profit Margin by Category
SELECT
    category,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_margin
FROM orders
GROUP BY category
ORDER BY profit_margin DESC;