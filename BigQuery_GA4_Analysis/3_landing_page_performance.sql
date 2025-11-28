
with user_sessions as (
  select
    user_pseudo_id ||
      cast((select value.int_value from unnest(event_params) where key = 'ga_session_id') as string)
      as user_session_id,
    regexp_extract(
      (select value.string_value from unnest(event_params) where key = 'page_location'),
      r'(?:\w+\:\/\/)?[^\/]+\/([^\?#]*)') as page_path,
    (select value.string_value from unnest(event_params) where key = 'page_location') as page_location
  from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
  where
    _table_suffix between '20200101' and '20201231'
    and event_name = 'session_start'
),


purchases as (
  select
    user_pseudo_id ||
      cast((select value.int_value from e.event_params where key = 'ga_session_id') as string)
      as user_session_id
  from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
  where
    _table_suffix between '20200101' and '20201231'
    and event_name = 'purchase'
)


select
  s.page_path,
  count(distinct(s.user_session_id)) as sessions_count,
  count(distinct(p.user_session_id)) as purchases_count,
  count(distinct(p.user_session_id))/count(distinct(s.user_session_id)) as cr_to_purhcase
from user_sessions s
left join purchases p using(user_session_id)
group by 1
order by 2 desc