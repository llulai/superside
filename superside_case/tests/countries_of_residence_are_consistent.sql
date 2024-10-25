-- This test verifies that the country of residence are
-- consistent accross the hr_staff_current and db_staff tables.
select staff_id
from {{ ref('countries_of_residence') }}
where residence_from_staff <> residence_from_current
