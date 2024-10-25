WITH countries_from_staff AS (
    SELECT DISTINCT trim(residence) AS country_name
    FROM
        {{ source('superside', 'db_staff') }}
    UNION
    SELECT DISTINCT
        trim(unnest(string_split(replace(citizenship, '.', ','), ',')))
            AS country_name
    FROM
        {{ source('superside', 'db_staff') }}
    UNION
    SELECT DISTINCT trim(residence) AS country_name
    FROM
        {{ source('superside', 'hr_staff_current') }}
    UNION
    SELECT DISTINCT
        trim(unnest(string_split(replace(nationality, '.', ','), ',')))
            AS country_name
    FROM
        {{ source('superside', 'hr_staff_current') }}
    ORDER BY
        1
),

exact_match_countries AS (
    SELECT
        cfs.country_name,
        ic.name AS iso_name,
        ic.alpha_3 AS iso_code
    FROM
        countries_from_staff AS cfs
    LEFT JOIN {{ ref('iso_3166_countries') }} AS ic ON
        cfs.country_name = ic.name
),

similar_match_country AS (
    SELECT
        emc.country_name,
        ic.name AS iso_name,
        ic.alpha_3 AS iso_code,
        jaccard(replace(
            emc.country_name,
            'Republic',
            ''
        ),
        replace(
            ic.name,
            'Republic',
            ''
        )) AS similarity,
        row_number() OVER (
            PARTITION BY emc.country_name
            ORDER BY
                jaccard(replace(
                    emc.country_name,
                    'Republic',
                    ''
                ),
                replace(
                    ic.name,
                    'Republic',
                    ''
                )) DESC
        ) AS rank
    FROM
        exact_match_countries AS emc,
        {{ ref('iso_3166_countries') }} AS ic
    WHERE
        emc.iso_name IS NULL
    ORDER BY
        1,
        5
)

SELECT *
FROM
    exact_match_countries
WHERE
    iso_name IS NOT NULL
UNION
SELECT
    country_name,
    iso_name,
    iso_code
FROM
    similar_match_country
WHERE
    rank = 1
    AND similarity > 0.5
