{% test valid_softwares(model, column_name, strict) %}

with parsed_softwares as (
    select coalesce(list_has_all(list_value('Illustrator', 'InDesign', 'Keynote', 'Other', 'Photoshop', 'PowerPoint', 'Shopify', 'SquareSpace'), {{ column_name }}), true) as is_valid,
           coalesce(len({{ column_name }}), false) = 0 as is_empty,
           {{ column_name }} is null as is_null
    from {{ model }}
)
select * from parsed_softwares
where not is_valid

{% if strict %}
   or (is_empty and not is_null)
{% endif %}


{% endtest %}
