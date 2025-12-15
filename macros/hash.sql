{% macro record_hash(columns) %}
    {{ dbt_utils.generate_surrogate_key(columns) }}
{% endmacro %}
