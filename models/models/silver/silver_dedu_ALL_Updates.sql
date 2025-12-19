{{ config(
    materialized = "table",
    unique_key = "ack_Id",
    incremental_strategy = "merge"
) }}


WITH dedu_dedu AS (
  SELECT 
      AcknowledgmentJournals, 
      NULLIF(TRIM(CreatedBy), '') AS CreatedBy,
      NULLIF(TRIM(CreatedDate), '') AS CreatedDate,
      NULLIF(TRIM(Description), '') AS Description,
      NULLIF(TRIM(ElementDescription), '') AS ElementDescription,
      ElementId,
      NULLIF(TRIM(ElementName), '') AS ElementName,
      FileObjects,
      GeoreferencedData,
      NULLIF(TRIM(GuidId), '') AS GuidId,
      NULLIF(TRIM(LastUpdated), '') AS LastUpdated,
      NULLIF(TRIM(LastUpdatedBy), '') AS LastUpdatedBy,
      NULLIF(TRIM(LatestWorkUpdate), '') AS LatestWorkUpdate,
      OrderNumber,
      NULLIF(TRIM(Placement), '') AS Placement,
      NULLIF(TRIM(PlannedDate), '') AS PlannedDate,
      ProfessionId,
      NULLIF(TRIM(ProfessionName), '') AS ProfessionName,
      NULLIF(TRIM(PropertyDescription), '') AS PropertyDescription,
      PropertyId,
      NULLIF(TRIM(PropertyName), '') AS PropertyName,
      NULLIF(TRIM(PropertyName2), '') AS PropertyName2,
      NULLIF(TRIM(RegTime), '') AS RegTime,
      NULLIF(TRIM(RegionDescription), '') AS RegionDescription,
      RegionId,
      NULLIF(TRIM(RegionName), '') AS RegionName,
      NULLIF(TRIM(ReportedByCellPhone), '') AS ReportedByCellPhone,
      NULLIF(TRIM(ReportedByEmail), '') AS ReportedByEmail,
      NULLIF(TRIM(ReportedByName), '') AS ReportedByName,
      ReportedByNotified,
      NULLIF(TRIM(ReportedByNotifiedDate), '') AS ReportedByNotifiedDate,
      NULLIF(TRIM(ReportedByPhone), '') AS ReportedByPhone,
      ReportedBySendSms,
      NULLIF(TRIM(SpaceId), '') AS SpaceId,
      NULLIF(TRIM(SpaceName), '') AS SpaceName,
      NULLIF(TRIM(SpatiSystemDescription), '') AS SpatiSystemDescription,
      NULLIF(TRIM(SpatiSystemId), '') AS SpatiSystemId,
      NULLIF(TRIM(SpatiSystemName), '') AS SpatiSystemName,
      NULLIF(TRIM(StructureDescription), '') AS StructureDescription,
      StructureId,
      NULLIF(TRIM(StructureName), '') AS StructureName,
      TaskCategoryId,
      NULLIF(TRIM(TaskCategoryName), '') AS TaskCategoryName,
      TaskPriorityId,
      NULLIF(TRIM(TaskPriorityName), '') AS TaskPriorityName,
      TaskStatusFactor,
      TaskStatusId,
      NULLIF(TRIM(TaskStatusName), '') AS TaskStatusName,
      TaskSubCategoryId,
      NULLIF(TRIM(TaskSubCategoryName), '') AS TaskSubCategoryName,
      TaskTypeId,
      NULLIF(TRIM(TaskTypeName), '') AS TaskTypeName,
      TenantContactPersons,
      ingestion_id,
      timestamp_raw_ingestion,
      NULLIF(TRIM(source_file), '') AS source_file,
      'DEDU' AS source
    FROM {{ source('bronze', 'dedu_dedu') }}
),

