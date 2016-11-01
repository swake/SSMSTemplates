USE [NCM_DataWarehouse]
GO

/****** Object:  StoredProcedure [RDS].[p_FactTheatreMediaRevenueProjected]    Script Date: 1/21/2016 2:32:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [RDS].[p_FactTheatreMediaRevenueProjected]
(
	@FlightStartDate DATE,
	@FlightEndDate DATE
)

AS
---------------------------------------------------------------------------------------------------------------------
-- Copyright (c) 2013, All Rights Reserved. This document contains data and information proprietary to
-- National Cinemedia. This data shall not be disclosed, disseminated, reproduced or otherwise used outside of the
-- facilities of National Cinemedia, without express written consent of an officer of the corporation.
-----------------------------------------------------------------------------------------------------------------------
--	NAME        : RDS.p_FactTheatreMediaRevenueProjected
--	CREATED BY  : Milla Smirnova
--	DATE        : 2013-11-18
--	SYSTEM      : Data Warehouse
--	CALLED BY   : Multiple views
--	CALLS       : none
--	DESCRIPTION : View for obtaining the facts for media revenue
--	NOTES       : none
--	GRANTS      : none
--	USAGE		: execute rds.p_FactTheatreMediaRevenueProjected '05/01/2015', '05/07/2015'
-----------------------------------------------------------------------------------------------------------------------
--	VER:    DATE:       NAME:           DESCRIPTION OF CHANGE:
--	------- ----------- --------------- --------------------------------------------------------------------------------
--	1.0     2013-11-18  Milla Smirnova	Initial Creation
--	1.1		2013-12-16	Shannon Holck	Added Booked Period for TP#25809 Adjusted Legacy Orders
--  2.0		2013-12-27	Jim Reindel		Made changes for orderline version changes and adjustments
--	2.1		2013-12-31	Milla Smirnova	Changed adjustment orderline association to compensate for same day revisions from SMART
--  2.2     2014-01-05	Jim Reindel		Changed to use orderlines with DateTime2 versions vs date versions
--										Changed to do day spreading vs. using etl.OrderLineLocationDayEOB
--	2.3		2014-01-06	Milla Smirnova	Added ETL.ChangedAdvertisingOrderLines and 
--                                      "AND oll.StartDate <=  @FlightEndDate AND oll.EndDate >= @FlightStartDate"
--	2.4		2014-01-07	Jim Reindel		Correct bug due to bookings for orderlines not occurring in date order
--	2.5		2014-01-11	Jim Reindel		Added AccountDateKey using LSA logic
--  2.6		2014-01-13	Jim Reindel		Corrected logic that was eliminating all non-booked orderlines
--	2.7		2014-01-14	Jim Reindel		Made performance enhancements
--  2.8		2014-01-20	Jim Reindel		Changed counts for CPS and CPT to be based on the screen week vs. screen day
--	2.9		2014-01-22	Jim Reindel		Changed datatypes of returned count, rate anf revenue
--	3.0		2014-01-27	Marie Yue		Adding CPM Pricing -- search for 20140127 to find changes
--	3.1		2014-01-31  Marie Yue		Updating pull to use OrderlineDetail and new ETL table 
--  3.2		2014-02-03	Jim Reindel		Adding JobId pull from RDS to fact table
--  3.3     2014-02-03  Milla Smirnova  Added Join to (dds.DimDate ld) for performance
--  3.4		2014-02-19	Jim Reindel		Changed criteria for selecting the theatre version
--										Changed interpretation of CPM count to be in thousands
--  3.5     2014-02-21  Milla Smirnova  Added Join to (dds.DimDate d2) to avoid cast and added OPTION(RECOMPILE)
--  3.6     2014-02-25  Milla Smirnova  Added and old.AdjustmentId = '0' for CPM Pricing
--	3.7		2014-02-28	Jim Reindel		Added logic to handle location lookup for theatres added to CTD after a backdated booked date
--	3.8		2015-01-28	Jim Reindel		Added Account Director key for DimAccountDirector
--										Made performance enhancing changes 
--	3.9		2015-02-09	Jim Reindel		Modified to use the account directors as of closed periods for booked orders
--	4.0		2015-02-26	Jim Reindel		Added Regional AD to time-tracked orderline ADs
--	4.1		2015-03-16	Jim Reindel		Added logic to set the AD to the correct 'None' based on order scope where the order 
--										has no ADs or an adjustment moved an orderline into a closed period on a booked order
--	4.1		2015-03-12	Jim Reindel		Modified to use the connections as of closed periods for booked orders
--	4.2		2015-04-28	Jim Reindel		Added logic to calculate facts for cancellations for CPM priced orderlines from 
--										daily CPM pricing information when it exists
--	4.3		2015-09-30	Mike Givant		Modified for OrderlinePricing Process
--											Replaced CPM join with OLP join
--											Removed JobId
--											Removed FragmentKey
--											Added join to DimTheatre **no longer coming from ChangedAvertisingOrderlines
--											Replaced formulas for [Count], Rate, and Revenue since they are now being sourced from OLP
--	4.4		2015-10-27	Marc Beacom		Adjusted the rate logic to deal with a divide by zero error
--	4.5		2014-12-17	Keith Barritt	#69217 DW: Report Rate Card Rate and % of Rate Card Rate  Added RateCardValue and RateCardQuantity
--  4.6     2015-01-20  Steve Wake      Performance enhancements (lots of temp tables)
-----------------------------------------------------------------------------------------------------------------------

SET NOCOUNT ON;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

declare	@RevenueTypeKey_Non_LSA int = (select RevenueTypeKey from dds.DimRevenueType where RevenueTypeDescription = 'Non LSA');
declare	@RevenueTypeKey_LSA int = (select RevenueTypeKey from dds.DimRevenueType where RevenueTypeDescription = 'LSA');
declare @AccountDirectorKey_None_National int = isnull((select AccountDirectorKey from DDS.DimAccountDirector where BuyingAD = 'None' and ClientAD = 'None' and PlanningAD = 'None' and RegionalAD = 'Not Applicable'), -2)
declare @AccountDirectorKey_None_Regional int = isnull((select AccountDirectorKey from DDS.DimAccountDirector where BuyingAD = 'Not Applicable' and ClientAD = 'Not Applicable' and PlanningAD = 'Not Applicable' and RegionalAD = 'None'), -2)
declare @FlightKeyStart INT = DATEPART(year, @FlightStartDate) * 10000 + DATEPART(month, @FlightStartDate) * 100 + DATEPART(day, @FlightStartDate)
declare @FlightKeyEnd INT   = DATEPART(year, @FlightEndDate) * 10000 + DATEPART(month, @FlightEndDate) * 100 + DATEPART(day, @FlightEndDate)
declare @PeriodClosedDate DATE = ISNULL ((SELECT TOP 1 PeriodClosedDate FROM dds.DimFlight WHERE FlightStartDate <= @FlightEndDate AND FlightEndDate >= @FlightStartDate),'9999-01-01');

-- Provide metadata for SSIS (due to temp table in front of actual select)
IF 1 = 0
BEGIN
   SELECT
	[RunDateKey] = CAST( 0 AS [int]),
	[TheatreKey] = CAST( 0 AS [int]),
	[OrderlineKey] = CAST( 0 AS [int]),
	[BookedDateKey] = CAST( 0 AS [int]),
	[RevenueTypeKey] = CAST( 0 AS [int]),
	[DDSBatchId] = CAST( 0 AS [int]),
	[InsertDateTime]  = CAST( 0 AS [datetime]),
	[AccountingDateKey] = CAST( 0 AS [int]),
	[AccountDirectorKey]= CAST( 0 AS [int]),
	[ConnectionsKey] = CAST( 0 AS [int]),
	[COUNT]  = CAST( 0 AS [decimal](25, 15)),
	[Rate] = CAST( 0 AS [decimal](25, 15)),
	[Revenue] = CAST( 0 AS [decimal](25, 15)),
	[RateCardQuantity]= CAST( 0 AS [decimal](30, 15)),
	[RateCardValue]= CAST( 0 AS [decimal](30, 15))
END

--Build temp tables to increase performance

SELECT DISTINCT OrderlineId 
	,OrderlineSecondaryId 
INTO #ols
FROM ETL.ChangedAdvertisingOrderLines with (nolock)
WHERE LocationStartDate <= @FlightEndDate AND LocationEndDate >= @FlightStartDate

CREATE INDEX olsidx1 ON #ols (OrderlineSecondaryId, OrderlineId)

SELECT OrderLineSecondaryId 
	,OrderLineAdjustmentSecondaryId
	,LocationSecondaryId
	,DayId
	,Quantity = SUM(Quantity)
	,Impressions = SUM(Impressions)
	,Value = SUM(Value)
INTO #olp
FROM ENT.OrderLinePricing WITH (NOLOCK)
WHERE OrderLineSecondaryId  IN (SELECT OrderlineSecondaryId FROM #ols)
AND DayId BETWEEN @FlightKeyStart AND @FlightKeyEnd
	AND isActive = 1
GROUP BY OrderLineSecondaryId 
	,OrderLineAdjustmentSecondaryId
	,LocationSecondaryId
	,DayId

CREATE INDEX olpidx1 ON #olp (OrderLineSecondaryId, OrderLineAdjustmentSecondaryId, LocationSecondaryId, DayId)

SELECT [OrderLineId]
	,BrandAccountId
	,BrandAccountNAICSCode
	,BrandAccountName
	,BuyingAccountId
	,BuyingAccountNAICSCode
	,BuyingAccountName
INTO #olcs
FROM [ETL].[OrderLine_Connections]
WHERE OrderLineID IN (SELECT DISTINCT OrderlineId FROM #ols) 
	AND MasterVersionDate = '01/01/9999'

CREATE INDEX olcsidx1 ON #olcs (OrderLineId)

SELECT max(versiondatetime) as versiondatetime
	,locationid
	,locationsecondaryid
INTO #loc
from rds.location with (nolock)
where locationtype = 'Theatre'
group by locationid
	,locationsecondaryid

CREATE INDEX locidx1 ON #loc (locationsecondaryid)

select	MasterVersionDate = max(MasterVersionDate)
	,OrderlineId
INTO #OLC
from ETL.OrderLine_Connections with (nolock)
WHERE MasterVersionDate <= @PeriodClosedDate
GROUP BY OrderlineId

CREATE INDEX olcidx1 ON #OLC (OrderLineId)

select	MasterVersionDate = max(MasterVersionDate)
	,OrderlineId
INTO #OLAD
FROM ETL.OrderLine_ADs 
WHERE MasterVersionDate <= @PeriodClosedDate
GROUP BY OrderlineId 

CREATE INDEX oladidx1 ON #OLAD (OrderLineId)

--------------

SELECT	
RunDateKey,
		TheatreKey,
		OrderlineKey,
		BookedDateKey,
		RevenueTypeKey,
		CAST(0 AS INT) AS DDSBatchId,
		GETDATE() AS InsertDateTime,
		AccountingDateKey,
		AccountDirectorKey,
		ConnectionsKey,
		SUM([COUNT]) AS [COUNT],
		SUM(Rate) AS Rate,
		SUM(Revenue) AS Revenue,
		SUM(RateCardQuantity) AS RateCardQuantity,
		SUM(RateCardValue) AS RateCardValue
FROM   (

		SELECT
				RunDateKey = d.DateKey,
				olp.LocationSecondaryId,
				t.TheatreKey,
				dol.OrderlineKey,
				ISNULL(CONVERT(VARCHAR(8),old.BookedDate,112),'99990101') as BookedDateKey,
				LocationStartDate,
				RevenueTypeKey = 
					CASE WHEN old.BookedDate = '01/01/9999' THEN @RevenueTypeKey_Non_LSA
					ELSE CASE WHEN cd.DateKey < CONVERT(VARCHAR(8),old.BookedDate,112) THEN @RevenueTypeKey_LSA ELSE @RevenueTypeKey_Non_LSA END 
					END,
				--When the PeriodClosedDate of the flight of the RunDate is < the booked date of the order line 
				--then use for the accounting date, the first date of the flight whose PeriodClosedDate > the booked date of the order line
				--else use the Run Date for the accounting date
				AccountingDateKey = 
					CASE WHEN old.BookedDate = '01/01/9999' THEN d.DateKey 
					ELSE CASE WHEN cd.DateKey < CONVERT(VARCHAR(8),old.BookedDate,112) THEN old.EarliestOpenedDateKey ELSE d.DateKey END
					END,
				AccountDirectorKey = 
					CASE WHEN old.BookedDate = '01/01/9999' THEN isnull(dad.AccountDirectorKey, -3)
					ELSE isnull(dad_asof.AccountDirectorKey, case when olads.RegionalAD = 'Not Applicable' then @AccountDirectorKey_None_National else @AccountDirectorKey_None_Regional end)
					END,
				ConnectionsKey = 
					CASE WHEN old.BookedDate = '01/01/9999' THEN isnull(dc.ConnectionsKey, -3)
					ELSE isnull(dc_asof.ConnectionsKey, -3)
					END,
				[COUNT] = (CASE
							WHEN old.PriceType IN ('CPS','CPT') THEN CAST(ISNULL(olp.[Quantity] / 7, 0) AS DECIMAL (25,15))
							WHEN old.PriceType IN ('CPM','CPZ') THEN CAST(ISNULL(OLP.[Impressions], 0) AS DECIMAL (25,15))
							ELSE 0
						  END),
				Rate =	CAST(
						ISNULL(	CASE	
									WHEN dol.AdjustmentType = 'Cancellation' THEN 0
									WHEN old.PriceType IN ('CPS','CPT') and (ISNULL(olp.[Quantity], 0) = 0 or CAST((DATEDIFF(dd,old.LocationStartDate,old.LocationEndDate) + 1) AS FLOAT) = 0) THEN 0
									WHEN old.PriceType IN ('CPS','CPT') THEN ( CAST(olp.[Value] AS FLOAT) / olp.[Quantity] / CAST((DATEDIFF(dd,old.LocationStartDate,old.LocationEndDate) + 1) AS FLOAT) )
									WHEN old.PriceType IN ('CPM','CPZ') and ISNULL(olp.[Impressions], 0) = 0 THEN 0
									WHEN old.PriceType IN ('CPM','CPZ') THEN ( CAST(olp.[Value] AS FLOAT) / CAST(olp.[Impressions] AS FLOAT) ) * 1000
									ELSE 0
								END, 0) AS DECIMAL (25,15)),
				Revenue = CAST(ISNULL(OLP.[Value], 0) AS DECIMAL (25,15)),
				RateCardQuantity = (CASE
							WHEN old.PriceType IN ('CPS','CPT') THEN CAST(ISNULL((rc.RateCardQuantity) * DATEDIFF(wk,dol.OrderlineStartDate,dol.OrderlineEndDate), 0) AS DECIMAL (25,15))
							WHEN old.PriceType IN ('CPM','CPZ') THEN CAST(ISNULL((rc.RateCardQuantity), 0) AS DECIMAL (25,15))
							ELSE 0
						  END),
				RateCardValue = CAST(RateCardValue AS DECIMAL (30,15))
		FROM #olp olp  with (nolock)
		INNER JOIN #ols ols
				ON olp.OrderLineSecondaryId = ols.OrderlineSecondaryId
				--AND olp.DayId BETWEEN @FlightKeyStart AND @FlightKeyEnd
				
		INNER JOIN	ETL.ChangedAdvertisingOrderLines old with (nolock)
				ON old.OrderLineSecondaryId = olp.OrderLineSecondaryId
				AND ISNULL(old.OrderLineAdjustmentSecondaryId, 0) = ISNULL(olp.OrderLineAdjustmentSecondaryId, 0)
				--AND olp.isActive = 1

		--Join to get the current account directors for orderlines  
		LEFT JOIN ETL.OrderLine_ADs olads  with (nolock)
				ON	olads.OrderLineId = old.OrderlineId
				AND	olads.MasterVersionDate = '01/01/9999' 

		--Join to get the junk dimension key for the current account directors 
		LEFT JOIN DDS.DimAccountDirector dad  with (nolock)
				ON	dad.BuyingAD = olads.BuyingAD
				AND	dad.BuyingADIsPrimary = olads.BuyingADIsPrimary
				AND	dad.BuyingADRegionOrOffice = olads.BuyingADRegionOrOffice
				AND	dad.ClientAD = olads.ClientAD
				AND	dad.ClientADIsPrimary = olads.ClientADIsPrimary
				AND	dad.ClientADRegionOrOffice = olads.ClientADRegionOrOffice
				AND	dad.PlanningAD = olads.PlanningAD
				AND	dad.PlanningADIsPrimary = olads.PlanningADIsPrimary
				AND	dad.PlanningADRegionOrOffice = olads.PlanningADRegionOrOffice
				AND	dad.RegionalAD = olads.RegionalAD
				AND	dad.RegionalADRegionOrOffice = olads.RegionalADRegionOrOffice

		--Join to get the current connections for orderlines  
		LEFT JOIN #olcs olcs
			ON	olcs.OrderLineId = old.OrderlineId
			--AND	olcs.MasterVersionDate = '01/01/9999' 
	
		--Join to get the junk dimension key for the current connections
		LEFT JOIN DDS.DimConnections dc  with (nolock)
			ON	dc.BrandAccountId = olcs.BrandAccountId
			AND	dc.BrandAccountNAICSCode = olcs.BrandAccountNAICSCode
			AND	dc.BrandAccountName = olcs.BrandAccountName
			AND	dc.BuyingAccountId = olcs.BuyingAccountId
			AND	dc.BuyingAccountNAICSCode = olcs.BuyingAccountNAICSCode
			AND	dc.BuyingAccountName = olcs.BuyingAccountName
	
		--Join to get orderlineKey 
		JOIN	dds.DimOrderline dol  with (nolock)
				ON old.OrderlineId = dol.OrderlineId
				AND old.OrderlineAdjustmentId = dol.OrderlineAdjustmentId 
				AND dol.IsRowCurrent = 1 

		--Join to get latest Rate Card for Orderline		
		LEFT JOIN ETL.OrderlineRateCardValues rc with(nolock)  on dol.Orderlineid = rc.OrderlineId
			

		--Join to DimDate on a range to explode fact rows out to the day limiting to the 'flight' passed in 
		JOIN	dds.DimDate d  with (nolock)
				ON	d.[DateKey] = olp.DayId

		--FlightWeek of the date of play
		JOIN	dds.DimFlightWeek fw   with (nolock)
				ON	fw.FlightWeekKey = d.FlightWeekKey

		--Flight of the FlightWeek of the date of play
		JOIN	dds.DimFlight fl  with (nolock)
				ON	fl.FlightKey = fw.FlightKey

		--For the DateKey of the PeriodClosded date of the Flight of the date of play
		JOIN	dds.DimDate cd  with (nolock)
				ON cd.[Date] = fl.PeriodClosedDate

		----Joins to get the account directors for orderlines on national orders as of closed periods
        LEFT JOIN #OLAD max_olads_asof
				ON	max_olads_asof.OrderLineId = old.OrderlineId

		LEFT JOIN ETL.OrderLine_ADs olads_asof with (nolock)
				ON	olads_asof.OrderLineId = old.OrderlineId
				AND	olads_asof.MasterVersionDate = max_olads_asof.MasterVersionDate

		----Join to get the junk dimension key for the account directors as of closed periods
		LEFT JOIN DDS.DimAccountDirector dad_asof  with (nolock)
				ON	dad_asof.BuyingAD = olads_asof.BuyingAD
				AND	dad_asof.BuyingADIsPrimary = olads_asof.BuyingADIsPrimary
				AND	dad_asof.BuyingADRegionOrOffice = olads_asof.BuyingADRegionOrOffice
				AND	dad_asof.ClientAD = olads_asof.ClientAD
				AND	dad_asof.ClientADIsPrimary = olads_asof.ClientADIsPrimary
				AND	dad_asof.ClientADRegionOrOffice = olads_asof.ClientADRegionOrOffice
				AND	dad_asof.PlanningAD = olads_asof.PlanningAD
				AND	dad_asof.PlanningADIsPrimary = olads_asof.PlanningADIsPrimary
				AND	dad_asof.PlanningADRegionOrOffice = olads_asof.PlanningADRegionOrOffice
				AND	dad_asof.RegionalAD = olads_asof.RegionalAD
				AND	dad_asof.RegionalADRegionOrOffice = olads_asof.RegionalADRegionOrOffice

		----Joins to get the connections for orderlines as of closed periods
        LEFT JOIN #OLC max_olcs_asof
				ON	max_olcs_asof.OrderLineId = old.OrderlineId

		LEFT JOIN ETL.OrderLine_Connections olcs_asof with (nolock)
				ON	olcs_asof.OrderLineId = old.OrderlineId
				AND	olcs_asof.MasterVersionDate =  max_olcs_asof.MasterVersionDate

		--Join to get the junk dimension key for the connections as of closed period
		LEFT JOIN DDS.DimConnections dc_asof  with (nolock)
			ON	dc_asof.BrandAccountId = olcs_asof.BrandAccountId
			AND	dc_asof.BrandAccountNAICSCode = olcs_asof.BrandAccountNAICSCode
			AND	dc_asof.BrandAccountName = olcs_asof.BrandAccountName
			AND	dc_asof.BuyingAccountId = olcs_asof.BuyingAccountId
			AND	dc_asof.BuyingAccountNAICSCode = olcs_asof.BuyingAccountNAICSCode
			AND	dc_asof.BuyingAccountName = olcs_asof.BuyingAccountName

		JOIN #loc loc
			ON olp.LocationSecondaryId = loc.LocationSecondaryId

		JOIN	DDS.DimTheatre t with (nolock)
			ON	t.NaturalKey = loc.LocationId
			AND
				case 
					when isnull(old.BookedDate, '01/01/9999') <> '01/01/9999' then old.BookedDate
					else old.LocationStartDate 
				end 
			BETWEEN t.RowStartDate AND t.RowEndDate 
		
		WHERE old.LocationStartDate <= @FlightEndDate AND old.LocationEndDate >= @FlightStartDate

		) x

WHERE ( ABS([COUNT])+ABS(RATE)+ABS(Revenue) <> 0 )

GROUP BY RunDateKey, TheatreKey, OrderlineKey, BookedDateKey, RevenueTypeKey, AccountingDateKey, AccountDirectorKey, ConnectionsKey



OPTION (RECOMPILE);

;
;

GO


