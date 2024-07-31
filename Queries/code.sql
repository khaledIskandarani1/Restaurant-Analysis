



use [pizza_restaurant];

select * from order_details;
select * from orders;
select * from pizzas;
select * from pizza_types;
GO



CREATE VIEW full_orders_details_vw 
AS
select od.order_id,quantity,date,time,datepart(hour,time) as hour
from order_details as od left join orders as ord
on od.order_id = ord.order_id;
go

select hour,sum(quantity) as total from 
full_orders_details_vw 
group by hour



;
go





/*
 customers each day, peak hours
*/
create view total_daily_orders_vw as
select date AS day, count(od.order_id) as 'total daily orders',round(sum(quantity*pi.price),2) as Revenue
	from order_details as od inner join orders as ord
		on od.order_id = ord.order_id
			left join pizzas as pi
				on od.pizza_id = pi.pizza_id
				
	group by date

	GO
	select * 
	from total_daily_orders_vw;
	go
	/*pizzas in an order, bestsellers*/

	select od.order_id, sum(quantity) as 'total pizza orders'
	from order_details as od inner join orders as ord
		on od.order_id = ord.order_id
	group by od.order_id;
    GO

	select pt.name, sum(quantity) as total_qty
	from order_details as od left join pizzas as pi
    on od.pizza_id = pi.pizza_id
		left join pizza_types as pt
			on pi.pizza_type_id = pt.pizza_type_id
	
	group by pt.name
    having sum(quantity) > 2000;
	GO

	/*  money earned tis year, seasonality*/

	select round(sum(quantity*price),2) as 'sum of sales'
from order_details as od inner join pizzas as pi
on od.pizza_id = pi.pizza_id
	left join orders as ord
    on ord.order_id = od.order_id
group by year(date);


create view monthly_sales_vw as
select datepart(quarter,date) as Quarter,round(sum(quantity*price),2) as 'sum of sales'
from order_details as od inner join pizzas as pi
on od.pizza_id = pi.pizza_id
	left join orders as ord
    on ord.order_id = od.order_id
	group by datepart(quarter,date)
;
GO

create view vw_quartrly_orders_vw as
select  datepart(quarter,date) as Quarterly_Sales,round(sum(quantity*price),2) as 'sum of sales'
from order_details as od inner join pizzas as pi
on od.pizza_id = pi.pizza_id
	left join orders as ord
    on ord.order_id = od.order_id
	group by datepart(quarter,date);

/* pizzas we should take of the menu, promotions we could leverage?*/

select   top 10 pt.name, sum(quantity) as total_qty
	from order_details as od left join pizzas as pi
    on od.pizza_id = pi.pizza_id
		left join pizza_types as pt
			on pi.pizza_type_id = pt.pizza_type_id
	
	group by pt.name
    order by total_qty asc;

	/* pizza for promotion*/
	create view vw_pizza_for_promotions as
	select   pt.name, sum(quantity) as total_qty
	from order_details as od left join pizzas as pi
    on od.pizza_id = pi.pizza_id
		left join pizza_types as pt
			on pi.pizza_type_id = pt.pizza_type_id
	
	group by pt.name
    having sum(quantity) between 1400 and 1600;
	go
	


/* top pizzas */
select   top 1 (select    pt.name
	from order_details as od left join pizzas as pi
    on od.pizza_id = pi.pizza_id
		left join pizza_types as pt
			on pi.pizza_type_id = pt.pizza_type_id
	
	group by pt.name
	having sum(quantity)>2450) as pizzaname
	from pizza_types ;

/*  category,ingridients making*/
CREATE TABLE Categories (
    CategoryID INT IDENTITY PRIMARY KEY,  -- Auto-incrementing primary key
    CategoryName VARCHAR(255) NOT NULL   -- Category name (e.g., meat, vegetables)
);

CREATE TABLE Ingredients (
    IngredientID INT IDENTITY PRIMARY KEY,  -- Auto-incrementing primary key
    IngredientName VARCHAR(255) NOT NULL,  -- Ingredient name (e.g., Barbecued Chicken)
    CategoryID INT,                        -- Foreign key to Categories table
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);



-- Insert Meat ingredients into Ingredients table
INSERT INTO Ingredients (IngredientName, CategoryID)
VALUES 
('Barbecued Chicken', 1),
('Bacon', 1),
('Pepperoni', 1),
('Italian Sausage', 1),
('Chorizo Sausage', 1),
('’Nduja Salami', 1),
('Pancetta', 1),
('Prosciutto', 1),
('Capocollo', 1),
('Calabrese Salami', 1),
('Genoa Salami', 1),
('Soppressata Salami', 1),
('Coarse Sicilian Salami', 1),
('Beef Chuck Roast', 1);

-- Insert Vegetables ingredients into Ingredients table
INSERT INTO Ingredients (IngredientName, CategoryID)
VALUES 
('Red Peppers', 2),
('Green Peppers', 2),
('Tomatoes', 2),
('Red Onions', 2),
('Artichokes', 2),
('Spinach', 2),
('Mushrooms', 2),
('Jalapeno Peppers', 2),
('Zucchini', 2),
('Eggplant', 2),
('Friggitello Peppers', 2),
('Green Olives', 2),
('Sun-dried Tomatoes', 2),
('Cilantro', 2);


