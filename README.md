# E-commerce-System
# The System ERD
<img src="ecommerceERD.png" />

See the full database setup [here](ecommerceSchema.sql)


# Some important quaries :
# An SQL query to generate a daily report of the total revenue for a specific date
<pre>
SELECT SUM(total_amount) AS total_revenue 
FROM orders
WHERE order_date = '2025-11-1'; 
</pre>
  
# An SQL query to generate a monthly report of the top-selling products in a given month.
<pre>
SELECT product.product_name,
SUM (order_details.unit_price * order_details.quantity) As total_revenue
FROM order_details JOIN product ON order_details.product_id = product.product_id 
JOIN orders ON orders.order_id = order_details.order_id
WHERE orders.order_date BETWEEN '2025-11-1' AND '2025-11-30'
GROUP BY product.product_name
ORDER BY total_revenue DESC;
</pre>
  
# An SQL query to retrieve a list of customers who have placed orders totaling more than $500 in the past month. 
<pre>
SELECT customer.first_name , customer.last_name , SUM(orders.total_amount ) AS past_moth
FROM customer JOIN orders ON (customer.customer_id = orders.customer_id)
WHERE orders.order_date BETWEEN '2025-10-1' AND '2025-10-30' 
GROUP BY customer.first_name , customer.last_name 
HAVING SUM(orders.total_amount) > 500;
</pre>

# We can apply a denormalization mechanism on customer and order entities
By adding a CustomerName to the Order entitie and by adding OrderId to the Customer entite 

# Write an SQL query to search for all products with the word "camera" in either the product name or description.
<pre>
SELECT name , cat_id , price , description
from product 
WHERE product_name LIKE '%camera%' 
OR description LIKE '%camera%'
</pre>

#  Design a query to suggest popular products in the same category for the same author, excluding the Purchsed product from the recommendations
  <pre>
select product.name , sum(order_details.unit_price * order_details.quantity) as total_revenue
from product join order_details on (product.id = order_details.product_id)
where product.cat_id = (select category_id from product where product_id = 123)
and product.author_id = (select author_id from product where product_id = 123) 
and product.id <> 123
group by product.id
order by total_revenue desc
  </pre>
