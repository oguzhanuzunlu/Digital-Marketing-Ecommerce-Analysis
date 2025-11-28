

WITH combined_ads AS (
    SELECT ad_date, spend, value FROM facebook_ads_basic_daily
    UNION ALL
    SELECT ad_date, spend, value FROM google_ads_basic_daily
),
daily_romi AS (
    SELECT
        ad_date,
        SUM(value)::numeric AS total_value,
        SUM(spend)::numeric AS total_spend,
        CASE
            WHEN SUM(spend) = 0 THEN NULL
            ELSE SUM(value)::numeric / SUM(spend)::numeric
        END AS romi
    FROM combined_ads
    GROUP BY ad_date
)
SELECT
    ad_date,
    ROUND(romi, 2) AS romi
FROM daily_romi
WHERE romi IS NOT NULL
ORDER BY romi DESC
LIMIT 5;