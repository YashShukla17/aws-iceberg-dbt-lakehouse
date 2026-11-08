{{
  config(
    materialized = 'view',
    )
}}

with source as (
    select DISTINCT title, instruction from {{ source('silver_recipes', 'recipes_instructions') }}
)
select 
    {{dbt_utils.generate_surrogate_key(['title','instruction'])}} as id,
    title,
    instruction
from source