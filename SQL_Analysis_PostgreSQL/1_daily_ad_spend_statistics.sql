

WITH fb AS (
    SELECT
        f.ad_date::date AS ad_date,
        'facebook'::text AS media_source,
        COALESCE(f.spend,0)::numeric AS spend,
        f.adset_id,
        f.campaign_id,
        a.adset_name,
        COALESCE(fc.campaign_name, f.campaign_id) AS campaign_name
    FROM facebook_ads_basic_daily f
    LEFT JOIN facebook_adset a ON f.adset_id = a.adset_id
    LEFT JOIN facebook_campaign fc ON f.campaign_id = fc.campaign_id
),
ga AS (
    SELECT
        g.ad_date::date AS ad_date,
        'google'::text AS media_source,
        COALESCE(g.spend,0)::numeric AS spend,
        NULL::text AS adset_id,
        NULL::text AS campaign_id,
        g.adset_name,
        COALESCE(g.campaign_name, 'google_unknown') AS campaign_name
    FROM google_ads_basic_daily g
),
all_media AS (
    SELECT * FROM fb
    UNION ALL
    SELECT * FROM ga
)
SELECT
    ad_date,
    media_source,
    ROUND(AVG(spend)::numeric, 2) AS avg_spend,
    ROUND(MAX(spend)::numeric, 2) AS max_spend,
    ROUND(MIN(spend)::numeric, 2) AS min_spend
FROM all_media
GROUP BY 1,2
ORDER BY ad_date, media_source;
