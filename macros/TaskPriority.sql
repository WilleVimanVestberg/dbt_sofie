{% macro format_task_priority(col) %}
CASE
    WHEN {{ col }} = 'VÄLJ PRIORITET' THEN 'EJ ANGIVEN'
    WHEN {{ col }} LIKE 'Prio %' THEN UPPER(regexp_extract({{ col }}, '(Prio [0-9]+)', 1))
    ELSE COALESCE({{ col }}, 'Okänd')
END
{% endmacro %}
