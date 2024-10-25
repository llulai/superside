{% test valid_industries(model, column_name, strict) %}

with parsed_industries as (
    select coalesce(list_has_all(list_value('Branding', 'Corporate', 'Film', 'Finance', 'Lifestyle', 'Marketing', 'Other', 'Technology'), {{ column_name }}), true) as is_valid,
           coalesce(len({{ column_name }}), false) = 0 as is_empty,
           {{ column_name }} is null as is_null
    from {{ model }}
)
select * from parsed_industries
where not is_valid
{% if strict %}
   or (is_empty and not is_null)
{% endif %}


{% endtest %}
