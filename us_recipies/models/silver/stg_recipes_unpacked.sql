{{
  config(
    materialized = 'table'
  )
}}

with source as (
    select *
    from {{ source('bronze_recipes', 'recipes_unpacked_silver') }}
)
select distinct
    url,
    cuisine,
    cook_time,
    description,
    calories,
    carbohydratecontent,
    cholesterolcontent,
    fatcontent,
    fibercontent,
    proteincontent,
    saturatedfatcontent,
    sodiumcontent,
    sugarcontent,
    unsaturatedfatcontent,
    prep_time,
    rating,
    serves,
    title,
    total_time
from source 
where title != '"NaN"'

