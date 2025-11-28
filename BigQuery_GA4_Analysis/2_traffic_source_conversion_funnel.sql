
with cr_events as (
  select
    timestamp_micros(event_timestamp) as event_timestamp,
    event_name,
    user_pseudo_id ||
      cast((select value.int_value from e.event_params where key = 'ga_session_id') as string)
      as user_session_id,
    traffic_source.source,
    traffic_source.medium,
    traffic_source.name as campaign
  from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
  where
    event_name in ('session_start', 'add_to_cart', 'begin_checkout', 'purchase')
),
events_count as (
  select
    date(event_timestamp) as event_date,
    source,
    medium,
    campaign,
    count(distinct user_session_id) as user_sessions_count,
    count(distinct case when event_name = 'add_to_cart' then user_session_id end) as added_to_cart_count,
    count(distinct case when event_name = 'begin_checkout' then user_session_id end) as began_checkout_count,
    count(distinct case when event_name = 'purchase' then user_session_id end) as purchased_count
  from cr_events
  group by 1,2,3,4
)
select
  event_date,
  source,
  medium,
  campaign,
  user_sessions_count,
  added_to_cart_count / user_sessions_count as visit_to_cart,
  began_checkout_count / user_sessions_count as visit_to_checkout,
  purchased_count / user_sessions_count as visit_to_purchase,
from events_count
order by 1 desc