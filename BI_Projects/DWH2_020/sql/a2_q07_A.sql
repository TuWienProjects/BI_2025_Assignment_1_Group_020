-- **Business Question Q7** — SQL for Student A
-- For 2023, show Avg Recorded Value and P95 Recorded Value by Country for PM10.
-- Return Countries on rows and two columns: Avg Recorded Value and P95 Recorded Value.

SET search_path TO dwh2_020;

SELECT
    c.country_name,
    AVG(f.recordedvalue_avg) AS "Avg_Recorded_Value_2023",
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY f.recordedvalue_avg) AS "P95_Recorded_Value_2023"
FROM ft_param_city_month AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
JOIN dim_param AS p ON p.param_key = f.param_key
WHERE t.year_num = 2023
  AND p.param_name = 'PM10'
GROUP BY c.country_name
ORDER BY "Avg_Recorded_Value_2023" DESC;
