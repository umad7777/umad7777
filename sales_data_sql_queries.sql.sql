-- ============================================================
-- SUPERSTORE SALES DATA — SQL QUERY FILE
-- Maincrafts Technology | Data Analytics & Business Intelligence Task 1
-- ============================================================

-- STEP 1: CREATE TABLE
CREATE TABLE sales (
    order_id      VARCHAR(50),
    order_date    DATE,
    ship_date     DATE,
    ship_mode     VARCHAR(50),
    customer_id   VARCHAR(50),
    customer_name VARCHAR(100),
    segment       VARCHAR(50),
    country       VARCHAR(50),
    city          VARCHAR(100),
    state         VARCHAR(100),
    postal_code   VARCHAR(20),
    region        VARCHAR(50),
    product_id    VARCHAR(50),
    category      VARCHAR(50),
    sub_category  VARCHAR(50),
    product_name  VARCHAR(255),
    sales         DECIMAL(10,2),
    quantity      INT,
    discount      DECIMAL(5,2),
    profit        DECIMAL(10,2)
);

-- ============================================================
-- QUERY 1: Total Sales by Region
-- ============================================================
SELECT
    region,
    SUM(sales)                             AS total_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (), 1) AS pct_of_total
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

/*  Expected Results:
    West:    $725,457.82  (31.6%)
    East:    $678,781.24  (29.5%)
    Central: $501,239.89  (21.8%)
    South:   $391,721.90  (17.1%)
*/

-- ============================================================
-- QUERY 2: Profit by Category (Top 5 Most Profitable)
-- ============================================================
SELECT
    category,
    SUM(sales)                               AS total_sales,
    SUM(profit)                              AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct
FROM sales
GROUP BY category
ORDER BY total_profit DESC
LIMIT 5;

/*  Expected Results:
    Technology:      Sales $836,154  | Profit $145,455  | Margin 17.4%
    Office Supplies: Sales $719,047  | Profit $122,491  | Margin 17.0%
    Furniture:       Sales $742,000  | Profit $18,451   | Margin  2.5%
*/

-- ============================================================
-- QUERY 3: Monthly Sales Trend
-- ============================================================
SELECT
    YEAR(order_date)                           AS year,
    MONTH(order_date)                          AS month,
    MONTHNAME(order_date)                      AS month_name,
    ROUND(SUM(sales), 2)                       AS total_sales,
    ROUND(SUM(profit), 2)                      AS total_profit
FROM sales
GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date)
ORDER BY year, month;

-- For SQLite, use:
-- strftime('%Y', order_date) AS year, strftime('%m', order_date) AS month

-- ============================================================
-- QUERY 4: Discount Impact on Profit
-- ============================================================
SELECT
    CASE
        WHEN discount = 0          THEN '0% - No Discount'
        WHEN discount <= 0.20      THEN '1-20% Discount'
        WHEN discount <= 0.40      THEN '21-40% Discount'
        WHEN discount <= 0.60      THEN '41-60% Discount'
        ELSE                            '61-80% Discount'
    END                                        AS discount_band,
    COUNT(*)                                   AS num_orders,
    ROUND(AVG(profit), 2)                      AS avg_profit,
    ROUND(SUM(profit), 2)                      AS total_profit
FROM sales
GROUP BY discount_band
ORDER BY avg_profit DESC;

/*  Key Insight: Discounts above 20% consistently result in negative avg profit!
    0%:     avg profit = $66.90  ✅
    1-20%:  avg profit = $26.50  ⚠️
    21-40%: avg profit = -$77.86 ❌
    41-60%: avg profit = -$134.62 ❌
*/

-- ============================================================
-- QUERY 5: Top 10 Customers by Sales
-- ============================================================
SELECT
    customer_name,
    COUNT(DISTINCT order_id)   AS total_orders,
    SUM(quantity)              AS total_items,
    ROUND(SUM(sales), 2)       AS total_sales,
    ROUND(SUM(profit), 2)      AS total_profit
FROM sales
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;

-- ============================================================
-- QUERY 6: Sub-Category Performance (Ranked by Profit)
-- ============================================================
SELECT
    sub_category,
    category,
    ROUND(SUM(sales), 2)                       AS total_sales,
    ROUND(SUM(profit), 2)                      AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 1)   AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(profit) DESC)    AS profit_rank
FROM sales
GROUP BY sub_category, category
ORDER BY total_profit DESC;

-- ============================================================
-- QUERY 7: Year-over-Year Sales Growth
-- ============================================================
SELECT
    YEAR(order_date)        AS year,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM sales
GROUP BY YEAR(order_date)
ORDER BY year;

/*  YoY Growth Observed:
    2014: $484,247  | 2015: $470,532  | 2016: $609,205  | 2017: $733,215
    Strong growth in 2016-2017 (+20.4%)
*/

-- ============================================================
-- QUERY 8: Best Performing States by Sales
-- ============================================================
SELECT
    state,
    region,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(SUM(profit), 2)    AS total_profit
FROM sales
GROUP BY state, region
ORDER BY total_sales DESC
LIMIT 10;

-- ============================================================
-- QUERY 9: Ship Mode Distribution and Average Delivery Days
-- ============================================================
SELECT
    ship_mode,
    COUNT(*)                                        AS num_orders,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 1)  AS avg_days_to_ship,
    ROUND(SUM(sales), 2)                            AS total_sales
FROM sales
GROUP BY ship_mode
ORDER BY num_orders DESC;

-- ============================================================
-- QUERY 10: Segment Performance Summary
-- ============================================================
SELECT
    segment,
    COUNT(DISTINCT customer_id)  AS total_customers,
    COUNT(DISTINCT order_id)     AS total_orders,
    ROUND(SUM(sales), 2)         AS total_sales,
    ROUND(SUM(profit), 2)        AS total_profit,
    ROUND(AVG(sales), 2)         AS avg_order_sales
FROM sales
GROUP BY segment
ORDER BY total_sales DESC;
