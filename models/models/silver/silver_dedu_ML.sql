{{ config(
    materialized = "table",
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
    'dedu' AS source
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
    'rekyl' AS source
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

exploded AS(
    SELECT
      o.*,
      ack,
      pos,
      CASE WHEN pos = size(o.AcknowledgmentJournals) - 1 THEN true ELSE false END AS is_latest_ack
    FROM Dedu_union_selected o
    LATERAL VIEW OUTER POSEXPLODE(o.AcknowledgmentJournals) AS pos, ack
), 

per_update AS(
  SELECT
    update_row_id,
  -- -- Simple data cleaning of new columns
    NULLIF(TRIM(ack.CreatedBy), '') AS ack_CreatedBy,
    coalesce(
        try_to_timestamp(ack.CreatedDate, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
        try_to_timestamp(ack.CreatedDate, "yyyy-MM-dd'T'HH:mm:ss")
    ) AS ack_created_timestamp,
    NULLIF(TRIM(ack.CreatedDate), '') AS ack_CreatedDate,
    ack.DeduUserId AS ack_DeduUserId,
    ack.Id AS ack_Id,
    NULLIF(TRIM(ack.LastUpdated), '') AS ack_LastUpdated,
    NULLIF(TRIM(ack.LastUpdatedBy), '') AS ack_LastUpdatedBy,
    NULLIF(TRIM(ack.Message), '') AS ack_Message,
    ack.OrderNumber AS ack_OrderNumber,
    NULLIF(TRIM(ack.RegTime), '') AS ack_RegTime,
    NULLIF(TRIM(ack.Signature), '') AS ack_Signature,
    ack.Type AS ack_Type, 
    pos, 
    is_latest_ack,
    -- Keep order info only if last object in array (exception created by, date, lastupdated)
    LastUpdatedBy AS LastUpdatedBy,
    LatestWorkUpdate AS LatestWorkUpdate,
    Description AS Description,
    ElementDescription AS ElementDescription,
    ElementId AS ElementId,
    ElementName AS ElementName,
    GeoreferencedData AS GeoreferencedData,
    GuidId AS GuidId,
    OrderNumber AS OrderNumber,
    Placement AS Placement,
    PlannedDate AS PlannedDate,
    ProfessionId AS ProfessionId,
    ProfessionName AS ProfessionName,
    PropertyDescription AS PropertyDescription,
    PropertyId AS PropertyId,
    PropertyName AS PropertyName,
    PropertyName2 AS PropertyName2,
    RegTime AS RegTime,
    RegionDescription AS RegionDescription,
    RegionId AS RegionId,
    RegionName AS RegionName,
    SpaceId AS SpaceId,
    SpaceName AS SpaceName,
    SpatiSystemDescription AS SpatiSystemDescription,
    SpatiSystemId AS SpatiSystemId,
    SpatiSystemName AS SpatiSystemName,
    StructureDescription AS StructureDescription,
    StructureId AS StructureId,
    StructureName AS StructureName,
    TaskCategoryId AS TaskCategoryId,
    TaskCategoryName AS TaskCategoryName,
    TaskPriorityId AS TaskPriorityId,
    TaskPriorityName AS TaskPriorityName,
    TaskStatusFactor AS TaskStatusFactor,
    TaskStatusId AS TaskStatusId,
    TaskStatusName AS TaskStatusName,
    TaskSubCategoryId AS TaskSubCategoryId,
    TaskSubCategoryName AS TaskSubCategoryName,
    TaskTypeId AS TaskTypeId,
    TaskTypeName AS TaskTypeName,
    CAST(split(trim(both '()' FROM substring(GeoreferencedData.Geography.Wkt, 7)), ' ')[0] AS DOUBLE) AS longitude,
    CAST(split(trim(both '()' FROM substring(GeoreferencedData.Geography.Wkt, 7)), ' ')[1] AS DOUBLE) AS latitude,

  -- -- Metadata
    ingestion_id,
    timestamp_raw_ingestion,
    source_file,
    source
FROM exploded
), 

joined_forces AS (
  SELECT
    MAX(RegionId) AS RegionId, 
    MAX(ProfessionId) AS ProfessionId, 
    MAX(PropertyId) AS PropertyId, 
    MAX(TaskCategoryId) AS TaskCategoryId, 
    MAX(TaskTypeId) AS TaskTypeId, 
    MAX(TaskPriorityId) AS TaskPriorityId,
    ack_OrderNumber,
    MAX(CASE WHEN pos = 0 THEN ack_created_timestamp END) AS start_time,
    MAX(CASE WHEN is_latest_ack = TRUE THEN ack_created_timestamp END) AS end_time
  FROM per_update
  WHERE TaskStatusId = 62
  and ack_CreatedDate IS NOT NULL
  GROUP BY ack_OrderNumber--, TaskPriorityId --, ElementId
)

SELECT 
    *,  
    (unix_timestamp(end_time) - unix_timestamp(start_time)) / 3600.0 AS hours_diff

FROM joined_forces
where end_time >= start_time
and end_time <> start_time



-- first_recorded_time AS (
--     SELECT
--         update_row_id,
--         ack_OrderNumber,
--         CASE WHEN pos = 0 THEN ack_CreatedDate END AS start_time, 
--         ack_CreatedDate, 
--         pos, 
--         TaskStatusId, 
--         is_latest_ack

--     FROM per_update
-- ), 

-- last_recorded_time AS (
--     SELECT
--         update_row_id,
--         ack_OrderNumber,
--         CASE WHEN is_latest_ack THEN ack_CreatedDate END AS end_time,
--         ack_CreatedDate,
--         pos,
--         TaskStatusId,
--         is_latest_ack


--     FROM per_update
-- )

-- SELECT
--     s.update_row_id AS start_update_row_id,
--     e.update_row_id AS end_update_row_id,
--     s.start_time, -- s = start_time
--     e.end_time, -- e = end_time
--     e.ack_OrderNumber, 
--     e.TaskStatusId AS TaskStatusId

-- FROM first_recorded_time s
-- JOIN last_recorded_time e
-- ON s.ack_OrderNumber = e.ack_OrderNumber
-- WHERE e.TaskStatusID = 62
-- AND s.pos = 0, 
-- AND e.is_latest_ack
-- WHERE end_time IS NOT NULL


-- SELECT *
-- from per_update