

WITH bounds AS (
  SELECT
    (SELECT MIN(ad_date) FROM (
       SELECT ad_date FROM facebook_ads_basic_daily
       UNION ALL
       SELECT ad_date FROM google_ads_basic_daily
    ) t) AS min_date,
    (SELECT MAX(ad_date) FROM (
       SELECT ad_date FROM facebook_ads_basic_daily
       UNION ALL
       SELECT ad_date FROM google_ads_basic_daily
    ) t) AS max_date
),
calendar AS (
  SELECT generate_series(min_date, max_date, interval '1 day')::date AS cal_date
  FROM bounds
),
adset_names AS (
  SELECT DISTINCT adset_name FROM (
    SELECT adset_name FROM facebook_adset WHERE adset_name IS NOT NULL
    UNION
    SELECT DISTINCT adset_name FROM google_ads_basic_daily WHERE adset_name IS NOT NULL
  ) s
),
adset_calendar AS (
  SELECT n.adset_name, c.cal_date
  FROM adset_names n
  CROSS JOIN calendar c
),
activity AS (
  SELECT
    ac.adset_name,
    ac.cal_date,
    CASE
      WHEN EXISTS (
        SELECT 1
        FROM facebook_ads_basic_daily f
        LEFT JOIN facebook_adset fa ON f.adset_id = fa.adset_id
        WHERE COALESCE(fa.adset_name,'') = ac.adset_name
          AND f.ad_date = ac.cal_date
          AND (COALESCE(f.impressions,0) > 0 OR COALESCE(f.spend,0) > 0 OR COALESCE(f.reach,0) > 0)
      ) THEN 1
      WHEN EXISTS (
        SELECT 1
        FROM google_ads_basic_daily g
        WHERE COALESCE(g.adset_name,'') = ac.adset_name
          AND g.ad_date = ac.cal_date
          AND (COALESCE(g.impressions,0) > 0 OR COALESCE(g.spend,0) > 0 OR COALESCE(g.reach,0) > 0)
      ) THEN 1
      ELSE 0
    END AS is_active
  FROM adset_calendar ac
),
ordered AS (
  SELECT
    adset_name,
    cal_date,
    (cal_date - (ROW_NUMBER() OVER (PARTITION BY adset_name ORDER BY cal_date) * INTERVAL '1 day'))::date AS grp
  FROM activity
  WHERE is_active = 1
),
streaks AS (
  SELECT
    adset_name,
    MIN(cal_date) AS streak_start,
    MAX(cal_date) AS streak_end,
    COUNT(*) AS streak_length
  FROM ordered
  GROUP BY adset_name, grp
)
SELECT
  adset_name,
  streak_start,
  streak_end,
  streak_length
FROM streaks
ORDER BY streak_length DESC
LIMIT 1;