dedu_rekyl AS (
  SELECT 
    AcknowledgmentJournals,
    NULLIF(TRIM(CreatedBy), '') AS CreatedBy,
    NULLIF(TRIM(CreatedDate), '') AS CreatedDate,
    NULLIF(TRIM(Description), '') AS Description,
    NULLIF(TRIM(ElementDescription), '') AS ElementDescription,
    ElementId,
    NULLIF(TRIM(ElementName), '') AS ElementName,
    FileObjects,
    GeoreferencedData,
    NULLIF(TRIM(GuidId), '') AS GuidId,
    NULLIF(TRIM(LastUpdated), '') AS LastUpdated,
    NULLIF(TRIM(LastUpdatedBy), '') AS LastUpdatedBy,
    NULLIF(TRIM(LatestWorkUpdate), '') AS LatestWorkUpdate,
    OrderNumber,
    NULLIF(TRIM(Placement), '') AS Placement,
    NULLIF(TRIM(PlannedDate), '') AS PlannedDate,
    ProfessionId,
    NULLIF(TRIM(ProfessionName), '') AS ProfessionName,
    NULLIF(TRIM(PropertyDescription), '') AS PropertyDescription,
    PropertyId,
    NULLIF(TRIM(PropertyName), '') AS PropertyName,
    NULLIF(TRIM(PropertyName2), '') AS PropertyName2,
    NULLIF(TRIM(RegTime), '') AS RegTime,
    NULLIF(TRIM(RegionDescription), '') AS RegionDescription,
    RegionId,
    NULLIF(TRIM(RegionName), '') AS RegionName,
    NULLIF(TRIM(ReportedByCellPhone), '') AS ReportedByCellPhone,
    NULLIF(TRIM(ReportedByEmail), '') AS ReportedByEmail,
    NULLIF(TRIM(ReportedByName), '') AS ReportedByName,
    ReportedByNotified,
    NULLIF(TRIM(ReportedByNotifiedDate), '') AS ReportedByNotifiedDate,
    NULLIF(TRIM(ReportedByPhone), '') AS ReportedByPhone,
    ReportedBySendSms,
    NULLIF(TRIM(SpaceId), '') AS SpaceId,
    NULLIF(TRIM(SpaceName), '') AS SpaceName,
    NULLIF(TRIM(SpatiSystemDescription), '') AS SpatiSystemDescription,
    NULLIF(TRIM(SpatiSystemId), '') AS SpatiSystemId,
    NULLIF(TRIM(SpatiSystemName), '') AS SpatiSystemName,
    NULLIF(TRIM(StructureDescription), '') AS StructureDescription,
    StructureId,
    NULLIF(TRIM(StructureName), '') AS StructureName,
    TaskCategoryId,
    NULLIF(TRIM(TaskCategoryName), '') AS TaskCategoryName,
    TaskPriorityId,
    NULLIF(TRIM(TaskPriorityName), '') AS TaskPriorityName,
    TaskStatusFactor,
    TaskStatusId,
    NULLIF(TRIM(TaskStatusName), '') AS TaskStatusName,
    TaskSubCategoryId,
    NULLIF(TRIM(TaskSubCategoryName), '') AS TaskSubCategoryName,
    TaskTypeId,
    NULLIF(TRIM(TaskTypeName), '') AS TaskTypeName,
    TenantContactPersons,
    ingestion_id,
    timestamp_raw_ingestion,
    NULLIF(TRIM(source_file), '') AS source_file,
    'REKYL' AS source
    FROM {{ source('bronze', 'dedu_rekyl') }}
),

dedu_union AS (
  SELECT * FROM dedu_dedu
  UNION ALL
  SELECT * FROM dedu_rekyl
),

Dedu_union_selected AS (  
    SELECT
        monotonically_increasing_id() AS update_row_id,
        u.*
    FROM dedu_union u
),

exploded AS (
  SELECT
    o.*,
    ack,
    pos,
    CASE 
        WHEN pos = size(o.AcknowledgmentJournals) - 1 
        THEN true 
        ELSE false 
    END AS is_latest_ack
  FROM Dedu_union_selected o
  LATERAL VIEW OUTER POSEXPLODE(o.AcknowledgmentJournals) AS pos, ack
),

--SELECTS ALL elements from AcknowledgementJournal to rows--

