-- **Business Question Q8** — SQL for Student A
-- For 2024, show Reading Events by Country × Quarter (Top 10 countries).
-- Return the four quarters on columns (Q1–Q4) and the Top 10 countries on rows, ranked by total Reading Events in 2024.

SET search_path TO dwh2_020;

SELECT
    c.country_name,
    SUM(CASE WHEN t.quarter_num = 1 THEN f.reading_events_count ELSE 0 END) AS "Q1_2024",
    SUM(CASE WHEN t.quarter_num = 2 THEN f.reading_events_count ELSE 0 END) AS "Q2_2024",
    SUM(CASE WHEN t.quarter_num = 3 THEN f.reading_events_count ELSE 0 END) AS "Q3_2024",
    SUM(CASE WHEN t.quarter_num = 4 THEN f.reading_events_count ELSE 0 END) AS "Q4_2024",
    SUM(f.reading_events_count) AS total_reading_events -- Add total reading events for ordering
FROM ft_param_city_month AS f
JOIN dim_city AS c ON c.city_key = f.city_key
JOIN dim_timemonth AS t ON t.month_key = f.month_key
WHERE t.year_num = 2024
GROUP BY c.country_name
ORDER BY total_reading_events DESC
LIMIT 10;
