CREATE DATABASE "E-commerce";

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(20) NOT NULL, 
    last_name VARCHAR(20) NOT NULL, 
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    address VARCHAR(255)
);

CREATE TABLE category(
    category_id SERIAL PRIMARY KEY, 
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE product(
    product_id SERIAL PRIMARY KEY, 
    product_name VARCHAR(100) NOT NULL, 
    price NUMERIC(10,2) NOT NULL,
    description VARCHAR(255),
    stock_quantity INT NOT NULL DEFAULT 0,
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE orders(
    order_id SERIAL PRIMARY KEY, 
    customer_id INT NOT NULL, 
    order_date DATE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,  
    order_id INT NOT NULL, 
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);
