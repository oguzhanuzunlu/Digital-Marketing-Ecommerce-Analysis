
select
  DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
  event_name,
  user_pseudo_id,
  (select value.int_value from e.event_params where key = 'ga_session_id') as session_id,
  geo.country,
  device.category as device_category,
  traffic_source.source,
  traffic_source.medium,
  traffic_source.name as campaign
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
where
  _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
  and event_name in ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'add_shipping_info', 'add_payment_info',  'purchase')