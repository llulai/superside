WITH previous_roles AS (
    SELECT
        hds.staff_id AS employee_staff_id,
        hsm.date_of_mobility,
        hsm._name AS employee_name,
        hsm.previous_role AS job_title,
        hsc.start_date AS onboarding_date
    FROM
        {{ source('superside', 'hr_staff_mobility') }} AS hsm
    LEFT JOIN
        {{ source('superside', 'db_staff') }} AS hds
        ON
            hsm._name = hds._name
    LEFT JOIN {{ source('superside', 'hr_staff_current') }} AS hsc
        ON
            hsm._name = hsc._name
    WHERE
        hsm._name IS NOT NULL
        AND hsm.previous_role IS NOT NULL
),

current_roles AS (
    SELECT
        hds.staff_id AS employee_staff_id,
        TODAY() AS date_of_mobility,
        hds._name AS employee_name,
        hsc._role AS job_title,
        hsc.start_date AS onboarding_date
    FROM
        {{ source('superside', 'hr_staff_current') }} AS hsc
    LEFT JOIN
        {{ source('superside', 'db_staff') }} AS hds
        ON
            hsc._name = hds._name
),


raw_roles AS (
    SELECT *
    FROM previous_roles
    UNION
    SELECT *
    FROM current_roles
),


extended_roles AS (
    SELECT
        employee_staff_id,
        employee_name,
        job_title,
        onboarding_date,
        MAX(date_of_mobility) AS end_date
    FROM raw_roles
    GROUP BY
        1,
        2,
        3,
        4
    ORDER BY
        1,
        5 DESC
)

SELECT
    employee_staff_id,
    employee_name,
    job_title,
    COALESCE(
        LEAD(end_date) OVER (PARTITION BY employee_name ORDER BY end_date DESC),
        onboarding_date
    ) AS started_date,
    NULLIF(end_date, TODAY()) AS ended_date
FROM
    extended_roles
ORDER BY 1
