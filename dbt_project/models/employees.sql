SELECT
    hds.staff_id,
    hds._name AS employee_name,
    hds.username,
    hds.email AS employee_email,
    hsc._role AS job_title,
    hds._position AS job_code,
    case when len(hds.styles) = 0 then null else hds.styles end as styles,
    hds.industries,
    case when len(hds.software) = 0 then null else hds.software end as softwares,
    n.nationality_from_staff AS nationality,
    r.residence_from_staff AS country_of_residence,
    hsc.gender,
    hsc.birthday,
    hsc.business_group,
    hsc.personal_email,
    coalesce(hds.offboarded_at IS null, false) AS is_active
FROM
    {{source('superside', 'db_staff')}} AS hds
LEFT JOIN {{source('superside', 'hr_staff_current')}} AS hsc ON hds._name = hsc._name
LEFT JOIN {{ ref('nationalities') }} AS n
    ON
        hds.staff_id = n.staff_id
LEFT JOIN {{ ref('countries_of_residence') }} AS r ON hds.staff_id = r.staff_id
ORDER BY 1
