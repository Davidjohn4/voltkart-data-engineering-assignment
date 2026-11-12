-- DDL + load for dialect: sqlserver

CREATE DATABASE Voltkart_assignment_1;
GO

USE Voltkart_assignment_1;
GO

CREATE TABLE dim_category (
  category_id BIGINT,
  parent_category_id BIGINT,
  category_name NVARCHAR(1500)
);
BULK INSERT dim_category FROM 'D:\\Data Engineer\\Data_Engineer_Bootcamp\\SQL\\code_assets_Day01\\week1_assignment_assets\\data\\dim_category.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
select * from dim_category;

CREATE TABLE dim_employee (
  employee_id BIGINT,
  employee_name NVARCHAR(255),
  manager_id BIGINT,
  role NVARCHAR(255),
  region NVARCHAR(255)
);
BULK INSERT dim_employee FROM 'D:\\Data Engineer\\Data_Engineer_Bootcamp\\SQL\\code_assets_Day01\\week1_assignment_assets\\data\\dim_employee.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

CREATE TABLE dim_customer (
  customer_id BIGINT,
  customer_name NVARCHAR(255),
  city NVARCHAR(255),
  segment NVARCHAR(255),
  signup_date DATE
);
BULK INSERT dim_customer FROM 'D:\\Data Engineer\\Data_Engineer_Bootcamp\\SQL\\code_assets_Day01\\week1_assignment_assets\\data\\dim_customer.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

CREATE TABLE dim_product (
  product_id BIGINT,
  product_name NVARCHAR(255),
  category_id BIGINT,
  unit_price DECIMAL(18,2),
  unit_cost DECIMAL(18,2),
  launch_date DATE
);
BULK INSERT dim_product FROM 'D:\\Data Engineer\\Data_Engineer_Bootcamp\\SQL\\code_assets_Day01\\week1_assignment_assets\\data\\dim_product.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

CREATE TABLE fact_orders (
  order_id BIGINT,
  order_date DATE,
  customer_id BIGINT,
  sales_rep_id BIGINT,
  order_status NVARCHAR(255),
  order_total DECIMAL(18,2)
);
BULK INSERT fact_orders FROM 'D:\\Data Engineer\\Data_Engineer_Bootcamp\\SQL\\code_assets_Day01\\week1_assignment_assets\\data\\fact_orders.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

CREATE TABLE fact_order_items (
  order_item_id BIGINT,
  order_id BIGINT,
  product_id BIGINT,
  quantity BIGINT,
  unit_price DECIMAL(18,2),
  line_amount DECIMAL(18,2)
);
BULK INSERT fact_order_items FROM 'D:\\Data Engineer\\Data_Engineer_Bootcamp\\SQL\\code_assets_Day01\\week1_assignment_assets\\data\\fact_order_items.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

CREATE TABLE stg_orders_incr (
  order_id BIGINT,
  order_date DATE,
  customer_id BIGINT,
  sales_rep_id BIGINT,
  order_status NVARCHAR(255),
  order_total DECIMAL(18,2)
);

BULK INSERT stg_orders_incr FROM 'D:\\Data Engineer\\Data_Engineer_Bootcamp\\SQL\\code_assets_Day01\\week1_assignment_assets\\data\\stg_orders_incr.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

CREATE TABLE cdc_product_changes (
  change_id BIGINT,
  product_id BIGINT,
  operation NVARCHAR(255),
  change_ts NVARCHAR(255),
  product_name NVARCHAR(255),
  category_id BIGINT,
  unit_price DECIMAL(18,2),
  unit_cost DECIMAL(18,2),
  launch_date DATE
);
BULK INSERT cdc_product_changes FROM 'D:\\Data Engineer\\Data_Engineer_Bootcamp\\SQL\\code_assets_Day01\\week1_assignment_assets\\data\\cdc_product_changes.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);


USE Voltkart_assignment_1;

