WITH promotions_summary AS (
    SELECT
        staff_id,
        count(*) - 1 AS times_promoted,
        max(end_date) AS last_promotion_date,
        min(end_date) AS onboarding_date
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
    where end_date is null
    GROUP BY
        1
)

SELECT
    e.staff_id,
    e.employee_name,
    e.username,
    e.employee_email,
    e.job_title,
    e.job_code,
    e.styles,
    e.industries,
    e.softwares,
    e.nationality,
    e.country_of_residence,
    e.gender,
    e.birthday,
    e.business_group,
    e.personal_email,
    e.is_active,
    ps.times_promoted,
    ps.last_promotion_date,
    ps.onboarding_date
    /* m.staff_id AS manager_staff_id,
    m.manager_name,
    m.manager_email, */
    /* coalesce(m.manager_name IS NOT null, false) AS has_manager,
    coalesce(coalesce(ms.n_reports, 0) > 0, false)
        AS is_manager, */
    -- coalesce(ms.n_reports, 0) AS n_reports
FROM
    {{ ref('employees') }} AS e
LEFT JOIN promotions_summary AS ps ON e.staff_id = ps.staff_id
/* LEFT JOIN managers_summary AS ms ON e.staff_id = ms.staff_id
LEFT JOIN {{ ref('managers') }} AS m ON e.staff_id = m.report_staff_id */
ORDER BY 1
