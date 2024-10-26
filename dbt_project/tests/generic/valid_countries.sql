{% test valid_countries(model, column_name, strict) %}

with countries as (
    select array_agg(iso_3166_countries.alpha_3) as country_list from iso_3166_countries
),
 parsed_nationalities as (
    select coalesce(list_has_all(country_list, m.{{ column_name }}), true) as is_valid,
           coalesce(len(m.{{ column_name }}), false) = 0 as is_empty,
           m.{{ column_name }} is null as is_null
    from {{ model }} as m, countries
)
select * from parsed_nationalities
where not is_valid

{% if strict %}
   or (is_empty and not is_null)
{% endif %}


{% endtest %}
