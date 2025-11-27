-- **Business Question Q4** — SQL for Student A
-- For 2024, show total Data Volume (KB) by Region × Quarter.
-- Return Regions on rows and the four quarters of 2024 (Q1–Q4) on columns.

SET search_path TO dwh2_020;

SELECT
    c.region_name,
    SUM(CASE WHEN t.quarter_num = 1 THEN f.data_volume_kb_sum ELSE 0 END) AS "Q1_2024",
    SUM(CASE WHEN t.quarter_num = 2 THEN f.data_volume_kb_sum ELSE 0 END) AS "Q2_2024",
    SUM(CASE WHEN t.quarter_num = 3 THEN f.data_volume_kb_sum ELSE 0 END) AS "Q3_2024",
    SUM(CASE WHEN t.quarter_num = 4 THEN f.data_volume_kb_sum ELSE 0 END) AS "Q4_2024"
FROM ft_param_city_month AS f
JOIN dim_timemonth AS t ON t.month_key = f.month_key
JOIN dim_city AS c ON c.city_key = f.city_key
WHERE t.year_num = 2024
GROUP BY c.region_name
ORDER BY c.region_name;