SELECT 'dim_category' AS table_name, COUNT(*) AS rows FROM dim_category
UNION ALL SELECT 'dim_employee', COUNT(*) FROM dim_employee
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'fact_orders', COUNT(*) FROM fact_orders
UNION ALL SELECT 'fact_order_items', COUNT(*) FROM fact_order_items
UNION ALL SELECT 'stg_orders_incr', COUNT(*) FROM stg_orders_incr
UNION ALL SELECT 'cdc_product_changes', COUNT(*) FROM cdc_product_changes;


Select * from fact_orders;

Select * from dim_customer;

Select * From fact_order_items
/*

Q1) Voltkart's commercial team wants a quick look at the biggest sales.Return the
top 20 completed orders by value, with the customer and the sales rep behind each one. 
Required output: order_id, order_date, customer_name, sales_rep_name, order_total.
*/


SELECT top 20
    fo.order_id,
    fo.order_date,
    dc.customer_name,
    de.employee_name AS sales_rep_name,
    fo.order_total
FROM fact_orders fo
left JOIN dim_employee de
    ON fo.sales_rep_id = de.employee_id
left Join dim_customer dc
on fo.customer_id=dc.customer_id
where fo.order_status = 'Completed'
order by fo.order_total desc;

/*
2.
Marketing wants to re-engage people who registered but never bought. List the
customers who have never placed an order. Required output: customer_id, customer_name, signup_date.
*/

select * from fact_orders

Select c.customer_id,c.customer_name,c.signup_date
from dim_customer c
where not EXISTS (​
        SELECT 1​
        FROM   fact_orders AS o​
        where o.customer_id=c.customer_id
      );

/*
3.
Merchandising wants the stars of each category. For every category, return the
top 3 products by completed revenue. Required output: category_name, product_name, total_revenue, revenue_rank.

*/

select * from dim_category;

select * from dim_product;

select * from fact_orders

select * from fact_order_items o


--with cte1 as(
--select c.category_name, p.product_name,Sum(o.line_amount) total_revenue    
--from fact_order_items o
--left join fact_orders os
--on os.order_id=o.order_id
--left join dim_product p 
--on p.product_id=o.product_id
--left join dim_category c
--on c.category_id=p.category_id
--where os.order_status='Completed'
--group by 
--c.category_name, p.product_name)
--select * ,RANK() OVER (
--        PARTITION BY category_name
--        ORDER BY total_revenue DESC
--    ) AS revenue_rank
--from cte1