selected AS (
    SELECT
        update_row_id,
        -- Simple data cleaning of new columns
        NULLIF(TRIM(ack.CreatedBy), '') AS ack_CreatedBy,
        NULLIF(TRIM(ack.CreatedDate), '') AS ack_CreatedDate,
        coalesce(
          try_to_timestamp(ack.CreatedDate, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
          try_to_timestamp(ack.CreatedDate, "yyyy-MM-dd'T'HH:mm:ss")
        ) AS ack_created_timestamp,
        ack.DeduUserId AS ack_DeduUserId,
        ack.Id AS ack_Id,
        NULLIF(TRIM(ack.LastUpdated), '') AS ack_LastUpdated,
        NULLIF(TRIM(ack.LastUpdatedBy), '') AS ack_LastUpdatedBy,
        NULLIF(TRIM(ack.Message), '') AS ack_Message,
        ack.OrderNumber AS ack_OrderNumber,
        NULLIF(TRIM(ack.RegTime), '') AS ack_RegTime,
        NULLIF(TRIM(ack.Signature), '') AS ack_Signature,
        ack.Type AS ack_Type,
        {{ generate_latest_fields([
            'LastUpdatedBy',
            'LatestWorkUpdate',
            'Description',
            'ElementDescription',
            'ElementId',
            'ElementName',
            'GeoreferencedData',
            'GuidId',
            'OrderNumber',
            'Placement',
            'PlannedDate',
            'ProfessionId',
            'ProfessionName',
            'PropertyDescription',
            'PropertyId',
            'PropertyName',
            'PropertyName2',
            'RegTime',
            'RegionDescription',
            'RegionId',
            'RegionName',
            'SpaceId',
            'SpaceName',
            'SpatiSystemDescription',
            'SpatiSystemId',
            'SpatiSystemName',
            'StructureDescription',
            'StructureId',
            'StructureName',
            'TaskCategoryId',
            'TaskCategoryName',
            'TaskPriorityId',
            'TaskPriorityName',
            'TaskStatusFactor',
            'TaskStatusId',
            'TaskStatusName',
            'TaskSubCategoryId',
            'TaskSubCategoryName',
            'TaskTypeId',
            'TaskTypeName'
        ]) }},

        -- Keep order info only if last object in array (exception created by, date, lastupdated)
        CreatedBy,
        CreatedDate,
        LastUpdated,
        -- Metadata
        ingestion_id,
        timestamp_raw_ingestion,
        source_file,
        source
    FROM exploded
),

--dedup--
dedu_partitioned AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY ack_Id --, ack_LastUpdated, ack_Message, ack_Type
      ORDER BY LastUpdated
    ) AS rn
  FROM selected
),

dedu_dedup AS (
    SELECT
        *,
        CASE 
          WHEN MAX(CASE WHEN TaskStatusId = 62 THEN 1 ELSE 0 END)
              OVER (PARTITION BY OrderNumber 
                    ORDER BY ack_created_timestamp 
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) = 1
          THEN MIN(CASE WHEN TaskStatusId = 62 THEN ack_created_timestamp END)
              OVER (PARTITION BY OrderNumber)
        ELSE NULL
        END AS order_completed_timestamp
    FROM dedu_partitioned
    WHERE rn = 1
)

