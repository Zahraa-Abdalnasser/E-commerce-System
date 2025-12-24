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
WHERE MATCH( name , description)
AGAINST ('camera')
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

# A Tigger to create a sale hitory when a new order is placed 
```
CREATE TABLE sales_history
(
sale_hist_id INT PRIMARY KEY , 
order_id INT NOT NULL , 
customer_id INT NOT NULL , 
product_id INT NOT NULL , 
total_amount INT NOT NULL ,
quantity INT NOT NULL ,
created_at TIMESTAMP , 
CONSTRAINT fk_items_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);                              

CREATE OR REPLACE FUNCTION insert_sales_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO sales_history (
        order_id,
        customer_id,
        product_id,
        total_amount,
        quantity
    )
    VALUES (
        NEW.order_id,
        NEW.customer_id,
        NEW.product_id,
        NEW.total_amount,
        NEW.quantity
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER after_new_order
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION insert_sales_history();

```
# A transaction query to lock the quantity field with product id = 211 for update 
```
BEGIN  
SELECT stock_quantity 
FROM product 
WHERE product_id = 211 
FOR UPDATE 
COMMIT ; 
```

# A transaction query to lock the row with product id = 211 for update 
```
BEGIN 
SELECT *
FROM product 
WHERE product_id = 211 
FOR UPDATE 
COMMIT ;
```
# optimization queries 
```
-- full scan on the product table 
explain select * from product
WHERE MATCH (product.name,product.description)
against ('T-shirt'); 

-- indexed lookup on the orders table 
explain analyze select * from orders 
where customer_id = 112 ;

-- Write a query to find all items for a specific order_id only (without including product_id).
explain analyze format='tree'  select product.product_name , product.price , product.description
from order_details inner join product on (order_detail.product_id = product.product_id)
where order_id = 122 ; 

--  find the Top 5 most expensive products within a specific category name
explain analyze format = 'tree' select product.product_id , product.product_name 
-- where category inner join product on (category.category_id = product.category_id)
group by category.category_id desc
limit 5 ;

-- find products where the "Price plus 14% Tax" is less than 200 ( the optimizer ignores indeces if there is an expression ) 
explain analyze format = 'tree' select product_name , description , price 
from product
where price * 1.14 < 200

-- top 10 expensive queries 
SELECT * FROM performance_schema.events_statements_summary_by_digest ORDER BY SUM_TIMER_WAIT DESC LIMIT 10 ; 

-- clusterd index  vs  covering index 
EXPLAIN 
SELECT username, email, created_at 
FROM userinfo 
WHERE role = 'user' AND is_active = 1 
ORDER BY created_at DESC;

CREATE INDEX idx_covering_role_active_created 
ON userinfo (role, is_active, created_at, username, email);

EXPLAIN 
SELECT username, email, created_at 
FROM userinfo 
WHERE role = 'user' AND is_active = 1 
ORDER BY created_at DESC;
-- does it really use the index ?
SELECT * FROM performance_schema.table_io_waits_summary_by_index_usage;

-- is there any deadlock?
SELECT * FROM performance_schema.events_errors_summary_by_account_by_error WHERE error_name = 'ER_LOCK_DEADLOCK';

SHOW GLOBAL VARIABLES LIKE 'innodb_buffer_pool_size';

-- calculate hit rate 
SHOW ENGINE INNODB STATUs ; 

```
