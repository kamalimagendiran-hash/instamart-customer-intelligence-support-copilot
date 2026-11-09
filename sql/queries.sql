-- Query 1: High-value completed orders

SELECT
    customer_id,
    SUM(order_amount) AS total_spend
FROM orders
WHERE status = 'completed'
    AND order_amount > 500
GROUP BY customer_id
HAVING SUM(order_amount) > 8000
ORDER BY total_spend DESC;


-- Query 2: Revenue by city and product category

SELECT
    c.city,
    p.category,
    ROUND(SUM(o.order_amount), 2) AS revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN products p
    ON o.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY c.city, p.category
ORDER BY c.city, p.category;

-- Query 3: Products priced above average catalogue price

SELECT
    product_id,
    product_name,
    price_inr
FROM products
WHERE price_inr > (
    SELECT AVG(price_inr)
    FROM products
)
ORDER BY price_inr DESC;


-- Query 4: Customers with no completed orders

SELECT
    c.customer_id,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.status = 'completed'
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- Query 5: Customers spending above average customer spend

WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(order_amount) AS total_spend
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
),
average_spend AS (
    SELECT AVG(total_spend) AS avg_spend
    FROM customer_spend
)
SELECT
    cs.customer_id,
    ROUND(cs.total_spend, 2) AS total_spend,
    ROUND(a.avg_spend, 2) AS avg_spend
FROM customer_spend cs
CROSS JOIN average_spend a
WHERE cs.total_spend > a.avg_spend
ORDER BY cs.total_spend DESC;

-- Query 6: Customer ranking within each city

WITH customer_spend AS (
    SELECT
        c.city,
        o.customer_id,
        SUM(o.order_amount) AS total_spend
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
    GROUP BY c.city, o.customer_id
),
ranked AS (
    SELECT
        city,
        customer_id,
        ROUND(total_spend, 2) AS total_spend,
        RANK() OVER (
            PARTITION BY city
            ORDER BY total_spend DESC
        ) AS spend_rank,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY total_spend DESC
        ) AS dense_rank,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY total_spend DESC, customer_id
        ) AS row_num
    FROM customer_spend
)
SELECT *
FROM ranked
WHERE spend_rank = 1
ORDER BY city, customer_id;


-- Query 7: Daily revenue and cumulative running total

WITH daily AS (
    SELECT
        DATE(order_ts) AS order_day,
        ROUND(SUM(order_amount), 2) AS daily_revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE(order_ts)
)
SELECT
    order_day,
    daily_revenue,
    ROUND(
        SUM(daily_revenue) OVER (
            ORDER BY order_day
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ), 2
    ) AS running_revenue
FROM daily
ORDER BY order_day;

print("Q1:")
print(...)
print("Q2:")
print(...)
...
print("Q7:")
print(...)