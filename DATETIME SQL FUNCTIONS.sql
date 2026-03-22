-- Retrieve all customers' first name, last name, and email.

USE customers;
SELECT customer_id, first_name, last_name, email
FROM customer;
 -- List all customers who are currently active.
 SELECT *
 FROM customer
 WHERE active = 1;
 -- Count the total number of customers.
 SELECT count(customer_id)
 FROM customer;
 
 -- Count how many customers belong to each store.
 SELECT store_id, count(customer_id)
 FROM customer
 GROUP BY store_id;
 
 -- Find customers who were created in a specific year (e.g. 2006).
 SELECT first_name, last_name, year(create_date) as Year_of_creation
 FROM customer
 WHERE year(create_date) = 2006;
 
 -- Find customers who have not been updated in the last 30 days.
SELECT NOW() as `Current_date`,
date_sub(NOW(),  Interval 30 DAY) as targeted_date;

SELECT customer_id, last_update,
date_sub(NOW(),  Interval 30 DAY) as targeted_date
FROM customer
WHERE last_update < date_sub(NOW(),  Interval 30 DAY)
