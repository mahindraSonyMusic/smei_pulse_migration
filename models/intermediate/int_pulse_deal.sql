{{ config(
    materialized='view',
    schema='smei'
) }}

WITH base AS (

    -- 🔹 DEAL DETAIL
    SELECT
        DDId AS deal_id,
        CAST(DealNo AS INT) AS deal_no,
        VersionNo AS version,
        NULL AS changerequestid,

        RequestDate,
        SubmissionDate,
        ApprovalDate,
        PMSubmittedBy,

        'detail' AS src

    FROM TYTexported.dbo.t_dealdetail

    UNION ALL

    -- 🔹 DEAL AMENDMENT
    SELECT
        DDAId AS deal_id,
        CAST(DealNo AS INT) AS deal_no,
        AmendmentNo AS version,
        AmendmentNo AS changerequestid,

        RequestDate,
        SubmissionDate,
        ApprovalDate,
        PMSubmittedBy,

        'amendment' AS src

    FROM TYTexported.dbo.t_dealdetailamendment
),

master AS (

    SELECT
        DealNo,
        IsSaved
    FROM TYTexported.dbo.t_dealmaster
)

SELECT

    -- 🔹 CORE
    b.deal_id,
    b.deal_no,                     -- ✅ INT
    b.version,

    b.deal_id AS id,

    -- 🔹 STATUS (renamed)
    CASE 
        WHEN m.IsSaved = 1 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS dealstatus,

    -- 🔹 COMMENTS (renamed)
    CAST(NULL AS NVARCHAR(4000)) AS rejection_remark,

    -- 🔹 DATES
    b.RequestDate AS submission1_date,
    b.SubmissionDate AS submission2_date,
    b.ApprovalDate AS approval1_date,
    CAST(NULL AS DATETIME) AS approval2_date,

    -- 🔹 USERS
    b.PMSubmittedBy AS submission1_by,
    CAST(NULL AS NVARCHAR(200)) AS submission2_by,
    CAST(NULL AS NVARCHAR(200)) AS approval1_by,
    CAST(NULL AS NVARCHAR(200)) AS approval2_by,

    -- 🔹 REMARKS
    CAST(NULL AS NVARCHAR(2000)) AS approver1_remark,
    CAST(NULL AS NVARCHAR(2000)) AS approver2_remark,

    -- 🔹 CHANGE REQUEST
    b.changerequestid,

    -- 🔹 OPTIONAL
    CAST(NULL AS INT) AS contractid,

    -- 🔹 DATES
    CAST(GETDATE() AS DATE) AS created_date,
    CAST(NULL AS DATE) AS onhold_date,

    -- 🔹 AUDIT (NEW)
    'system' AS created_by,
    'system' AS updatedby,
    GETDATE() AS updatedat,

    -- 🔹 FLAG (NEW)
    CAST(1 AS BIT) AS isactive

FROM base b

LEFT JOIN master m
    ON b.deal_no = m.DealNo