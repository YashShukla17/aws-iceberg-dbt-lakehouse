{{
  config(
    materialized = 'view',
  )
}}

with source as (
    select DISTINCT title, ingredients
    from {{ source('silver_recipes', 'recipes_ingredients') }}
) 

select 
    {{ dbt_utils.generate_surrogate_key(['title', 'ingredients']) }} as id,
    title,
    ingredients
from source