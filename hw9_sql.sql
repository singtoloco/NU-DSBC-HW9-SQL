use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) as `Actor Name`
FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";


-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
-- so create a column in the table actor named description and use the data type BLOB
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) as `Count Last Name`
FROM actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors
SELECT a.last_name, a.count_last_name
FROM (SELECT last_name, COUNT(last_name) as count_last_name FROM actor GROUP BY last_name) a
WHERE a.count_last_name >= 2;

SELECT last_name, COUNT(last_name) as `Count Last Name`
FROM actor
GROUP BY last_name
HAVING `Count Last Name` >= 2;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
-- Write a query to fix the record.

-- check before update
SELECT *
FROM actor
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- update (fix the record)
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- check after update
SELECT *
FROM actor
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all! In a single query,
-- if the first name of the actor is currently HARPO, change it to GROUCHO.

-- check before correction
SELECT *
FROM actor
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';

-- correction
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';

-- check after correction
SELECT *
FROM actor
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
FROM staff as s 
INNER JOIN address as a
ON s.address_id = a.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(pmt.amount) as `Total Amount Rung`
FROM staff as s
INNER JOIN payment as pmt
ON s.staff_id = pmt.staff_id
WHERE pmt.payment_date LIKE "%2005-08%"
GROUP BY s.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(f.title) as num_actors
FROM film_actor as fa
INNER JOIN film as f
ON fa.film_id = f.film_id
GROUP BY f.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(f.title)
FROM film as f
INNER JOIN inventory as i
on f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) as `Total Amount Paid`
FROM customer as c
INNER JOIN payment as p
on c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE title LIKE "K%" OR title LIKE "Q%" AND language_id IN
(
 SELECT language_id
 FROM language
 WHERE name = 'English'
);


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
 SELECT actor_id
 FROM film_actor
 WHERE film_id IN
 (
  SELECT film_id
  FROM film
  WHERE title = 'Alone Trip'
 )
);


-- 7c. You want to run an email marketing campaign in Canada,
-- for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id
INNER JOIN city
ON address.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id
WHERE country.country = 'Canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.
SELECT f.title
FROM film as f
INNER JOIN film_category as fc
ON f.film_id = fc.film_id
INNER JOIN category as c
ON fc.category_id = c.category_id
WHERE c.name = 'Family';


-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) as count_rent
FROM film as f
INNER JOIN inventory as i
ON f.film_id = i.film_id
INNER JOIN rental as r
ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY count_rent DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(pmt.amount)
FROM store
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment as pmt
ON staff.staff_id = pmt.staff_id
GROUP BY store.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, city.city, country.country
FROM store as s
INNER JOIN address as a
ON s.address_id = a.address_id
INNER JOIN city
ON a.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id
GROUP BY s.store_id;


-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT cat.name as "Genre", SUM(pmt.amount) as `Gross revenue`
FROM category as cat
INNER JOIN film_category as fcat
ON cat.category_id = fcat.category_id
INNER JOIN inventory as i
ON fcat.film_id = i.film_id
INNER JOIN rental as r
ON i.inventory_id = r.inventory_id
INNER JOIN payment as pmt
ON r.rental_id = pmt.rental_id
GROUP BY cat.name
ORDER BY `Gross revenue` DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres as
	SELECT cat.name as "Genre", SUM(pmt.amount) as `Gross revenue`
	FROM category as cat
	INNER JOIN film_category as fcat
	ON cat.category_id = fcat.category_id
	INNER JOIN inventory as i
	ON fcat.film_id = i.film_id
	INNER JOIN rental as r
	ON i.inventory_id = r.inventory_id
	INNER JOIN payment as pmt
	ON r.rental_id = pmt.rental_id
	GROUP BY cat.name
	ORDER BY `Gross revenue` DESC
	LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top_five_genres;










