-- an SQL query to generate a daily report of the total revenue for a specific date
SELECT SUM(total_amount) AS total_revenue 
FROM orders
WHERE order_date = '2025-11-1'; 

--an SQL query to generate a monthly report of the top-selling products in a given month.
SELECT product.product_name,
SUM (order_details.unit_price * order_details.quantity) As total_revenue
FROM order_details JOIN product ON order_details.product_id = product.product_id 
JOIN orders ON orders.order_id = order_details.order_id
WHERE orders.order_date BETWEEN '2025-11-1' AND '2025-11-30'
GROUP BY product.product_name
ORDER BY total_revenue DESC;

-- a SQL query to retrieve a list of customers who have placed orders totaling more than $500 in the past month. 
SELECT customer.first_name , customer.last_name , SUM(orders.total_amount ) AS past_moth
FROM customer JOIN orders ON (customer.customer_id = orders.customer_id)
WHERE orders.order_date BETWEEN '2025-10-1' AND '2025-10-30' 
GROUP BY customer.first_name , customer.last_name 
HAVING SUM(orders.total_amount) > 500;