use sakila;
--- 1.What is the total revenue generated from all rentals in the database?
select * from rental;
select * from film;
select sum(amount) from payment;
select * from payment;
--- 2.	How many rentals were made in each month_name?
select extract(month from rental_date)as month, count(*) from rental group by month;
--- 3.	What is the rental rate of the film with the longest title in the database?
select * from film;
select rental_rate from film where length(title)=
(select max(length(title)) from film);
--- 4.	What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")
select * from inventory;
select avg(f.rental_rate)
from film f 
join inventory i on f.film_id = i.film_id 
join rental r on i.inventoy_id = r.inventory_id
where r.rental_date >= (select date_sub("2005-05-05 22:04:30", interval 30 day));
SELECT AVG(f.rental_rate)
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_date >= (SELECT DATE_SUB('2005-05-05 22:04:30', INTERVAL 30 DAY));
 --- 5.	What is the most popular category of films in terms of the number of rentals? 
 select * from film_category;
 select * from film;
 select c.category_id,count(*)as rent_count from film_category c 
 join film f on f.film_id=c.film_id
 join inventory i on i.film_id=f.film_id
 join rental r on i.inventory_id=r.inventory_id
 group by c.category_id order by rent_count desc;
 select * from rental;
 --- 6.	Find the longest movie duration from the list of films that have not been rented by any customer
select film_id,length from film f where not exists
(select rental_id,customer_id from rental r where rental_id is null)group by film_id order by length desc;
--- 7.	What is the average rental rate for films, broken down by category?
select avg(f.rental_rate),c.category_id from film f
join film_category c on f.film_id=c.film_id
group by c.category_id;
--- 8.	What is the total revenue generated from rentals for each actor in the database? 
select a.actor_id,sum(p.amount) from film_actor a 
join film f on a.film_id=f.film_id
join inventory i on i.film_id=f.film_id
join rental r on i.inventory_id=r.inventory_id
join payment p on p.rental_id=r.rental_id group by a.actor_id;
--- 9.	Show all the actresses who worked in a film having a "Wrestler" in the description.
select a.actor_id from film_actor a 
join film f on a.film_id=f.film_id
where f.description like "%Wrestler%";
--- 10.	Which customers have rented the same film more than once?
select c.customer_id from customer c
join rental r on c.customer_id=r.rental_id
join inventory i on i.inventory_id=r.inventory_id
join film f on i.film_id=f.film_id group by c.customer_id having count(*)>1;
--- 11.	How many films in the comedy category have a rental rate higher than the average rental rate?
select c.name,count(*),avg(f.rental_rate) from category c
join film_category fc on c.category_id=fc.category_id 
join film f on f.film_id=fc.film_id
where c.name="comedy" and f.rental_rate>
(select avg(f1.rental_rate) from film f1
join film_category fc1 on f1.film_id=fc1.film_id) ;
--- 12.	Which films have been rented the most by customers living in each city?
SELECT city.city,
    film.title AS most_rented_film,
    COUNT(*) AS rental_count
FROM
    city
JOIN
    address ON city.city_id = address.city_id
JOIN
    customer ON address.address_id = customer.address_id
JOIN
    rental ON customer.customer_id = rental.customer_id
JOIN
    inventory ON rental.inventory_id = inventory.inventory_id
JOIN
    film ON inventory.film_id = film.film_id
GROUP BY
    city.city,
    film.title
order by rental_count desc;
--- 13.	What is the total amount spent by customers whose rental payments exceed $200?
select * from payment;
select customer_id,sum(amount) as total from payment group by customer_id having total>200; 
--- 14.	Display the fields which are having foreign key constraints related to the "rental" table.
select table_name,column_name,constraint_name,referenced_table_name,referenced_column_name
from information_schema.key_column_usage
where referenced_table_name ="rental";
--- 15.	Create a View for the total revenue generated by each staff member, broken down by store city with the country name
SELECT s.staff_id, s.first_name, s.last_name, ci.city AS store_city, c.country AS store_country, SUM(p.amount) AS total_revenue
FROM staff s
JOIN store st ON s.store_id = st.store_id
JOIN address a ON st.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country c ON ci.country_id = c.country_id
JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name, store_city, c.country;
 --- 16.	Create a view based on rental information consisting of visiting_day, customer_name, the title of the film,
 --- no_of_rental_days, the amount paid by the customer along with the percentage of customer spending
 SELECT r.rental_date AS visiting_day,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       f.title AS film_title,
       f.rental_duration AS no_of_rental_days,
       p.amount AS amount_paid,
       (p.amount / (SELECT SUM(amount) FROM payment WHERE customer_id = p.customer_id) * 100) AS spending_percentage
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN payment p ON r.rental_id = p.rental_id;
select * from film;
--- 17.	Display the customers who paid 50% of their total rental costs within one day
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       SUM(p.amount) AS total_payment,
       SUM(f.rental_rate) AS total_rental_cost
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN payment p ON r.rental_id = p.rental_id
WHERE p.payment_date = r.rental_date
GROUP BY c.customer_id
HAVING SUM(p.amount) >= 0.5 * SUM(f.rental_rate);
