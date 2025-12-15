{% macro generate_latest_fields(columns) %}
    {%- for col in columns %}
        CASE WHEN is_latest_ack THEN {{ col }} END AS {{ col }}{% if not loop.last %},{% endif %}
    {%- endfor %}
{% endmacro %}
