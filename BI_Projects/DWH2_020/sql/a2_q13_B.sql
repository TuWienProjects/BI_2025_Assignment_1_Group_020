-- **Business Question Q13** — SQL for Student B
-- For 2024, show Exceed Days (any) by City for Param Category = Particulate Matter.
-- Return Cities on rows and one column with the total Exceed Days for the year 2024, filtered to Category = Particulate Matter.

SET search_path TO dwh2_020;

SELECT
    c.city_name,
    SUM(f.exceed_days_any) AS "Exceed_Days_2024"
FROM ft_param_city_month AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
JOIN dim_param AS p ON p.param_key = f.param_key
WHERE t.year_num = 2024
  AND p.category = 'Particulate matter'
GROUP BY c.city_name
ORDER BY "Exceed_Days_2024" DESC;
