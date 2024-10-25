WITH promotions_summary AS (
    SELECT
        employee_staff_id,
        count(*) - 1 AS times_promoted,
        max(end_date) AS last_promotion_date
    FROM
        {{ ref('promotions') }}
    GROUP BY
        1
),

managers_summary AS (
    SELECT
        manager_staff_id,
        count(*) AS n_reports
    FROM
        {{ ref('managers') }}
    WHERE end_date IS null
    GROUP BY
        1
),

employees_sumary AS (
    SELECT
        m.employee_staff_id,
        m.manager_staff_id,
        m.manager_name
    FROM {{ ref('managers') }} AS m
    WHERE m.end_date IS null
)

SELECT
    hds.staff_id,
    hds._name AS employee_name,
    hds.username,
    hds.email AS employee_email,
    hsc._role AS current_job_title,
    hds._position AS current_job_code,
    CASE WHEN len(hds.styles) = 0 THEN null ELSE hds.styles END AS styles,
    hds.industries,
    CASE WHEN len(hds.software) = 0 THEN null ELSE hds.software END
        AS softwares,
    n.nationality_from_staff AS nationality,
    r.residence_from_staff AS country_of_residence,
    hsc.gender,
    hsc.birthday,
    hsc.business_group,
    hsc.personal_email,
    coalesce(hds.offboarded_at IS null, false) AS is_active,
    ps.times_promoted,
    ps.last_promotion_date,
    hsc.start_date AS onboarding_date,
    coalesce(es.manager_name IS NOT null, false) AS has_manager,
    es.manager_staff_id,
    es.manager_name,
    coalesce(coalesce(ms.n_reports, 0) > 0, false)
        AS is_manager,
    coalesce(ms.n_reports, 0) AS n_reports
FROM
    {{ source('superside', 'db_staff') }} AS hds
LEFT JOIN
    {{ source('superside', 'hr_staff_current') }} AS hsc
    ON hds._name = hsc._name
LEFT JOIN {{ ref('nationalities') }} AS n
    ON
        hds.staff_id = n.staff_id
LEFT JOIN {{ ref('countries_of_residence') }} AS r ON hds.staff_id = r.staff_id
LEFT JOIN promotions_summary AS ps ON hds.staff_id = ps.employee_staff_id
LEFT JOIN managers_summary AS ms ON hds.staff_id = ms.manager_staff_id
LEFT JOIN employees_sumary AS es ON hds.staff_id = es.employee_staff_id
ORDER BY 1
