-- **Business Question Q17** — SQL for Student B
-- Show Avg Data Quality by Country for 2023 and 2024.
-- Return Countries on rows and two columns—2023 and 2024 values of Avg Data Quality.

SET search_path TO dwh2_020;

SELECT
    c.country_name,
    AVG(CASE WHEN t.year_num = 2023 THEN f.data_quality_avg ELSE NULL END) AS "Avg_Data_Quality_2023",
    AVG(CASE WHEN t.year_num = 2024 THEN f.data_quality_avg ELSE NULL END) AS "Avg_Data_Quality_2024"
FROM ft_param_city_month AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
WHERE t.year_num IN (2023, 2024)
GROUP BY c.country_name
ORDER BY c.country_name;
