WITH previous_managers AS (
    SELECT
        ds.staff_id as employee_staff_id,
        hsm.date_of_mobility,
        hsm._name as employee_name,
        hsm.previous_manager as manager_name,
        hsc.start_date AS onboarding_date
    FROM
        {{ source('superside', 'hr_staff_mobility') }} AS hsm
    LEFT JOIN {{ source('superside', 'db_staff') }} AS ds
        ON
            hsm._name = ds._name
    LEFT JOIN {{ source('superside', 'hr_staff_current') }} AS hsc
        ON
            hsm._name = hsc._name
    WHERE
        hsm._name IS NOT NULL AND hsm.previous_manager IS NOT NULL
),
current_managers AS (
    SELECT
        ds.staff_id as employee_staff_id,
        TODAY() AS date_of_mobility,
        ds._name as employee_name,
        hsc.manager_email as manager_name,
        hsc.start_date AS onboarding_date
    FROM
        {{ source('superside', 'hr_staff_current') }} AS hsc
    LEFT JOIN {{ source('superside', 'db_staff') }} AS ds ON
        hsc._name = ds._name
),

raw_managers AS (
    SELECT *
    FROM
        previous_managers
    UNION
    SELECT *
    FROM
        current_managers
),

extended_managers AS (
    SELECT
        employee_staff_id,
        employee_name,
        manager_name,
        onboarding_date,
        MIN(date_of_mobility) AS end_date
    FROM
        raw_managers
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
    ds.staff_id as manager_staff_id,
    manager_name,
    COALESCE(LEAD(
        end_date,
        1
    ) OVER (PARTITION BY employee_staff_id),
    onboarding_date) AS start_date,
nullif(end_date, today()) as end_date
FROM
    extended_managers as em left join {{ source('superside', 'db_staff')}} as ds on em.manager_name = ds._name
order by 1