WITH cte1 AS
(
    select c.category_name, p.product_name,Sum(o.line_amount) total_revenue    
from fact_order_items o
left join fact_orders os
on os.order_id=o.order_id
left join dim_product p 
on p.product_id=o.product_id
left join dim_category c
on c.category_id=p.category_id
where os.order_status='Completed'
group by 
c.category_name, p.product_name
),
cte2 AS
(
    SELECT
        category_name,
        product_name,
        total_revenue,
        RANK() OVER (
            PARTITION BY category_name
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM cte1
)
select * from cte2 
where revenue_rank <= 3

/*
4.
Finance wants the revenue trend with momentum. Produce
monthly completed revenue with a cumulative running total and the month-over-month % change. 

Required output: order_month (YYYY-MM), monthly_revenue, running_total, mom_pct_change.
*/

WITH cte1 AS (
    SELECT 
        FORMAT(o.order_date, 'yyyy-MM') AS order_month,
        SUM(o.order_total) AS monthly_revenue
    FROM fact_orders o
    WHERE order_status = 'Completed'
    GROUP BY FORMAT(o.order_date, 'yyyy-MM')
),

cte2 AS (
    SELECT 
        order_month,
        monthly_revenue,

        SUM(monthly_revenue) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total,

        LAG(monthly_revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue

    FROM cte1
)

SELECT 
    order_month,
    monthly_revenue,
    running_total,

    CAST(
        (monthly_revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0)
        AS DECIMAL(10,2)
    ) AS mom_pct_change

FROM cte2;


/*
5.
The CRM team wants to size up the customer base by value. Split customers into
four quartiles by lifetime completed spend, and for each quartile report how many customers fall in it and their average spend. 
Required output: spend_quartile, customer_count, avg_lifetime_spend.
*/

Select * from dim_customer;


WITH cte1 AS (
    SELECT 
        o.customer_id,
        SUM(o.order_total) AS lifetime_spend
    FROM fact_orders o
    WHERE order_status = 'Completed'
    GROUP BY o.customer_id
),
cte2 as
(
select customer_id,lifetime_spend ,NTILE(4) OVER (
    ORDER BY lifetime_spend
)spend_quartile
from cte1

)
SELECT
    spend_quartile,
    COUNT(*) AS customer_count,
    round(AVG(lifetime_spend),2) AS avg_lifetime_spend
FROM cte2
GROUP BY spend_quartile;

/*

6.
The catalogue team needs to see everything under a part of the tree. Using a
recursive query, list all categories in the subtree rooted at 'Computers' at any depth, 
with how deep each sits and a readable path from Computers.
Required output: category_id, category_name, depth_level, category_path.
*/
WITH category_tree AS
(
    SELECT 
        category_id,
        category_name,
        0 AS depth_level,
        CAST(category_name AS VARCHAR(1000)) AS category_path
    FROM dim_category
    WHERE category_id = 102

    UNION ALL

    SELECT
        c.category_id,
        c.category_name,
        ct.depth_level + 1,
        CAST(
            ct.category_path + ' > ' + c.category_name 
            AS VARCHAR(1000)
        ) AS category_path
    FROM dim_category c
    JOIN category_tree ct
        ON c.parent_category_id = ct.category_id
)
SELECT *
FROM category_tree;

/*

7.
Sales leadership wants performance rolled up the org chart. For every employee,
compute the total completed order value generated by their whole team — that is, 
themselves plus everyone reporting under them at any depth.
A Sales Rep's team is just themselves; a manager's is their entire subtree.
*/

/*
7.
Sales leadership wants performance rolled up the org chart. For every employee,
compute the total completed order value generated by their whole team —
themselves plus everyone reporting under them at any depth.
*/

WITH employee_tree AS
(
    -- STEP 1: Every employee is initially their own root
    SELECT
        employee_id,
        employee_id AS root_employee_id,
        manager_id,
        0 AS depth_level
    FROM dim_employee

    UNION ALL

    -- STEP 2: Find everyone reporting under each employee
    SELECT
        e.employee_id,
        et.root_employee_id,
        e.manager_id,
        et.depth_level + 1
    FROM dim_employee e
    JOIN employee_tree et
        ON e.manager_id = et.employee_id
),

employee_order_value AS
(
    -- STEP 3: Calculate each employee's own completed sales
    SELECT
        sales_rep_id AS employee_id,
        SUM(order_total) AS own_order_value
    FROM fact_orders
    WHERE order_status = 'Completed'
    GROUP BY sales_rep_id
)

-- STEP 4: Roll up everyone's sales to their root employee
SELECT
    et.root_employee_id AS employee_id,
    e.employee_name,
    SUM(COALESCE(eov.own_order_value, 0)) AS team_order_value
FROM employee_tree et
JOIN dim_employee e
    ON e.employee_id = et.root_employee_id
LEFT JOIN employee_order_value eov
    ON eov.employee_id = et.employee_id
GROUP BY
    et.root_employee_id,
    e.employee_name
ORDER BY
    et.root_employee_id
OPTION (MAXRECURSION 0);

/*
8.
The platform team is moving off nightly full reloads. You've been handed today's
batch in stg_orders_incr. Write a single MERGE that performs an incremental load into fact_orders:
update orders that changed, insert ones that are new. Acceptance criteria: one MERGE statement;
matched orders are updated (status and total) and new orders inserted; include a verification query
showing the fact_orders row count before versus after and a sample of updated rows.
*/

-- Before count
Select count(*) stg_orders_incr from stg_orders_incr
select count(*) fact_orders from fact_orders

/* =========================================
   1. ROW COUNT BEFORE MERGE
========================================= */

DECLARE @before_count INT;

SELECT @before_count = COUNT(*)
FROM fact_orders;


/* =========================================
   2. INCREMENTAL MERGE
========================================= */

DECLARE @merge_output TABLE
(
    action_type VARCHAR(10),
    order_id INT,
    order_status VARCHAR(50),
    order_total DECIMAL(18,2)
);

MERGE fact_orders AS o
USING stg_orders_incr AS soi
    ON o.order_id = soi.order_id

WHEN MATCHED
     AND (
         o.order_status <> soi.order_status
         OR o.order_total <> soi.order_total
     )
THEN
    UPDATE SET
        o.order_status = soi.order_status,
        o.order_total  = soi.order_total

WHEN NOT MATCHED BY TARGET
THEN
    INSERT
    (
        order_id,
        order_date,
        customer_id,
        sales_rep_id,
        order_status,
        order_total
    )
    VALUES
    (
        soi.order_id,
        soi.order_date,
        soi.customer_id,
        soi.sales_rep_id,
        soi.order_status,
        soi.order_total
    )

OUTPUT
    $action,
    inserted.order_id,
    inserted.order_status,
    inserted.order_total
INTO @merge_output;


/* =========================================
   3. ROW COUNT AFTER MERGE
========================================= */

DECLARE @after_count INT;

SELECT @after_count = COUNT(*)
FROM fact_orders;


/* =========================================
   4. BEFORE VS AFTER ROW COUNT
========================================= */

SELECT
    @before_count AS row_count_before,
    @after_count AS row_count_after;


/* =========================================
   5. SAMPLE OF UPDATED ROWS
========================================= */

SELECT TOP 10
    order_id,
    order_status,
    order_total
FROM @merge_output
WHERE action_type = 'UPDATE';


/* =========================================
   6. OPTIONAL: SEE INSERTED ROWS
========================================= */

SELECT TOP 10
    order_id,
    order_status,
    order_total
FROM @merge_output
WHERE action_type = 'INSERT';
    /*
    9.
The catalogue source now emits a change feed (cdc_product_changes) with
operation codes. Apply it to dim_product in a single MERGE that honours the codes: 
I inserts a new product, U updates an existing one, D deletes it. Acceptance criteria: 
one MERGE handling all three operations; 
include a verification query showing inserted, updated, and deleted products.
    */

/* =========================================================
   CDC PRODUCT CHANGES → DIM_PRODUCT
   I = INSERT
   U = UPDATE
   D = DELETE
========================================================= */

MERGE dim_product AS target
USING cdc_product_changes AS source
ON target.product_id = source.product_id

-- UPDATE existing product
WHEN MATCHED AND source.operation_code = 'U'
THEN
    UPDATE SET
        target.product_name = source.product_name,
        target.category_id = source.category_id,
        target.unit_price = source.unit_price,
        target.unit_cost = source.unit_cost,
        target.launch_date = source.launch_date

-- DELETE existing product
WHEN MATCHED AND source.operation_code = 'D'
THEN
    DELETE

-- INSERT new product
WHEN NOT MATCHED BY TARGET
     AND source.operation_code = 'I'
THEN
    INSERT
    (
        product_id,
        product_name,
        category_id,
        unit_price,
        unit_cost,
        launch_date
    )
    VALUES
    (
        source.product_id,
        source.product_name,
        source.category_id,
        source.unit_price,
        source.unit_cost,
        source.launch_date
    );



/* =========================================================
   VERIFICATION
========================================================= */

-- 1. Verify INSERTED products
SELECT
    c.product_id,
    c.product_name,
    c.operation_code
FROM cdc_product_changes AS c
WHERE c.operation_code = 'I'
  AND EXISTS
  (
      SELECT 1
      FROM dim_product AS p
      WHERE p.product_id = c.product_id
  );


-- 2. Verify UPDATED products
SELECT
    c.product_id,
    c.product_name,
    c.operation_code
FROM cdc_product_changes AS c
WHERE c.operation_code = 'U'
  AND EXISTS
  (
      SELECT 1
      FROM dim_product AS p
      WHERE p.product_id = c.product_id
  );


-- 3. Verify DELETED products
SELECT
    c.product_id,
    c.product_name,
    c.operation_code
FROM cdc_product_changes AS c
WHERE c.operation_code = 'D'
  AND NOT EXISTS
  (
      SELECT 1
      FROM dim_product AS p
      WHERE p.product_id = c.product_id
  );
