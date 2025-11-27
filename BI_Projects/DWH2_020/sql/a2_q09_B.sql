-- **Business Question Q9** — SQL for Student B
-- For 2024, list the Top 10 Countries by Avg Data Quality.
-- Return the 10 countries with the highest values on rows (highest → lowest) and one column with Avg Data Quality for 2024.

SET search_path TO dwh2_020;

SELECT
    c.country_name,
    AVG(f.data_quality_avg) AS "Avg_Data_Quality_2024"
FROM ft_param_city_month AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
WHERE t.year_num = 2024
GROUP BY c.country_name
ORDER BY "Avg_Data_Quality_2024" DESC
LIMIT 10;
