-- This test verifies that all employees in the hr_staff_current
-- table are present in the db_staff table.
select hsc._name
from {{ source('superside', 'hr_staff_current') }} as hsc
left join {{ source('superside', 'db_staff') }} as hds
    on hsc._name = hds._name
where hds._name is null
