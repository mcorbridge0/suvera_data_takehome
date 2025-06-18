{% macro test_is_int(model, column_name) %}
SELECT *
FROM {{ model }}
WHERE REGEXP_MATCHES(CAST({{ column_name }} AS TEXT), '^-?[0-9]+$') = false
{% endmacro %}