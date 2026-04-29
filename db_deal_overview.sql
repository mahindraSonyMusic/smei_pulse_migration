{{ config(
    materialized='incremental',
    incremental_strategy='append',
    schema='smei'
) }}

WITH src AS (

    SELECT TOP (500)

        CAST(db_id AS VARCHAR(53)) AS db_id,
        deal_id,
        artist_project_id,

        contractual_party,
        artist_project_title,

        language_id,
        type_id,
        tier_id,
        genre_id,

        attachments,

        TRY_CAST(submission_date AS DATE) AS submission_date,
        TRY_CAST(approval_date AS DATE) AS approval_date,

        status AS db_status,

        GETDATE() AS updatedat,
        updatedby,

        deal_id AS id,
        1 AS active,

        reimbursement_deal,
        deal_sub_type_id,

        CAST(licensee_fee AS INT) AS licensee_fee,
        CAST(NULL AS INT) AS remarks,
        CAST(NULL AS INT) AS revenuetype

    FROM {{ ref('int_db_deal_overview') }} src

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} t
        WHERE t.deal_id = src.deal_id
          AND t.artist_project_id = src.artist_project_id
    )

    ORDER BY deal_id
)

SELECT * FROM src