SET search_path TO northwind;

-- Make the order_id column in orders an auto-generated identity column
ALTER TABLE orders
    ALTER COLUMN order_id ADD GENERATED ALWAYS AS IDENTITY;

--- PART 1: FUNCTIONS ---

/*
EXAMPLE 1.1 - SCALAR FUNCTION
A scalar function returns a single value.
This one calculates total revenue for a customer.
Parameters: p_customer_id (a variable-length string)
Returns: a number (the total revenue for that customer)
*/
CREATE OR REPLACE FUNCTION get_customer_revenue(p_customer_id VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC; -- Variable to hold the total revenue
BEGIN
    -- Raise an exception if the customer ID does not exist in the customers table
    IF p_customer_id NOT IN (SELECT customer_id FROM customers) THEN
        RAISE EXCEPTION 'No such customer.';
    END IF;
    -- Calculate the total revenue for the customer by adding up the revenue for each item in every order made by the customer.
    -- The revenue for each item is the product of unit price, quantity, and discount.
    -- Put the result into the v_total variable.
    SELECT SUM(od.unit_price * od.quantity * (1 - od.discount))
    INTO v_total
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    WHERE o.customer_id = p_customer_id;

    -- If the customer has no orders, the total revenue will be NULL, so we use COALESCE to return 0 instead.
    RETURN COALESCE(v_total, 0);
END;
$$ LANGUAGE plpgsql;

-- Test the function with a valid customer ID and an invalid one to see how it behaves.
SELECT get_customer_revenue('ALFKI');
SELECT get_customer_revenue('ABCDE'); -- EXCEPTION

-- Use the function in a query to get the total revenue for each customer, ordered from highest to lowest.
SELECT customer_id, company_name, get_customer_revenue(customer_id) AS
total_revenue
FROM customers
ORDER BY total_revenue DESC;

/*
EXERCISE 1
Write a function called get_product_revenue that accepts a product_id (INT)
and returns the total revenue for that product across all orders. Use COALESCE
for NULL product_ids.
*/
CREATE OR REPLACE FUNCTION get_product_revenue(p_product_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN

    -- Raise an exception if the product ID does not exist in the products table
    IF p_product_id NOT IN (SELECT product_id FROM products) THEN
        RAISE EXCEPTION 'No such product.';
    END IF;

    -- Calculate the total revenue for the product by adding up the revenue for each item in every order that includes the product.
    -- The revenue for each item is the product of unit price, quantity, and discount.
    -- Put the result into the v_total variable.
    SELECT SUM(od.unit_price * od.quantity * (1 - od.discount))
    INTO v_total
    FROM products p
    JOIN order_details od ON p.product_id = od.product_id
    WHERE p.product_id = p_product_id;

    -- If the product has no orders, the total revenue will be NULL, so we use COALESCE to return 0 instead.
    RETURN COALESCE(v_total, 0);
END;
$$ LANGUAGE plpgsql;

-- Test the function with a valid product ID and an invalid one to see how it behaves.
SELECT get_product_revenue(11);
SELECT get_product_revenue(999); 

-- Use the function in a query to get the total revenue for each product, ordered from highest to lowest.
SELECT product_id, product_name, get_product_revenue(product_id) AS
total_revenue
FROM products
ORDER BY total_revenue DESC;

/*
EXAMPLE 1.2 - FUNCTION WITH CONDITIONAL LOGIC
Functions can contain IF and CASE logic.
This example reuses get_customer_revenue from Example 1.1.
Parameters: p_customer_id (a variable-length string)
Returns: a string indicating the loyalty tier of the customer based on their total revenue.
*/
CREATE OR REPLACE FUNCTION get_loyalty_tier(p_customer_id VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    v_revenue NUMERIC; -- Variable to hold the total revenue for the customer
BEGIN
    -- Call the get_customer_revenue function to get the total revenue for the customer and store it in v_revenue.
    v_revenue := get_customer_revenue(p_customer_id);
    -- Use a CASE statement to determine the loyalty tier based on the total revenue.
    RETURN CASE
        WHEN v_revenue >= 10000 THEN 'Platinum'
        WHEN v_revenue >= 5000 THEN 'Gold'
        WHEN v_revenue >= 1000 THEN 'Silver'
        ELSE 'Bronze'
    END;
END;
$$ LANGUAGE plpgsql;

-- Use the function in a query to get the loyalty tier for each customer, ordered by tier.
SELECT customer_id, company_name, get_loyalty_tier(customer_id) AS tier
FROM customers
ORDER BY tier;


/*
EXERCISE 2
Write a function called get_stock_status that accepts units_in_stock (INT)
and returns a VARCHAR label:
0 units: Out of Stock
1 to 9 units: Low Stock
10 or more units: In Stock

Parameters: p_units_in_stock (an integer)
Returns: a string indicating the stock status of the product based on the number of units in stock
*/
CREATE OR REPLACE FUNCTION get_stock_status(p_units_in_stock INT)
RETURNS VARCHAR AS $$
BEGIN
    -- Use a CASE statement to determine the stock status based on the number of units in stock.
    RETURN CASE
        WHEN p_units_in_stock = 0 THEN 'Out of Stock'
        WHEN p_units_in_stock <= 9 THEN 'Low Stock'
        ELSE 'In Stock'
    END;
END;
$$ LANGUAGE plpgsql;

-- Use the function in a query to get the stock status for each product.
SELECT product_name, units_in_stock, get_stock_status(units_in_stock) AS
status
FROM products;

--- PART 2: STORED PROCEDURES ---

/*
EXAMPLE 2.1 - BASIC PROCEDURE
This procedure inserts an order header, a single line item, and updates
stock as one atomic transaction.
Parameters: p_customer_id (a variable-length string), p_employee_id (an integer), 
p_ship_via (an integer), p_product_id (an integer), 
p_quantity (an integer), p_unit_price (a real number), p_discount (a real number, defaulting to 0)
*/
CREATE OR REPLACE PROCEDURE place_order(
    p_customer_id VARCHAR,
    p_employee_id INT,
    p_ship_via INT,
    p_product_id INT,
    p_quantity INT,
    p_unit_price REAL,
    p_discount REAL DEFAULT 0
)
LANGUAGE plpgsql AS $$
DECLARE
    v_order_id INT; -- Variable to hold the generated order ID
BEGIN
    -- Wrap queries in a block to catch exceptions safely
    BEGIN
        -- Insert parent order record
        INSERT INTO orders (customer_id, employee_id, order_date, ship_via)
        VALUES (p_customer_id, p_employee_id, CURRENT_DATE, p_ship_via)
        RETURNING order_id INTO v_order_id;

        -- Insert line item
        INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount)
        VALUES (v_order_id, p_product_id, p_unit_price, p_quantity, p_discount);

        -- Deduct inventory
        UPDATE products
        SET units_in_stock = units_in_stock - p_quantity
        WHERE product_id = p_product_id;
    EXCEPTION
    WHEN OTHERS THEN
        -- Explicit rollback if any of the above statements fail. This will undo any changes made in the transaction.
        ROLLBACK;
        RAISE EXCEPTION 'Order failed: %', SQLERRM;
    END;

    -- Explicit commit happens outside the block where subtransactions are cleared
    COMMIT;
    RAISE NOTICE 'Order % placed successfully.', v_order_id;
END;
$$;

/*
Questions:
1. What happens if the INSERT into orders succeeds but the INSERT into order_details fails?
    There will be an exception, and the ROLLBACK will run. Any previous changes will not have been committed, and therefore
    the database will return to the state it was in before the procedure began.
2. Why is RETURNING order_id INTO v_order_id necessary?
    We want to be able to use the order_id again. However, that was local to the INSERT query. To be able to use it
    elsewhere, we had to assign it to a procedure variable.
*/

-- Test the procedure by placing an order for a single product. 
-- Then, check the orders and order_details tables to see if the order was placed successfully.
CALL place_order('ALFKI', 5, 2, 11, 10, 21.00, 0.05);
SELECT * FROM orders WHERE order_date = CURRENT_DATE;
SELECT * FROM order_details WHERE order_id IN (SELECT order_id FROM orders
WHERE order_date = CURRENT_DATE);

/*
EXERCISE 3 - A BETTER PROCEDURE
Real orders have multiple products. This version accepts arrays so you can
pass all line items in one call.
Notice: PostgreSQL arrays are 1-indexed. The loop starts at 1, not 0.
Parameters: p_customer_id (a variable-length string), p_employee_id (an integer),
p_ship_via (an integer), p_product_ids (an array of integers),
p_quantities (an array of integers), p_unit_prices (an array of real numbers),
p_discounts (an array of real numbers, defaulting to NULL)
*/
CREATE OR REPLACE PROCEDURE place_order_multi(
    p_customer_id VARCHAR,
    p_employee_id INT,
    p_ship_via INT,
    p_product_ids INT[],
    p_quantities INT[],
    p_unit_prices REAL[],
    p_discounts REAL[] DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    -- Variable to hold the generated order ID
    v_order_id INT;
    -- Variable to hold the number of products in the order
    v_count INT;
    -- Variable to hold the stock level of a product
    v_stock INT;
    -- Loop counter for iterating through the arrays
    i INT;
    -- Variable to hold the discount for a product, defaulting to 0 if not provided
    v_discount REAL;
BEGIN
    BEGIN
        -- Check if the product list is empty and raise an exception if it is
        v_count := coalesce(array_length(p_product_ids, 1), 0);
        IF v_count IS NULL OR v_count = 0 THEN
            RAISE EXCEPTION 'Product list cannot be empty.';
        END IF;

        -- raise an exception when the length of p_quantities or p_unit_prices does not match the length of p_product_ids
        -- coalesce is used to handle the case where the arrays are NULL, which would cause array_length to return NULL 
        --and not raise an exception
        IF coalesce(array_length(p_quantities, 1), 0) <> v_count 
        OR coalesce(array_length(p_unit_prices, 1), 0) <> v_count THEN
            RAISE EXCEPTION 'Lengths of lists do not match.';
        END IF;

        -- raise an exception when p_discounts is not the same length
        -- as the other arrays that is only raised if p_discounts is not null
        IF p_discounts IS NOT NULL AND coalesce(array_length(p_discounts, 1), 0) <> v_count THEN
            RAISE EXCEPTION 'Problem with p_discounts.';
        END IF;

        -- Insert parent order record and get the generated order ID into the v_order_id variable. 
        -- The order_date is set to the current date.
        INSERT INTO orders (customer_id, employee_id, order_date, ship_via)
        VALUES (p_customer_id, p_employee_id, CURRENT_DATE, p_ship_via)
        RETURNING order_id INTO v_order_id;

        FOR i IN 1 .. v_count LOOP
            -- PostgreSQL array subscripting returns NULL instead of erroring when the array is NULL or the index is out of bounds
            -- So this does not raise an exception when p_discounts is NULL. We use COALESCE to default to 0.
            v_discount := COALESCE(p_discounts[i], 0);
            
            -- Insert each line item into the order_details table, using the corresponding product ID, 
            -- unit price, quantity, and discount from the arrays.
            INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount)
            VALUES (v_order_id, p_product_ids[i], p_unit_prices[i], p_quantities[i], v_discount);

            -- Update the units_in_stock for the product by subtracting the quantity ordered.
            UPDATE products
            SET units_in_stock = units_in_stock - p_quantities[i]
            WHERE product_id = p_product_ids[i]
            RETURNING units_in_stock INTO v_stock;

            -- Raise an exception when units in stock for a product is less than the corresponding quantity in p_quantities
            IF v_stock < 0 THEN
                RAISE EXCEPTION 'Product % cannot be ordered in quantity %, only % is available.', 
                                                 p_product_ids[i], p_quantities[i], v_stock+p_quantities[i];
            END IF;
        END LOOP;

    EXCEPTION
        -- Handle invalid customer, employee, or product IDs and other exceptions by rolling back all changes
        -- and printing an appropriate error message.
        WHEN foreign_key_violation THEN
            RAISE EXCEPTION 'Invalid customer, employee or product ID. %',
            SQLERRM;
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Order failed: %', SQLERRM;
    END;
    -- Explicit commit happens outside the block where subtransactions are cleared
    COMMIT;

    -- A message is printed to indicate that the order was placed successfully, 
    -- along with the order ID and the number of line items.
    RAISE NOTICE 'Order % placed with % line item(s).', v_order_id, v_count;
END;
$$;

--- Test the procedure by placing an order for multiple products.
CALL place_order_multi(
    'ALFKI', 5, 2,
    ARRAY[11, 42],
    ARRAY[1, 5],
    ARRAY[21.00, 14.00]
);
SELECT * FROM orders WHERE order_date = CURRENT_DATE;
SELECT * FROM order_details WHERE order_id IN (SELECT order_id FROM orders
WHERE order_date = CURRENT_DATE);
SELECT product_id, units_in_stock FROM products WHERE product_id IN (11, 42);

--- Test the procedure with various edge cases to ensure it handles errors correctly.
CALL place_order_multi('ALFKI', 5, 2, ARRAY[]::INT[], ARRAY[]::INT[], ARRAY[]::INT[]); -- Empty order list
CALL place_order_multi('ALFKI', 5, 2, ARRAY[11]::INT[], ARRAY[1]::INT[], ARRAY[]::INT[]); -- Mismatched lengths
CALL place_order_multi('ALFKI', 5, 2, ARRAY[11]::INT[], ARRAY[1]::INT[], ARRAY[1]::INT[], ARRAY[]::INT[]); -- Mismatched p_discount length
CALL place_order_multi('ALFKI', 5, 2, ARRAY[11]::INT[], ARRAY[10000]::INT[], ARRAY[1]::INT[]); -- More than was in stock
CALL place_order_multi('ALFKI', 5, 2, ARRAY[1999]::INT[], ARRAY[1]::INT[], ARRAY[1]::INT[]); -- Invalid product ID
CALL place_order_multi('AHHHH', 5, 2, ARRAY[11]::INT[], ARRAY[1]::INT[], ARRAY[1]::INT[]); -- Invalid customer ID

/*
EXERCISE 4 - CANCEL THE ORDER
Write a procedure that cancels an existing order by
restoring stock, then deleting the line items and order header.

Parameters: p_order_id (an integer)
*/
CREATE OR REPLACE PROCEDURE cancel_order(p_order_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    -- Variable to hold the number of orders with the given order_id
    v_count INT;
BEGIN
    BEGIN
        -- Check if the order exists by counting the number of orders with the given order_id.
        -- Raise an exception if the order does not exist.
        SELECT COUNT(*) INTO v_count
        FROM orders WHERE order_id = p_order_id;
        
        IF v_count = 0 THEN
            RAISE EXCEPTION 'There is no order with ID %', p_order_id;
        END IF;

        -- This can also be done with EXISTS, like this:
        -- IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = p_order_id)
        --    RAISE EXCEPTION 'There is no order with ID %', p_order_id;

        -- Restore stock for each product in the order by adding the quantity from order_details 
        -- back to the units_in_stock in products.
        UPDATE products p
        SET units_in_stock = p.units_in_stock + od.quantity
        FROM order_details od
        WHERE od.product_id = p.product_id AND od.order_id = p_order_id;

        -- Delete the order details and the order itself.
        DELETE FROM order_details WHERE order_id = p_order_id;
        DELETE FROM orders WHERE order_id = p_order_id;      
    EXCEPTION
    -- Handle any exceptions that occur during the cancellation process by rolling back all changes
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Cancellation failed: %', SQLERRM;
    END;
    -- Explicit commit happens outside the block where subtransactions are cleared
    COMMIT;
    -- A message is printed to indicate that the stock has been restored and the order has been deleted.
    RAISE NOTICE 'Stock restored and order deleted: %', p_order_id;
END;
$$;

/*
Call your procedure to test it. Be sure to check the output in the tables.
Your .sql file should contain your test cases and comments on expected
behavior.
*/
CALL cancel_order(10); -- Successful!!!!

SELECT * FROM orders WHERE order_id = 10; -- Should return no rows
SELECT * FROM order_details WHERE order_id = 10; -- Should return no rows
SELECT product_id, units_in_stock FROM products WHERE product_id IN (11, 42); -- Should show that stock has been restored

CALL cancel_order(10); -- Failed since it's already been deleted
CALL cancel_order(99999); -- Order never existed

/*
List all user-defined routines. Your database should now contain all the
functions and procedures in this tutorial.
*/
SELECT routine_name, routine_type, data_type
FROM information_schema.routines
WHERE routine_schema = 'northwind'
ORDER BY routine_type, routine_name;