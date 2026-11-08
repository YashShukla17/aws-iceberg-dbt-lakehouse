{% macro print_column_names(relation_name) %}
  {% set relation = ref(relation_name) %}

  {% set columns = adapter.get_columns_in_relation(relation) %}

  {% do log('columns for table:' ~ relation_name, info=true) %}
  {% do log('------------------------------------', info=true) %}

  {% for col in columns %}
    {% do log(col.name ~ ',', info=true) %}
  {% endfor %}
{% endmacro %}