use sakila;

-- Write a query to find what is the total business done by each store.
SELECT
    s.store_id, FORMAT(SUM(amount), 2, 'de_DE') income
FROM
    rental r
        JOIN
    payment p ON r.rental_id = p.rental_id
        JOIN
    staff s ON p.staff_id = s.staff_id
GROUP BY s.store_id;

-- Convert the previous query into a stored procedure.
drop procedure if exists store_incomestore_income;
delimiter //
create procedure store_income()
begin
		SELECT
			s.store_id, FORMAT(SUM(amount), 2, 'de_DE') income
		FROM
			rental r
				JOIN
			payment p ON r.rental_id = p.rental_id
				JOIN
			staff s ON p.staff_id = s.staff_id
		GROUP BY s.store_id;
end
// delimiter ;

call store_income;

-- Convert the previous query into a stored procedure that takes the input for store_id and displays the total sales for that store.
drop procedure if exists income_store_id;
delimiter //
create procedure income_store_id(in store smallint)
begin

	SELECT s.store_id, FORMAT(SUM(amount), 2, 'de_DE') income
	FROM rental r
	JOIN payment p ON r.rental_id = p.rental_id
	JOIN staff s ON p.staff_id = s.staff_id
    WHERE s.store_id = store
	GROUP BY s.store_id;
end
// delimiter ;

call income_store_id(1);


--  Update the previous query. Declare a variable total_sales_value of float type, that will store the returned result (of the total sales amount for the store). 
-- Call the stored procedure and print the results.
drop procedure if exists income_store_id_to_v;

delimiter //
create procedure income_store_id_to_v(in store smallint, out total_sales_value float)
begin

	select income into total_sales_value from
		(SELECT s.store_id, SUM(amount) income
		FROM rental r
		JOIN payment p ON r.rental_id = p.rental_id
		JOIN staff s ON p.staff_id = s.staff_id
		WHERE s.store_id = store
		GROUP BY s.store_id)
	sub1;
end
// delimiter ;

call income_store_id_to_v(1, @total_sales_value);
select @total_sales_value;

-- In the previous query, add another variable flag. If the total sales value for the store is over 30.000, then label it as green_flag, otherwise label is as red_flag. 
-- Update the stored procedure that takes an input as the store_id and returns total sales value for that store and flag value.
drop procedure if exists income_store_id_to_v;

delimiter //
create procedure income_store_id_to_v(in store smallint, out total_sales_value float, out flag varchar(10))
begin

    declare flag_color varchar(10) default "";

	select income into total_sales_value from
		(SELECT s.store_id, SUM(amount) income
		FROM rental r
		JOIN payment p ON r.rental_id = p.rental_id
		JOIN staff s ON p.staff_id = s.staff_id
		WHERE s.store_id = store
		GROUP BY s.store_id)
	sub1;

    if total_sales_value > 30000 then
		set flag_color = "green_flag";
	else
		set flag_color = "red_flag";
	end if;

    select flag_color into flag;
end

// delimiter ;

call income_store_id_to_v(1, @total_sales_value, @flag);
SELECT @total_sales_value, @flag;