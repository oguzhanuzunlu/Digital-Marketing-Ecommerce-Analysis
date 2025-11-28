

WITH fb_monthly AS (
  SELECT
    DATE_TRUNC('month', f.ad_date)::date AS month_start,
    LOWER(TRIM(COALESCE(fc.campaign_name, f.campaign_id))) AS campaign_key,
    SUM(COALESCE(f.reach,0))::bigint AS fb_monthly_reach
  FROM facebook_ads_basic_daily f
  LEFT JOIN facebook_campaign fc ON f.campaign_id = fc.campaign_id
  GROUP BY 1,2
),
ga_monthly AS (
  SELECT
    DATE_TRUNC('month', g.ad_date)::date AS month_start,
    LOWER(TRIM(COALESCE(g.campaign_name,''))) AS campaign_key,
    SUM(COALESCE(g.reach,0))::bigint AS ga_monthly_reach
  FROM google_ads_basic_daily g
  GROUP BY 1,2
),
monthly_combined AS (
  SELECT month_start, campaign_key, SUM(fb_monthly_reach) AS fb_reach, 0::bigint AS ga_reach
  FROM fb_monthly GROUP BY 1,2
  UNION ALL
  SELECT month_start, campaign_key, 0::bigint AS fb_reach, SUM(ga_monthly_reach) AS ga_reach
  FROM ga_monthly GROUP BY 1,2
),
monthly_agg AS (
  SELECT
    month_start,
    campaign_key,
    SUM(fb_reach) + SUM(ga_reach) AS monthly_reach
  FROM monthly_combined
  GROUP BY 1,2
),
with_lag AS (
  SELECT
    month_start,
    campaign_key,
    monthly_reach,
    monthly_reach - LAG(monthly_reach) OVER (PARTITION BY campaign_key ORDER BY month_start) AS monthly_growth
  FROM monthly_agg
)
SELECT
  TO_CHAR(month_start, 'YYYY-MM') AS ad_month,
  INITCAP(campaign_key) AS campaign_name,
  TO_CHAR(monthly_reach, 'FM9G999G999G999') AS monthly_reach,
  TO_CHAR(monthly_growth, 'FM9G999G999G999') AS monthly_growth
FROM with_lag
WHERE monthly_growth IS NOT NULL
  AND monthly_growth > 0    
ORDER BY monthly_growth::bigint DESC
LIMIT 1;