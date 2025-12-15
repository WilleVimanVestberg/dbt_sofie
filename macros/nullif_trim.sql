{% macro trim_and_nullify(column_name) %}
    NULLIF(TRIM({{ column_name }}), '')
{% endmacro %}