SET search_path TO dwh_020;

SELECT
  COUNT(*) AS missing_campaign_refs,
  CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'FAIL' END AS status_check,
  CURRENT_TIMESTAMP AS run_time
FROM ft_reading fr
LEFT JOIN dim_campaign dc ON fr.sk_campaign = dc.sk_campaign
WHERE fr.sk_campaign IS NOT NULL AND dc.sk_campaign IS NULL;
