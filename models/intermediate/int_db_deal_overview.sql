{{ config(
    materialized='view',
    schema='smei'
) }}

-- 🔹 DEAL UNION
WITH deal_base AS (

    SELECT
        DDId AS deal_id,
        DealNo AS deal_no,
        RequestDate,
        ApprovalDate,
        NULL AS changerequestid
    FROM TYTexported.dbo.t_dealdetail

    UNION ALL

    SELECT
        DDAId AS deal_id,
        DealNo AS deal_no,
        RequestDate,
        ApprovalDate,
        AmendmentNo AS changerequestid
    FROM TYTexported.dbo.t_dealdetailamendment
),

-- 🔹 JOIN SOURCE TABLES
joined AS (

    SELECT
        d.*,
        a.DAId AS artist_project_id,
        a.ArtistName,
        a.LanguageName,
        a.DealType,
        a.Category,
        a.Genre,
        a.WriteUp,

        m.PartyName,
        m.IsSaved,
        m.DealTemplate

    FROM deal_base d

    LEFT JOIN TYTexported.dbo.t_dealartist a
        ON d.deal_no = a.DealNo

    LEFT JOIN TYTexported.dbo.t_dealmaster m
        ON d.deal_no = m.DealNo
),

-- 🔹 LOOKUP MAPPING (UPDATED)
mapped AS (

    SELECT
        j.*,

        lang.id  AS language_id,
        dtype.id AS type_id,
        tier.id  AS tier_id,
        genre.id AS genre_id,

        -- 🔥 NEW: deal_sub_type_id instead of entry_type_id
        etype.id AS deal_sub_type_id

    FROM joined j

    LEFT JOIN smei.met_lookup lang
        ON j.LanguageName = lang.[values] AND lang.type = 'met_language'

    LEFT JOIN smei.met_lookup dtype
        ON j.DealType = dtype.[values] AND dtype.type = 'met_deal_type'

    LEFT JOIN smei.met_lookup tier
        ON j.Category = tier.[values] AND tier.type = 'met_tier'

    LEFT JOIN smei.met_lookup genre
        ON j.Genre = genre.[values] AND genre.type = 'met_genre'

    LEFT JOIN smei.met_lookup etype
        ON j.DealTemplate = etype.[values] AND etype.type = 'met_entry_type'
)

-- 🔹 FINAL SELECT
SELECT

    -- 🔑 INTEGER db_id
    ROW_NUMBER() OVER (ORDER BY deal_id, artist_project_id) AS db_id,

    

    deal_id,
    artist_project_id,

    NULL AS business_unit,

    PartyName AS contractual_party,
    ArtistName AS artist_project_title,

    language_id,
    type_id,
    tier_id,
    genre_id,

    NULL AS nature_of_service,
    NULL AS licensee,

    -- 🔥 UPDATED FIELD
    deal_sub_type_id,

    NULL AS project_name,
    NULL AS production_house,
    NULL AS brand_name,
    NULL AS product_name,
    NULL AS campaign_name,
    NULL AS campaign_start_date,
    NULL AS campaign_end_date,
    NULL AS comissioning_entity_platform,
    NULL AS purpose,
    NULL AS restrictions,
    NULL AS primary_language,
    NULL AS type_of_product,
    NULL AS no_of_products,
    NULL AS deal_start_date,
    NULL AS term_of_deal,
    NULL AS deal_end_date,
    NULL AS company_name,
    NULL AS type_of_library,
    NULL AS application_name,

    TRY_CAST(RequestDate AS DATE)  AS submission_date,
    TRY_CAST(ApprovalDate AS DATE) AS approval_date,

    NULL AS type_of_service,
    NULL AS markup,
    NULL AS category,
    NULL AS no_of_titles,
    NULL AS parties,
    NULL AS proposed_business_of_jv,
    NULL AS resultant_shareholdings,
    NULL AS other_overview,

    WriteUp AS attachments,

    CASE 
        WHEN IsSaved = 1 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS status,

    -- 🔥 NEW v1.4 COLUMNS
    CAST(0 AS BIT) AS reimbursement_deal,
    CAST(NULL AS DECIMAL(18,2)) AS licensee_fee,
    CAST(NULL AS VARCHAR(500)) AS remarks,
    CAST(NULL AS VARCHAR(50)) AS revenuetype,

    GETDATE() AS updatedat,
    'system' AS updatedby

FROM mapped