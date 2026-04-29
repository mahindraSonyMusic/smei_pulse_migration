-- Custom helper macros for the project

{% macro generate_schema_name(custom_schema_name, node) -%}
    {# 
        Use custom schema if provided,
        otherwise fallback to target schema.
        This avoids duplication like smei_smei.
    #}
    {{ custom_schema_name if custom_schema_name else target.schema }}
{%- endmacro %}


{% macro get_current_timestamp() %}
    {# Returns the current timestamp for the database #}
    current_timestamp
{% endmacro %}


{% macro safe_divide(numerator, denominator, default_value=0) %}
    {# Safely divides two numbers, avoiding divide-by-zero errors #}
    case 
        when {{ denominator }} is null or {{ denominator }} = 0 
        then {{ default_value }}
        else {{ numerator }}::numeric / {{ denominator }}::numeric
    end
{% endmacro %}