-- Insert Herbs & Spices into the Seasoning category (CategoryID = 3)
INSERT INTO Ingredients (IngredientName, CategoryID)
VALUES 
('Thyme', 3),
('Garlic', 3),
('Oregano', 3),
('Arugula', 3),
('Cilantro', 3);

-- Insert Cheese ingredients into Ingredients table
INSERT INTO Ingredients (IngredientName, CategoryID)
VALUES 
('Brie Carre Cheese', 4),
('Fontina Cheese', 4),
('Gouda Cheese', 4),
('Asiago Cheese', 4),
('Mozzarella Cheese', 4),
('Provolone Cheese', 4),
('Smoked Gouda Cheese', 4),
('Romano Cheese', 4),
('Blue Cheese', 4),
('Ricotta Cheese', 4),
('Gorgonzola Piccante Cheese', 4),
('Parmigiano Reggiano Cheese', 4),
('Goat Cheese', 4),
('Feta Cheese', 4);


-- Insert Sauces ingredients into Ingredients table
INSERT INTO Ingredients (IngredientName, CategoryID)
VALUES 
('Barbecue Sauce', 5),
('Alfredo Sauce', 5),
('Pesto Sauce', 5),
('Thai Sweet Chilli Sauce', 5),
('Chipotle Sauce', 5);


select * from Ingredients;
-- Describe a table using sp_help
EXEC sp_help 
 pizza_types;



 /*
1-Create a Mapping Table: Create PizzaTypeIngredients to link pizza_type_id with ingredient_id.
2-Extract Ingredients: Split the ingredients column values and map them to ingredient names.
3-Insert Mapped Data: Insert the ingredient IDs for each pizza_type_id into the new mapping table.
4-Clean Up: Drop temporary tables if used.
*/



-- Check the column definition in pizza_types table
SELECT COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_types';

/* create table PizzaTypeIngredients */
CREATE TABLE PizzaTypeIngredient (
    pizza_type_id NVARCHAR(50),
    ingredient_id INT,
    PRIMARY KEY (pizza_type_id, ingredient_id),
    FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(IngredientID)
);

-- Create a temporary table to hold parsed ingredients
CREATE TABLE #TempPizzaIngredients (
    pizza_type_id NVARCHAR(50),
    ingredient_name NVARCHAR(50)
);

-- Populate the temporary table with parsed ingredient data
INSERT INTO #TempPizzaIngredients (pizza_type_id, ingredient_name)
SELECT
    pizza_type_id,
    TRIM(value) AS ingredient_name
FROM
    pizza_types
CROSS APPLY
    STRING_SPLIT(ingredients, ',')
WHERE
    value IS NOT NULL;


	-- Insert into PizzaTypeIngredients
INSERT INTO PizzaTypeIngredient (pizza_type_id, ingredient_id)
SELECT
    t.pizza_type_id,
    i.IngredientID
FROM
    #TempPizzaIngredients t
JOIN
    Ingredients i ON t.ingredient_name = i.IngredientName;

-- Drop the temporary table
DROP TABLE #TempPizzaIngredients;

SELECT 
    pt.pizza_type_id,
    pt.name AS pizza_name,
    i.IngredientName
FROM 
    PizzaTypeIngredient pti
JOIN 
    pizza_types pt ON pti.pizza_type_id = pt.pizza_type_id
JOIN 
    Ingredients i ON pti.ingredient_id = i.IngredientID
WHERE 
    pt.pizza_type_id = 'big_meat';  -- Replace with actual pizza type ID

select * from pizza_types;

SELECT 
    pt.pizza_type_id,
    pt.name AS pizza_name,
    i.IngredientID
FROM 
    PizzaTypeIngredient pti
JOIN 
    pizza_types pt ON pti.pizza_type_id = pt.pizza_type_id
JOIN 
    Ingredients i ON pti.ingredient_id = i.IngredientID
WHERE 
    pt.pizza_type_id = 'cali_ckn';  -- Replace with actual pizza type ID

/* identify highest ordered pizzas*/
SELECT
    pt.pizza_type_id,
    pt.name AS pizzaname,
	pt.ingredients
FROM
    order_details AS od
LEFT JOIN
    pizzas AS pi ON od.pizza_id = pi.pizza_id
LEFT JOIN
    pizza_types AS pt ON pi.pizza_type_id = pt.pizza_type_id
GROUP BY
    pt.pizza_type_id, pt.name,pt.ingredients
HAVING
    SUM(quantity) > 1400;

/* display their ingredients**/

SELECT
    i.IngredientName,
    COUNT(*) AS usage_count
FROM
    PizzaTypeIngredient AS pti
JOIN
    ingredients AS i ON pti.ingredient_id = i.ingredientid
WHERE
    pti.pizza_type_id IN (
        SELECT
            pt.pizza_type_id
        FROM
            order_details AS od
        LEFT JOIN
            pizzas AS pi ON od.pizza_id = pi.pizza_id
        LEFT JOIN
            pizza_types AS pt ON pi.pizza_type_id = pt.pizza_type_id
        GROUP BY
            pt.pizza_type_id
        HAVING
            SUM(quantity) > 1400
    )
GROUP BY
    i.IngredientName
ORDER BY
    usage_count DESC;



	




















