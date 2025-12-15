{% macro select_columns_except(columns, exclude=[]) %}
    {# 
        columns: lista med kolumnnamn
        exclude: lista med kolumner som ska exkluderas
    #}
    {% set filtered = [] %}
    {% for col in columns %}
        {% if col not in exclude %}
            {% do filtered.append(col) %}
        {% endif %}
    {% endfor %}

    {{ filtered | join(', ') }}
{% endmacro %}
