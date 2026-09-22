-- 1. tabulka --

CREATE TABLE t_liliana_chundelova_project_sql_primary_final AS
WITH avg_prices AS (
SELECT  
	EXTRACT(YEAR FROM date_from)::int AS YEAR, 
	category_code, 
	round(avg(value)::NUMERIC, 2) AS avg_price
FROM
	czechia_price
GROUP BY
	EXTRACT(YEAR FROM date_from)::int,
	category_code 
), 
avg_payrolls AS (
SELECT
	industry_branch_code, 
	payroll_year AS YEAR, 
	round(avg(value)::NUMERIC, 2) AS avg_payroll
FROM
	czechia_payroll
WHERE
	value_type_code = 5958
	AND calculation_code = 200
GROUP BY
	payroll_year, 
	industry_branch_code 
) 
SELECT
	ap.avg_payroll, 
	ap.year, 
	ap.industry_branch_code,
	cpib.name AS industry_branch, 
	apr.avg_price, 
	apr.category_code,
	cprc.name AS product,
	e.gdp
FROM
	avg_prices apr
JOIN avg_payrolls ap 
	ON
	apr.year = ap.year
JOIN czechia_payroll_industry_branch cpib 
	ON
	ap.industry_branch_code = cpib.code
JOIN czechia_price_category cprc 
	ON
	apr.category_code = cprc.code
JOIN economies e 
	ON
	ap.year = e.year::int
	AND e.country = 'Czech Republic';
-- 2. tabulka --

CREATE TABLE t_liliana_chundelova_project_sql_secondary_final AS
SELECT
	country,
	gdp,
	population,
	gini,
	YEAR
FROM
	economies
WHERE
	lower(trim(country)) IN (
    'albania',
    'andorra',
    'austria',
    'belarus',
    'belgium',
    'bosnia and herzegovina',
    'bulgaria',
    'croatia',
    'cyprus',
    'czech republic',
    'denmark',
    'estonia',
    'finland',
    'france',
    'georgia',
    'germany',
    'greece',
    'hungary',
    'iceland',
    'ireland',
    'italy',
    'kazakhstan',
    'kosovo',
    'latvia',
    'liechtenstein',
    'lithuania',
    'luxembourg',
    'malta',
    'moldova',
    'monaco',
    'montenegro',
    'netherlands',
    'north macedonia',
    'norway',
    'poland',
    'portugal',
    'romania',
    'russian federation',
    'san marino',
    'serbia',
    'slovakia',
    'slovenia',
    'spain',
    'sweden',
    'switzerland',
    'turkey',
    'ukraine',
    'united kingdom'
)
	AND YEAR BETWEEN 2006 AND 2018;
--podklad pro odpověď na 1. otázku--

WITH clear_payroll AS (
SELECT
	DISTINCT
        YEAR,
	industry_branch,
	avg_payroll
FROM
	t_liliana_chundelova_project_sql_primary_final 
),
payroll_lag AS (
SELECT
	YEAR,
	industry_branch,
	avg_payroll,
	LAG(avg_payroll) OVER 
   		(PARTITION BY industry_branch
ORDER BY
	YEAR) AS previous_year_payroll
FROM
	clear_payroll
),
payroll_change AS (
SELECT
	YEAR,
	industry_branch,
	avg_payroll,
	previous_year_payroll,
	avg_payroll - previous_year_payroll AS payroll_difference
FROM
	payroll_lag
)
SELECT
	industry_branch,
	YEAR,
	avg_payroll,
	previous_year_payroll,
	payroll_difference
FROM
	payroll_change
WHERE
	payroll_difference <= 0
ORDER BY
	industry_branch,
	YEAR;
--podklad pro odpověď na 2. otázku--
--v jednotlivých odvětvích--

SELECT
	YEAR,
	industry_branch,
	product,
	round (avg_payroll / avg_price,
	2) AS product_per_wage
FROM
	t_liliana_chundelova_project_sql_primary_final
WHERE
	YEAR IN ('2006', '2018')
	AND category_code IN ('114201', '111301')
ORDER BY
	industry_branch;
--průměrem pro všechna odvětví--

WITH unique_wages AS (
SELECT
	DISTINCT
        YEAR,
	industry_branch,
	avg_payroll
FROM
	t_liliana_chundelova_project_sql_primary_final
WHERE
	YEAR IN (2006, 2018)
),
avg_wage AS (
SELECT
	YEAR,
	round(avg(avg_payroll), 2) AS avg_payroll
FROM
	unique_wages
GROUP BY
	YEAR
),
prices AS (
SELECT
	DISTINCT
        YEAR,
	product,
	avg_price
FROM
	t_liliana_chundelova_project_sql_primary_final
WHERE
	category_code IN ('111301', '114201')
		AND YEAR IN (2006, 2018)
)
SELECT
	p.year,
	p.product,
	round(aw.avg_payroll / p.avg_price, 2) AS product_per_wage
FROM
	prices p
JOIN avg_wage aw
    ON
	p.year = aw.year
ORDER BY
	p.year,
	p.product;
--podklad pro odpověď na 3.otázku--

