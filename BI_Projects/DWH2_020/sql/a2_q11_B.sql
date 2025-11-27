-- **Business Question Q11** — SQL for Student B
-- For 2024, show Exceed Days (any) by City × Monthly Peak Alert Level for Eastern Europe.
-- Return Cities in Eastern Europe on rows and the five Alert Levels on columns.

SET search_path TO dwh2_020;

SELECT
    c.city_name,
    ap.alert_level_name,
    SUM(f.exceed_days_any) AS "Exceed_Days_2024"
FROM ft_param_city_month AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
JOIN dim_alertpeak AS ap ON ap.alertpeak_key = f.alertpeak_key
WHERE t.year_num = 2024
  AND c.region_name = 'Eastern Europe'
GROUP BY c.city_name, ap.alert_level_name
ORDER BY
    CASE ap.alert_level_name
        WHEN 'None' THEN 1
        WHEN 'Yellow' THEN 2
        WHEN 'Orange' THEN 3
        WHEN 'Red' THEN 4
        WHEN 'Crimson' THEN 5
    END;
