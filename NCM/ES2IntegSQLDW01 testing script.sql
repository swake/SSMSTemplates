USE [NCM_DataWarehouse]
GO

	DECLARE @DDSBatchId INT = 0
	DECLARE @FlightWeekKey INT = 20160301

	DECLARE @DDSObjectName				VARCHAR(500) = 'FactInventoryCapacity'
	DECLARE @EarliestInventoryDate		Date
	DECLARE @LatestInventoryDate		Date
	DECLARE @StartDateKey			INT
	DECLARE @EndDateKey			INT

	SELECT @EarliestInventoryDate = SettingValue FROM Admin.ETLSettings WHERE SettingName = 'Earliest Flight Start Date for Inventory'
	SELECT @LatestInventoryDate =  SettingValue FROM Admin.ETLSettings WHERE SettingName = 'Latest Flight End Date for Inventory'

	SELECT @FlightWeekKey AS FlightWeekKey, @EarliestInventoryDate AS EarliestInventoryDate, @LatestInventoryDate AS LatestInventoryDate
	
	SELECT @StartDateKey = min(d.datekey) 
		, @EndDateKey=max(d.datekey) 
	FROM DDS.DimFlightWeek fw 
	JOIN DDS.DimDate d on d.FlightWeekKey = fw.FlightWeekKey
	where fw.flightweekkey = @FlightWeekKey
	and d.[date] >= ISNULL(@EarliestInventoryDate,'10/2/2015') 
	and d.[date] <= ISNULL( @LatestInventoryDate, '1/1/9999') 

	SELECT @StartDateKey AS StartDateKey, @EndDateKey AS EndDateKey

	DECLARE @CurrentRunDateTime DATETIME2 = SYSDATETIME() 
	DECLARE @a TABLE 
	(
		ActionType					NVARCHAR(10)
		, InsertedPartitionKey		INT
		, DeletedPartitionKey		INT
	) 
	DECLARE @i BIGINT, @u BIGINT, @d BIGINT 

	DECLARE @Deleted AS BIGINT = 0;
	DECLARE @Inserted AS BIGINT = 0;
	DECLARE @BatchSize as INT = 100000;
	DECLARE @R			AS INT = 1;

	DROP TABLE #ICGs
	DROP TABLE #ICGInfo

	SELECT NaturalKey
	INTO #ICGs
	FROM DDS.DimInventoryGroup
	WHERE	ImpressionsProductCategory in  ('On-Screen', 'Promotions')
	OR		InventoryGroupName = 'Poster Cases'

	CREATE TABLE #ICGInfo
	(
		InventoryGroupKey	INT NOT NULL,
		InventoryCapacityGroupID VARCHAR(50) NOT NULL,
		InitialTheatreKey			INT NOT NULL,
		StdCapUnit			INT NOT NULL,
		StdCapTime			INT NOT NULL,
		MgdCapUnit			INT NOT NULL,
		MgdCapTime			INT NOT NULL,
		EffectiveStartDateKey	INT NOT NULL,
		EffectiveEndDateKey		INT NOT NULL
	)

	INSERT INTO #ICGInfo
	SELECT dig.InventoryGroupKey 
		, a.InventoryCapacityGroupId
	, dt.InitialTheatreKey
	, a.StdCapUnit, a.StdCapTime
	, a.MgdCapUnit, a.MgdCapTime
	,  CAST(CONVERT(VARCHAR(10), CAST(a.EffectiveStartDate as Date), 112) AS INT) as EffectiveStartDateKey
	,  CAST(CONVERT(VARCHAR(10), CAST(a.EffectiveEndDate as Date), 112) AS INT) as EffectiveEndDateKey
	FROM
	(
		SELECT	ic.InventoryCapacityGroupId
					, ISNULL(StandardCapacity,0) AS StdCapUnit
					, ISNULL(ManagedCapacity,0) AS MgdCapUnit
					, CASE WHEN IsTemporal = 1 THEN
						ISNULL(AvailUnit, 1) * ISNULL(StandardCapacity,0)
						ELSE 0
						END As StdCapTime
					, CASE WHEN IsTemporal = 1 THEN
						ISNULL(AvailUnit, 1) * ISNULL(ManagedCapacity,0)
						ELSE 0
						END As MgdCapTime
					, ISNULL(EffectiveStartDate, '1/1/1900') AS EffectiveStartDate
					, ISNULL(EffectiveEndDate, '1/1/9999') AS EffectiveEndDate
					, ISNULL(cc.LocationId,'0') AS LocationID
					, ROW_NUMBER() OVER (PARTITION BY ic.InventoryCapacityGroupId, cc.LocationId ORDER BY ic.InsertDateTime DESC) As RowNo
					, ISNULL(IsDeleted,0) AS IsDeleted
					
			FROM RDS.InventoryCapacityGroup ic join RDS.InventoryCapacityGroup_Location cc
			on ic.inventorycapacitygroupid = cc.inventorycapacitygroupid
			WHERE cc.LocationId <> '0'
			AND EXISTS
			(
				SELECT 1 
				FROM #ICGs i
				WHERE i.NaturalKey = ic.InventoryCapacityGroupId
			)
	) a
	JOIN DDS.DimInventoryGroup dig on dig.NaturalKey = a.InventoryCapacityGroupId
	JOIN DDS.DimTheatre dt on dt.NaturalKey = a.LocationID
	JOIN DDS.DimChain c 
		ON	c.ChainKey = dt.ChainKey
		AND c.ShortName != 'SVV' --Screenvision
	WHERE	a.RowNo = 1
		AND a.IsDeleted = 0
		AND dt.IsRowCurrent = 1
		AND	dt.Name NOT LIKE 'NCM Online Portfolio of Sites - Zip Code%'	--Exclude zipcode theatres for online products
		AND	dt.Name NOT LIKE 'NCM.COM Media Network%'	--Exclude fake DMA theatres
		AND c.IsRowCurrent = 1

	SELECT COUNT(*) AS ICGsCount FROM #ICGs
	SELECT * FROM #ICGs
	SELECT COUNT(*) AS ICGInfoCount FROM #ICGInfo
	SELECT * FROM #ICGInfo

	-- Insert location specific records
	--INSERT INTO 
	--	DDS.FactInventoryCapacity
	--	(	[RunDateKey]
	--		,InventoryGroupKey
	--		,InitialTheatreKey
	--		,StdCapUnit
	--		,StdCapTime
	--		,MgdCapUnit
	--		,MgdCapTime
	--		,[DDSBatchId]
	--		,[InsertDatetime]
	--	)
	SELECT 
		b.DateKey
		, a.InventoryGroupKey
		, a.InitialTheatreKey
		, a.StdCapUnit
		, a.StdCapTime
		, a.MgdCapUnit
		, a.MgdCapTime
		, @DDSBatchId AS DDSBatchId
		, @CurrentRunDateTime AS CurrentRunDateTime
	FROM #ICGInfo a
	JOIN (

		SELECT D.DateKey 
			, icgi.InventoryGroupKey
			, icgi.InitialTheatreKey
		FROM RDS.InventoryCapacityGroup icg1 join RDS.InventoryCapacityGroup_Location cc
		on icg1.InventoryCapacityGroupId = cc.InventoryCapacityGroupId
		-- for every date (limited below)
		CROSS JOIN DDS.DimDate d 
		-- And every theatre that is not fake DMA or online
		JOIN 
			(
			-- TODO: might need to limit by open / close date on theatres, but not included in this story.. hopefully panda has this in its logic
				SELECT l.InitialTheatreKey, l.NaturalKey, l.LocationSecondaryID
				FROM DDS.DimTheatre l
				JOIN DDS.DimChain c 
					ON	c.ChainKey = l.ChainKey
					AND c.ShortName != 'SVV' --Screenvision
				WHERE	l.IsRowCurrent = 1
				AND		l.Name NOT LIKE 'NCM Online Portfolio of Sites - Zip Code%'	--Exclude zipcode theatres for online products
				AND		l.Name NOT LIKE 'NCM.COM Media Network%'	--Exclude fake DMA theatres
				AND		l.LocationSecondaryID > 0 --Only Theatres with a secondary ID can be in PANDA/OLP and be inventory managed
				AND		c.IsRowCurrent = 1
			) t on t.NaturalKey = cc.LocationId
		JOIN #ICGInfo icgi on icgi.InventoryCapacityGroupId = icg1.InventoryCapacityGroupId 
			AND icgi.InitialTheatreKey = t.InitialTheatreKey
		WHERE	
			
			d.DateKey NOT IN (19000101, 99990101) 
				AND d.DateKey > =	@StartDateKey
				AND d.DateKey <=	@EndDateKey
				AND (d.DateKey >= icgi.EffectiveStartDateKey AND d.DateKey <= icgi.EffectiveEndDateKey)
			 AND ISNULL(icg1.IsDeleted,0) = 0 AND cc.LocationId <> '0' 
			AND EXISTS(
				SELECT 1
				FROM DDS.FactInventoryImpressions fii
				WHERE fii.InventoryGroupKey = icgi.InventoryGroupKey
					AND fii.DateKey = d.DateKey
					AND fii.TheatreKey = icgi.InitialTheatreKey
				)
			AND EXISTS
			(
				SELECT 1 
				FROM #ICGs i
				WHERE i.NaturalKey = icg1.InventoryCapacityGroupId
			)
			GROUP BY D.DateKey, icgi.InventoryGroupKey, icgi.InitialTheatreKey 
		) b on a.InventoryGroupKey = b.InventoryGroupKey and a.InitialTheatreKey = b.InitialTheatreKey 
	
	--SET @Inserted = @Inserted + ISNULL(@@ROWCOUNT,0)

	DROP TABLE #ICGAllTheatreInfo

	-- for all locations if location is not specified (0).  
	CREATE TABLE #ICGAllTheatreInfo
	(
		InventoryGroupKey	INT NOT NULL,
		InventoryCapacityGroupID VARCHAR(50) NOT NULL,
		StdCapUnit			INT NOT NULL,
		StdCapTime			INT NOT NULL,
		MgdCapUnit			INT NOT NULL,
		MgdCapTime			INT NOT NULL,
		EffectiveStartDateKey	INT NOT NULL,
		EffectiveEndDateKey		INT NOT NULL
	)

	INSERT INTO #ICGAllTheatreInfo
	SELECT dig.InventoryGroupKey 
		, a.InventoryCapacityGroupId
	, a.StdCapUnit, a.StdCapTime
	, a.MgdCapUnit, a.MgdCapTime
	,  CAST(CONVERT(VARCHAR(10), CAST(a.EffectiveStartDate as Date), 112) AS INT) as EffectiveStartDateKey
	,  CAST(CONVERT(VARCHAR(10), CAST(a.EffectiveEndDate as Date), 112) AS INT) as EffectiveEndDateKey
	FROM
	(
		SELECT	icg.InventoryCapacityGroupId
			, ISNULL(StandardCapacity,0) AS StdCapUnit
			, ISNULL(ManagedCapacity,0) AS MgdCapUnit
			, CASE WHEN IsTemporal = 1 THEN
				ISNULL(AvailUnit, 1) * ISNULL(StandardCapacity,0)
				ELSE 0
				END As StdCapTime
			, CASE WHEN IsTemporal = 1 THEN
				ISNULL(AvailUnit, 1) * ISNULL(ManagedCapacity,0)
				ELSE 0
				END As MgdCapTime
			, ISNULL(EffectiveStartDate, '1/1/1900') AS EffectiveStartDate
			, ISNULL(EffectiveEndDate, '1/1/9999') AS EffectiveEndDate
			, ISNULL(LocationId,'0') AS LocationID
			, ROW_NUMBER() OVER (PARTITION BY icg.InventoryCapacityGroupId, LocationId ORDER BY icg.InsertDateTime DESC) As RowNo
			, ISNULL(IsDeleted,0) AS IsDeleted
			FROM RDS.InventoryCapacityGroup icg join RDS.InventoryCapacityGroup_Location icgcc
			on icg.InventoryCapacityGroupId = icgcc.InventoryCapacityGroupId
			WHERE InventoryGroupName <> 'Poster Cases' -- TODO: Hardcoded this for RopeBridge.  Might want to make this a column in Enterprise.dbo.InventoryCapacityGroup
			AND ISNULL(LocationId,'0') = '0'
	) a
	JOIN DDS.DimInventoryGroup dig on dig.NaturalKey = a.InventoryCapacityGroupId
	WHERE a.RowNo = 1	
		AND a.IsDeleted = 0

	SELECT COUNT(*) AS ICGAllTheatreInfoCount FROM #ICGAllTheatreInfo
	SELECT * FROM #ICGAllTheatreInfo

	--INSERT INTO 
	--	DDS.FactInventoryCapacity
	--	(	[RunDateKey]
	--		,InventoryGroupKey
	--		,InitialTheatreKey
	--		,StdCapUnit
	--		,StdCapTime
	--		,MgdCapUnit
	--		,MgdCapTime
	--		,[DDSBatchId]
	--		,[InsertDatetime]
	--	)
	SELECT b.DateKey 
		, a.InventoryGroupKey
		, b.InitialTheatreKey
		, a.StdCapUnit
		, a.StdCapTime
		, a.MgdCapUnit
		, a.MgdCapTime
		, @DDSBatchId AS DDSBatchId
		, @CurrentRunDateTime AS CurrentRunDateTime
	FROM #ICGAllTheatreInfo a
	JOIN (

		SELECT D.DateKey 
			, icgi.InventoryGroupKey
			, t.InitialTheatreKey
		FROM RDS.InventoryCapacityGroup icg1
		-- for every date (limited below)
		CROSS JOIN DDS.DimDate d 
		-- And every theatre that is not fake dma or online
		CROSS JOIN 
			(
			-- TODO: might need to limit by open / close date on theatres, but not included in this story.. hopefully panda has this in its logic
				SELECT l.InitialTheatreKey, l.NaturalKey, l.LocationSecondaryID
				FROM DDS.DimTheatre l
				JOIN DDS.DimChain c 
					ON	c.ChainKey = l.ChainKey
					AND c.ShortName != 'SVV' --Screenvision
				WHERE	l.IsRowCurrent = 1
				AND		l.Name NOT LIKE 'NCM Online Portfolio of Sites - Zip Code%'	--Exclude zipcode theatres for online products
				AND		l.Name NOT LIKE 'NCM.COM Media Network%'	--Exclude fake dma theatres
				AND		l.LocationSecondaryID > 0 --Only Theatres with a secondary ID can be in PANDA/OLP and be inventory managed
				AND		c.IsRowCurrent = 1
			) t 
		JOIN #ICGAllTheatreInfo icgi on icgi.InventoryCapacityGroupId = icg1.InventoryCapacityGroupId 
		WHERE	
			
			d.DateKey NOT IN (19000101, 99990101) 
				AND d.DateKey > =	@StartDateKey
				AND d.DateKey <=	@EndDateKey
				AND (d.DateKey >= icgi.EffectiveStartDateKey AND d.DateKey <= icgi.EffectiveEndDateKey)
			 AND ISNULL(icg1.IsDeleted,0) = 0 
				AND icg1.InventoryGroupName <> 'Poster Cases'  -- TODO: Hardcoded this for RopeBridge.  Might want to make this a column in Enterprise.dbo.InventoryCapacityGroup
			AND EXISTS(
				SELECT 1
				FROM DDS.FactInventoryImpressions fii
				WHERE fii.InventoryGroupKey = icgi.InventoryGroupKey
					AND fii.DateKey = d.DateKey
					AnD fii.TheatreKey = t.InitialTheatreKey
		)
			GROUP BY D.DateKey, icgi.InventoryGroupKey, t.InitialTheatreKey
		) b on a.InventoryGroupKey = b.InventoryGroupKey 
		-- only if a value for this theatre/location/date has not already been inserted
		WHERE NOT EXISTS(

			SELECT 1
			FROM DDS.FactInventoryCapacity fic
			WHERE	fic.InventoryGroupKey = a.InventoryGroupKey
				AND fic.InitialTheatreKey = b.InitialTheatreKey
				AND fic.RunDateKey >= @StartDateKey
				AND fic.RunDateKey <= @EndDateKey
		)