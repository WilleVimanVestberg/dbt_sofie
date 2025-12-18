{% macro trim_and_nullify(columns) %}
    {%- for col in columns %}
        NULLIF(TRIM({{ col }}), '')
    {%- endfor %}
{% endmacro %}