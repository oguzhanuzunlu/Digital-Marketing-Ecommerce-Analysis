

WITH fb_norm AS (
  SELECT
    DATE_TRUNC('week', f.ad_date)::date AS week_start,
    LOWER(TRIM(COALESCE(fc.campaign_name, f.campaign_id))) AS campaign_key,
    SUM(COALESCE(f.value,0) + COALESCE(f.total,0))::numeric AS fb_weekly_sum
  FROM facebook_ads_basic_daily f
  LEFT JOIN facebook_campaign fc ON f.campaign_id = fc.campaign_id
  GROUP BY 1,2
),
ga_norm AS (
  SELECT
    DATE_TRUNC('week', g.ad_date)::date AS week_start,
    LOWER(TRIM(COALESCE(g.campaign_name, ''))) AS campaign_key,
    SUM(COALESCE(g.value,0))::numeric AS ga_weekly_sum
  FROM google_ads_basic_daily g
  GROUP BY 1,2
),
joined AS (
  SELECT
    COALESCE(f.week_start, g.week_start) AS week_start,
    COALESCE(f.campaign_key, g.campaign_key) AS campaign_key,
    COALESCE(f.fb_weekly_sum, 0) AS fb_weekly_sum,
    COALESCE(g.ga_weekly_sum, 0) AS ga_weekly_sum
  FROM fb_norm f
  FULL JOIN ga_norm g
    ON f.week_start = g.week_start
   AND f.campaign_key = g.campaign_key
)
SELECT
  week_start,
  INITCAP(campaign_key) AS campaign_name,
  TO_CHAR((fb_weekly_sum + ga_weekly_sum), 'FM9G999G999G999') AS weekly_value
FROM joined
ORDER BY (fb_weekly_sum + ga_weekly_sum) DESC
LIMIT 1;