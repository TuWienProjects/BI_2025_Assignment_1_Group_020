-- **Business Question Q10** — SQL for Student B
-- For 2024, show Exceed Days (any) by Region for Param Category = Gas.
-- Return Regions on rows and one column with Exceed Days (any) for the year 2024, filtered to Category = Gas.

SET search_path TO dwh2_020;

SELECT
    c.region_name,
    SUM(f.exceed_days_any) AS "Exceed_Days_2024"
FROM ft_param_city_month AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
JOIN dim_param AS p ON p.param_key = f.param_key
WHERE t.year_num = 2024
  AND p.category = 'Gas'
GROUP BY c.region_name
ORDER BY "Exceed_Days_2024" DESC;
