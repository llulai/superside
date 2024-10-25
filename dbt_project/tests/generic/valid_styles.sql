{% test valid_styles(model, column_name, strict) %}

with parsed_styles as (
    select coalesce(list_has_all(list_value('Modern', 'Corporate', 'Minimalistic', 'Original', 'Other'), {{ column_name }}), true) as is_valid,
           coalesce(len({{ column_name }}), false) = 0 as is_empty,
           {{ column_name }} is null as is_null
    from {{ model }}
)
select * from parsed_styles
where not is_valid

{% if strict %}
   or (is_empty and not is_null)
{% endif %}


{% endtest %}
