-- **Business Question Q6** — SQL for Student A
-- For 2024, list the Top 10 Cities by total Missing Days (all parameters).
-- Return the Top 10 cities on rows (highest → lowest) and one column with the total Missing Days for 2024.

SET search_path TO dwh2_020;

SELECT
    c.city_name,
    SUM(f.missing_days) AS "Total_Missing_Days_2024"
FROM (
    SELECT DISTINCT city_key, month_key, missing_days
    FROM ft_param_city_month
) AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
WHERE t.year_num = 2024
GROUP BY c.city_name
ORDER BY "Total_Missing_Days_2024" DESC
LIMIT 10;
