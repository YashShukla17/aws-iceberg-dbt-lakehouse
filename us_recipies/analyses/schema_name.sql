{% if execute %}
  {% for node in graph.nodes.values() %}
    {% if node.resource_type == 'model' %}
      -- {{ node.name }}
    {% endif %}
  {% endfor %}
{% endif %}
