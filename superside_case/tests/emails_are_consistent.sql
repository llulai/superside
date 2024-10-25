-- This test verifies that the email addresses are
-- consistent across the hr_staff_current and db_staff tables.
select hds.staff_id
from {{ source('superside', 'hr_staff_current') }} as hsc
inner join
    {{ source('superside', 'db_staff') }} as hds
    on hsc._name = hds._name
where hsc.email <> hds.email
