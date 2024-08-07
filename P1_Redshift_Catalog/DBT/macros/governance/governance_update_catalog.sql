{% macro governance_update_catalog(table, procedure) %}
  {% if target.name != 'dev' %} 
    TRUNCATE TABLE {{table}};
    CALL {{procedure}} ();
  {% endif %} 
{% endmacro %}