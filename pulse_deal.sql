{{ config(
    materialized='incremental',
    incremental_strategy='append',
    schema='smei'
) }}

-- 🔹 Get last max
WITH last_max AS (
    {% if is_incremental() %}
        SELECT ISNULL(MAX(deal_id), 0) AS max_id FROM {{ this }}
    {% else %}
        SELECT 0 AS max_id
    {% endif %}
),

-- 🔹 Filter first, then limit
src AS (

    SELECT TOP (100) *

    FROM (
        SELECT

            deal_id,
            CAST(deal_no AS INT) AS deal_no,
            version,
            id,

            dealstatus,
            rejection_remark,

            submission1_date,
            submission2_date,
            approval1_date,
            approval2_date,

            submission1_by,
            submission2_by,
            approval1_by,
            approval2_by,

            approver1_remark,
            approver2_remark,

            changerequestid,
            contractid,

            onhold_date,

            GETDATE() AS updatedat,
            'system' AS updatedby,

            isactive

        FROM {{ ref('int_pulse_deal') }}

        WHERE deal_id > (SELECT max_id FROM last_max)

    ) s

    ORDER BY deal_id
)

SELECT * FROM src