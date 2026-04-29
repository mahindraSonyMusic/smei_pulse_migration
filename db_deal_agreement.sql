{{ config(
    materialized='incremental',
    unique_key='deal_id',
    incremental_strategy='merge',
    schema='smei'
) }}

WITH last_max AS (
    {% if is_incremental() %}
        SELECT ISNULL(MAX(deal_id), 0) AS max_id FROM {{ this }}
    {% else %}
        SELECT 0 AS max_id
    {% endif %}
),

-- 🔥 ONLY SMALL BATCH FROM INT
src AS (
    SELECT TOP (50)
        db_id,
        deal_id,
        artist_project_id,
        artist_project_title,
        entry_type_id,
        agreement_type_id,
        no_of_contract,
        db_status,
        updatedat,
        updatedby
    FROM {{ ref('int_db_deal_agreement') }}
    WHERE deal_id > (SELECT max_id FROM last_max)
    ORDER BY deal_id
)

SELECT
    db_id,
    deal_id,
    artist_project_id,
    artist_project_title,
    entry_type_id,
    agreement_type_id,
    no_of_contract,
    CAST(db_status AS VARCHAR(50)) AS db_status,
    updatedat,
    updatedby
FROM src