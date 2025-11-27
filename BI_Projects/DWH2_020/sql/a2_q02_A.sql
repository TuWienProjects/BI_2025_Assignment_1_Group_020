-- **Business Question Q2** — SQL for Student A
-- For parameter O3, show Missing Days in Austria by City × Month for Q1 of 2023.
-- Return Austrian Cities on rows and the first three months of 2023 (Jan–Mar) on columns.

SET search_path TO dwh2_020;

SELECT
    c.city_name,
    SUM(CASE WHEN t.month_num = 1 THEN f.missing_days ELSE 0 END) AS "Jan_2023",
    SUM(CASE WHEN t.month_num = 2 THEN f.missing_days ELSE 0 END) AS "Feb_2023",
    SUM(CASE WHEN t.month_num = 3 THEN f.missing_days ELSE 0 END) AS "Mar_2023"
FROM ft_param_city_month AS f
JOIN dim_timemonth AS t ON t.month_key = f.month_key
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_param AS p ON p.param_key = f.param_key
WHERE t.year_num = 2023
  AND p.param_name = 'O3'
  AND c.country_name = 'Austria'
  AND t.month_num BETWEEN 1 AND 3  -- Jan-Mar (Q1 of 2023)
GROUP BY c.city_name
ORDER BY c.city_name;
