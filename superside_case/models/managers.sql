SELECT
    hds.staff_id,
    hsc.manager_email AS manager_name,
    hsc2.email AS manager_email,
    hsc2._role AS manager_job_title,
    hsc._name AS report,
    hds2.staff_id AS report_staff_id
FROM {{ source('superside', 'hr_staff_current') }} AS hsc
LEFT JOIN
    {{ source('superside', 'db_staff') }} AS hds
    ON hsc.manager_email = hds._name
LEFT JOIN
    {{ source('superside', 'db_staff') }} AS hds2
    ON hsc._name = hds2._name
LEFT JOIN
    {{ source('superside', 'hr_staff_current') }} AS hsc2
    ON hsc.manager_email = hsc2._name
WHERE hds.staff_id IS NOT null
ORDER BY 1, 5
