-- **Business Question Q15** — SQL for Student B
-- Show Exceed Days (any) by Country in Eastern Europe for 2023 and 2024.
-- Return Countries (only those in Eastern Europe) on rows and two columns—2023 and 2024 totals of Exceed Days (any).

SET search_path TO dwh2_020;

SELECT
    c.country_name,
    SUM(CASE WHEN t.year_num = 2023 THEN f.exceed_days_any ELSE 0 END) AS "Exceed_Days_2023",
    SUM(CASE WHEN t.year_num = 2024 THEN f.exceed_days_any ELSE 0 END) AS "Exceed_Days_2024"
FROM ft_param_city_month AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
WHERE c.region_name = 'Eastern Europe'
GROUP BY c.country_name
ORDER BY c.country_name;
