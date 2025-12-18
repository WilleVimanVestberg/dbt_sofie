{% test null_count(model, column_name, max_allowed=0) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} IS NULL
HAVING COUNT(*) > {{ max_allowed }}

{% endtest %}
