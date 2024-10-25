WITH previous_managers AS (
    SELECT
        hds.staff_id AS employee_staff_id,
        hsm.date_of_mobility,
        hsm._name AS employee_name,
        hsm.previous_manager AS manager_name,
        hsc.start_date AS onboarding_date
    FROM {{ source('superside', 'hr_staff_mobility') }} AS hsm
    LEFT JOIN {{ source('superside', 'db_staff') }} AS hds
        ON
            hsm._name = hds._name
    LEFT JOIN {{ source('superside', 'hr_staff_current') }} AS hsc
        ON
            hsm._name = hsc._name
    WHERE
        hsm._name IS NOT NULL
        AND hsm.previous_manager IS NOT NULL
),

current_managers AS (
    SELECT
        hds.staff_id AS employee_staff_id,
        TODAY() AS date_of_mobility,
        hds._name AS employee_name,
        hsc.manager_email AS manager_name,
        hsc.start_date AS onboarding_date
    FROM {{ source('superside', 'hr_staff_current') }} AS hsc
    LEFT JOIN {{ source('superside', 'db_staff') }} AS hds ON
        hsc._name = hds._name
),


raw_managers AS (
    SELECT *
    FROM previous_managers
    UNION
    SELECT *
    FROM current_managers
),


extended_managers AS (
    SELECT
        employee_staff_id,
        employee_name,
        manager_name,
        onboarding_date,
        MAX(date_of_mobility) AS end_date
    FROM raw_managers
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
    ds.staff_id AS manager_staff_id,
    manager_name,
    COALESCE(
        LEAD(end_date) OVER (PARTITION BY employee_name ORDER BY end_date DESC),
        onboarding_date
    ) AS start_date,
    NULLIF(end_date, TODAY()) AS end_date
FROM
    extended_managers AS em
LEFT JOIN
    {{ source('superside', 'db_staff') }} AS ds
    ON em.manager_name = ds._name
ORDER BY 1