SELECT 
    -- {{ select_columns_except(all_columns, ['GeoreferencedData']) }}, --All except rn
     -- Acknowledgement info
  COALESCE(ack_CreatedBy, 'Okänd') AS ack_created_by,
  coalesce(
    try_to_timestamp(ack_CreatedDate, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    try_to_timestamp(ack_CreatedDate, "yyyy-MM-dd'T'HH:mm:ss")
  ) AS ack_created_timestamp,
  COALESCE(ack_DeduUserId, -1) AS ack_dedu_user_id,
  COALESCE(ack_Id, -1) AS ack_id,
  coalesce(
		try_to_timestamp(ack_LastUpdated, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
		try_to_timestamp(ack_LastUpdated, "yyyy-MM-dd'T'HH:mm:ss")
	) AS ack_last_updated_timestamp,
  COALESCE(ack_LastUpdatedBy, 'Okänd') AS ack_last_updated_by,
  COALESCE(ack_Message, 'Okänd') AS ack_message,
  COALESCE(ack_OrderNumber, -1) AS ack_order_number,
  coalesce(
		try_to_timestamp(ack_RegTime, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
		try_to_timestamp(ack_RegTime, "yyyy-MM-dd'T'HH:mm:ss")
	) AS ack_registered_timestamp,
  COALESCE(ack_Signature, 'Okänd') AS ack_signature,
  COALESCE(ack_type, -1) AS ack_type,

  -- Order info
  COALESCE(CreatedBy, 'Okänd') AS order_created_by,
  coalesce(
		try_to_timestamp(CreatedDate, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
		try_to_timestamp(CreatedDate, "yyyy-MM-dd'T'HH:mm:ss")
	) AS order_created_timestamp,
  coalesce(
		try_to_timestamp(LastUpdated, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
		try_to_timestamp(LastUpdated, "yyyy-MM-dd'T'HH:mm:ss")
	) AS order_last_updated_timestamp,
  COALESCE(LastUpdatedBy, 'Okänd') AS order_last_updated_by,
  coalesce(
		try_to_timestamp(LatestWorkUpdate, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
		try_to_timestamp(LatestWorkUpdate, "yyyy-MM-dd'T'HH:mm:ss")
	) AS order_latest_work_update_timestamp,
  COALESCE(Description, 'Okänd') AS order_description,
  COALESCE(ElementDescription, 'Okänd') AS order_element_description,
  COALESCE(ElementId, -1) AS order_element_id,
  COALESCE(ElementName, 'Okänd') AS order_element_name,
  COALESCE(GuidId, 'Okänd') AS order_guid_id,
  COALESCE(OrderNumber, -1) AS order_number,
  COALESCE(Placement, 'Okänd') AS order_placement_description,
  coalesce(
		try_to_timestamp(PlannedDate, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
		try_to_timestamp(PlannedDate, "yyyy-MM-dd'T'HH:mm:ss")
	) AS order_planned_timestamp,
  COALESCE(ProfessionId, -1) AS order_profession_id,
  COALESCE(ProfessionName, 'Okänd') AS order_profession_name,
  coalesce(
		try_to_timestamp(RegTime, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
		try_to_timestamp(RegTime, "yyyy-MM-dd'T'HH:mm:ss")
	) AS order_registered_timestamp,
  COALESCE(TaskCategoryId, -1) AS task_category_id,
  COALESCE(TaskCategoryName, 'Okänd') AS task_category_name,
  COALESCE(TaskPriorityId, -1) AS task_priority_id,
  CASE
    WHEN TaskPriorityName = 'VÄLJ PRIORITET' THEN 'EJ ANGIVEN'
    WHEN TaskPriorityName LIKE 'Prio %' 
        THEN UPPER(regexp_extract(TaskPriorityName, '(Prio [0-9]+)', 1))
    ELSE COALESCE(TaskPriorityName, 'Okänd') 
  END AS task_priority_name,
  CASE
    WHEN TaskPriorityName LIKE 'Prio %' THEN regexp_extract(TaskPriorityName, 'Prio [0-9]+ (.*)', 1)
    ELSE COALESCE(TaskPriorityName, 'Okänd')
  END AS task_priority_description,
  COALESCE(TaskStatusFactor, -1) AS task_status_factor,
  COALESCE(TaskStatusId, -1) AS task_status_id,
  COALESCE(TaskStatusName, 'Okänd') AS task_status_name,
  COALESCE(TaskSubCategoryId, -1) AS task_sub_category_id,
  COALESCE(TaskSubCategoryName, 'Okänd') AS task_sub_category_name,
  COALESCE(TaskTypeId, -1) AS task_type_id,
  COALESCE(TaskTypeName, 'Okänd') AS task_type_name,

  -- Property info
  COALESCE(PropertyDescription, 'Okänd') AS property_description,
  COALESCE(PropertyId, -1) AS dedu_property_id,
  COALESCE(PropertyName, 'Okänd') AS property_name,
  COALESCE(PropertyName2, 'Okänd') AS property_number,
  COALESCE(RegionDescription, 'Okänd') AS region,
  COALESCE(RegionId, -1) AS region_id,
  COALESCE(RegionName, 'Okänd') AS region_name,
  COALESCE(SpatiSystemDescription, 'Okänd') AS spati_system_description,
  COALESCE(SpatiSystemId, 'Okänd') AS spati_system_id,
  COALESCE(SpatiSystemName, 'Okänd') AS spati_system_name,
  COALESCE(StructureDescription, 'Okänd') AS structure_description,
  COALESCE(StructureId, -1) AS structure_id,
  COALESCE(StructureName, 'Okänd') AS structure_name,
  COALESCE(GeoreferencedData.Distance, 'Okänd') AS geo_distance,
  COALESCE(GeoreferencedData.Geography.CoordinateSystemId, -1) AS geo_coordinate_system_id,
  COALESCE(GeoreferencedData.Geography.Wkt, 'Okänd') AS geo_wkt,
  COALESCE(GeoreferencedData.Source, 'Okänd') AS geo_source,
  
  -- Metadata
  update_row_id AS update_row_id,
  ingestion_id AS ingestion_id,
  timestamp_raw_ingestion AS timestamp_raw_ingestion,
  source_file AS source_file,
  source AS source_system
  
    -- GeoreferencedData.Geography.Wkt AS wkt,
    -- order_completed_timestamp,
    -- DATEDIFF(
    --     CAST(order_completed_timestamp AS DATE),
    --     CAST(ack_created_timestamp AS DATE)
    -- ) AS days_to_completed,

    -- CAST(
    --     (UNIX_TIMESTAMP(order_completed_timestamp)
    --     - UNIX_TIMESTAMP(ack_created_timestamp)) / 3600
    --     AS INT
    -- ) AS hours_to_completed,

    -- CAST(split(trim(both '()' FROM substring(GeoreferencedData.Geography.Wkt, 7)), ' ')[0] AS DOUBLE) AS longitude,
    -- CAST(split(trim(both '()' FROM substring(GeoreferencedData.Geography.Wkt, 7)), ' ')[1] AS DOUBLE) AS latitude
FROM dedu_dedup












