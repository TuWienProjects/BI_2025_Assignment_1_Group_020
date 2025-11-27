-- **Business Question Q1** — SQL for Student A
-- For parameter PM2, show Exceed Days (any) by Country × Month for Q1 of 2024.
-- Return Countries on rows and the first three months of 2024 (Jan–Mar) on columns.

SET search_path TO dwh2_020;

SELECT
    c.country_name,
    SUM(CASE WHEN t.month_num = 1 THEN f.exceed_days_any ELSE 0 END) AS "Jan_2024",
    SUM(CASE WHEN t.month_num = 2 THEN f.exceed_days_any ELSE 0 END) AS "Feb_2024",
    SUM(CASE WHEN t.month_num = 3 THEN f.exceed_days_any ELSE 0 END) AS "Mar_2024"
FROM ft_param_city_month AS f
JOIN dim_timemonth AS t ON t.month_key = f.month_key
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_param AS p ON p.param_key = f.param_key
WHERE t.year_num = 2024
  AND p.param_name = 'PM2'
  AND t.month_num BETWEEN 1 AND 3  -- Jan-Mar (Q1 of 2024)
GROUP BY c.country_name
ORDER BY c.country_name;
