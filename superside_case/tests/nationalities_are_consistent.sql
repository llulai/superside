-- This test verifies that the nationalities are consistent
-- accross the hr_staff_current and db_staff tables.
select staff_id
from {{ ref('nationalities') }}
where not (
    list_has_all(nationality_from_staff, nationality_from_current)
    and list_has_all(nationality_from_current, nationality_from_staff)
)
