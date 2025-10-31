
USE sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW customer_rentals AS 
SELECT
rental.customer_id,
customer.first_name,
customer.last_name,
customer.email,
COUNT(rental_id) AS rental_count
FROM rental
LEFT JOIN customer
ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE customer_total_paid AS
SELECT
customer_rentals.*,
SUM(payment.amount) AS total_paid
FROM customer_rentals
INNER JOIN payment
ON customer_rentals.customer_id = payment.customer_id
GROUP BY customer_rentals.customer_id;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
WITH customer_summary AS (
	SELECT
		customer_rentals.first_name,
		customer_rentals.last_name,
		customer_rentals.email,
		customer_rentals.rental_count,
		customer_total_paid.total_paid
	FROM customer_rentals
	INNER JOIN customer_total_paid
		ON customer_rentals.customer_id = customer_total_paid.customer_id
)
SELECT *
FROM customer_summary;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH customer_summary AS (
	SELECT
		customer_rentals.first_name,
		customer_rentals.last_name,
		customer_rentals.email,
		customer_rentals.rental_count,
		customer_total_paid.total_paid
	FROM customer_rentals
	INNER JOIN customer_total_paid
		ON customer_rentals.customer_id = customer_total_paid.customer_id
)
SELECT
    first_name,
    last_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary;


