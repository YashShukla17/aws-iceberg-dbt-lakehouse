{{
  config(
    materialized = 'table',
    table_type = 'iceberg'
  )
}}

with silver_recipes as (
    -- We use ref() here because we are reading from the dbt model we just built, 
    -- not the raw PySpark source.
    select * from {{ ref('stg_recipes_unpacked') }}
)

select
    cuisine,
    count(title) as total_recipes,
    round(avg(rating), 2) as average_rating,
    -- Make sure numerical string columns are cast to doubles/integers before doing math
    round(avg(cast(trim(replace(calories, ' kcal', '')) as double)), 2) as avg_calories,
    
    round(avg(total_time), 0) as avg_total_time_mins
from silver_recipes
where cuisine is not null
group by cuisine
order by total_recipes desc