WITH unique_prices AS (
SELECT
	DISTINCT
		YEAR,
		product,
		avg_price
FROM
	t_liliana_chundelova_project_sql_primary_final
),
price_lag AS (
SELECT
		YEAR,
		product,
		avg_price,
		LAG(avg_price) OVER (PARTITION BY product
ORDER BY
	YEAR
		) AS previous_price
FROM
	unique_prices
),
price_change AS (
SELECT
		YEAR,
		product,
		round(((avg_price - previous_price) / previous_price)* 100,
		2) AS percent_change
FROM
	price_lag
WHERE
	previous_price IS NOT NULL
)
SELECT 
	product,
	round(avg(percent_change), 2) AS avg_percent_change
FROM
	price_change
GROUP BY
	product
ORDER BY
	avg_percent_change;
--podklad pro odpověď na 4.otázku--
WITH unique_prices AS (
SELECT
	DISTINCT
		YEAR,
		product,
		avg_price
FROM
	t_liliana_chundelova_project_sql_primary_final
),
price_lag AS (
SELECT
		YEAR,
		product,
		avg_price,
		LAG(avg_price) OVER (PARTITION BY product
ORDER BY
	YEAR
		) AS previous_price
FROM
	unique_prices
),
price_change AS (
SELECT
		YEAR,
		product,
		round(((avg_price - previous_price) / previous_price)* 100,
		2) AS price_percent_change
FROM
	price_lag
WHERE
	previous_price IS NOT NULL
),
avg_price_change AS (
SELECT 
		YEAR,
		round(avg(price_percent_change), 2) AS avg_price_growth
FROM
	price_change
GROUP BY
	YEAR
),
unique_wages AS (
SELECT
	DISTINCT
		YEAR,
		avg_payroll,
		industry_branch
FROM
	t_liliana_chundelova_project_sql_primary_final
),
wage_lag AS (
SELECT
		YEAR,
		industry_branch,
		avg_payroll,
		LAG(avg_payroll) OVER (PARTITION BY industry_branch
ORDER BY
	YEAR
		) AS previous_wage
FROM
	unique_wages
),
wage_change AS (
SELECT
		YEAR,
		round(((avg_payroll - previous_wage) / previous_wage)* 100,
		2) AS wage_percent_change
FROM
	wage_lag
WHERE
	previous_wage IS NOT NULL
),
avg_wage_change AS (
SELECT 
		YEAR,
		round(avg(wage_percent_change), 2) AS avg_wage_growth
FROM
	wage_change
GROUP BY
	YEAR
)
SELECT 
	awc.year,
	awc.avg_wage_growth,
	apc.avg_price_growth,
	round(apc.avg_price_growth - awc.avg_wage_growth, 2) 
		AS difference
FROM
	avg_wage_change awc
JOIN avg_price_change apc
ON
	awc.year = apc.YEAR
WHERE
	(apc.avg_price_growth - awc.avg_wage_growth) > 10
ORDER BY
	YEAR;
--podklad pro odpověď na 5.otázku--
WITH unique_gdp AS (
SELECT
	DISTINCT
		YEAR,
		gdp
FROM
	t_liliana_chundelova_project_sql_primary_final
),
gdp_lag AS (
SELECT 
		YEAR,
		gdp,
		LAG(gdp) OVER (
	ORDER BY YEAR) AS previous_gdp
FROM
	unique_gdp
),
gdp_change AS (
SELECT 
		YEAR,
		round((((gdp - previous_gdp) / previous_gdp) * 100)::NUMERIC, 2)
			AS gdp_growth
FROM
	gdp_lag
WHERE
	previous_gdp IS NOT NULL 
),
unique_prices AS (
SELECT
	DISTINCT
		YEAR,
		product,
		avg_price
FROM
	t_liliana_chundelova_project_sql_primary_final
),
price_lag AS (
SELECT
		YEAR,
		product,
		avg_price,
		LAG(avg_price) OVER (PARTITION BY product
ORDER BY
	YEAR
		) AS previous_price
FROM
	unique_prices
),
price_change AS (
SELECT
		YEAR,
		product,
		round(((avg_price - previous_price) / previous_price)* 100,
		2) AS price_percent_change
FROM
	price_lag
WHERE
	previous_price IS NOT NULL
),
avg_price_change AS (
SELECT 
		YEAR,
		round(avg(price_percent_change), 2) AS avg_price_growth
FROM
	price_change
GROUP BY
	YEAR
),
unique_wages AS (
SELECT
	DISTINCT
		YEAR,
		avg_payroll,
		industry_branch
FROM
	t_liliana_chundelova_project_sql_primary_final
),
wage_lag AS (
SELECT
		YEAR,
		industry_branch,
		avg_payroll,
		LAG(avg_payroll) OVER (PARTITION BY industry_branch
ORDER BY
	YEAR
		) AS previous_wage
FROM
	unique_wages
),
wage_change AS (
SELECT
		YEAR,
		round(((avg_payroll - previous_wage) / previous_wage)* 100,
		2) AS wage_percent_change
FROM
	wage_lag
WHERE
	previous_wage IS NOT NULL
),
avg_wage_change AS (
SELECT 
		YEAR,
		round(avg(wage_percent_change), 2) AS avg_wage_growth
FROM
	wage_change
GROUP BY
	YEAR
)
SELECT
	gc.year,
	awc.avg_wage_growth,
	apc.avg_price_growth,
	gc.gdp_growth,
	LAG(gc.gdp_growth) OVER (
	ORDER BY gc.year) AS previous_year_gdp_growth
FROM
	gdp_change gc
JOIN avg_wage_change awc
    ON
	gc.year = awc.year
JOIN avg_price_change apc
    ON
	gc.year = apc.year
ORDER BY
	gc.year;
