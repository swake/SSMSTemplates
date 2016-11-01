USE [NCM_DataWarehouse]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [DDS].[trgDimMovie_InventoryUpdates] 
   ON  [DDS].[DimMovie]
   AFTER UPDATE
AS
-----------------------------------------------------------------------------------------------------------------------
-- Copyright (c) 2016, All Rights Reserved. This document contains data and information proprietary to
-- National Cinemedia. This data shall not be disclosed, disseminated, reproduced or otherwise used outside of the
-- facilities of National Cinemedia, without express written consent of an officer of the corporation.
-----------------------------------------------------------------------------------------------------------------------
--	NAME        : DDS.trgDimMovie_InventoryUpdates
--	CREATED BY  : SWake
--	DATE        : 2016-08-31
--	SYSTEM      : Data Warehouse
--	DESCRIPTION : Inserts rows to ETL.ChangedInventoryMovies for each Movie Updated that Inventory will need to reprocess
--	NOTES       : none
--	GRANTS      : none
-----------------------------------------------------------------------------------------------------------------------
--	VER:    DATE:       NAME:				DESCRIPTION OF CHANGE:
--	------- ----------- ---------------		-------------------------------------------------------------------------------
--	1.0     2016-08-31  SWake				Initial Creation
----------------------------------------------------------------------------------------------------------------------- 
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #changedMovie (MovieKey INT)

	-- Updates
	IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		INSERT INTO #changedMovie
		SELECT i.MovieKey
		FROM inserted i
		JOIN deleted d 
			ON i.MovieKey = d.MovieKey
		WHERE
			(
				i.ReleaseDateKey <> d.ReleaseDateKey
				OR i.NCMRating <> d.NCMRating
				OR i.MPAARating <> d.MPAARating
				OR i.Genre1 <> d.Genre1
				OR i.Genre2 <> d.Genre2
			)
	END

	-- Inserts
	--IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
	--BEGIN
	--	-- Insert Trigger Logic here, don't forget to update AFTER statement above to include INSERT
	--END

	-- Deletes
	--IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
	--BEGIN
	--	-- Delete Trigger Logic here, don't forget to update AFTER statement above to include DELETE
	--END

	-- Record the changes to DimMovie in the ETL table to be picked up by DW\DDS_Load_Inventory.dtsx
	INSERT INTO ETL.ChangedInventoryMovies (MovieKey)
	SELECT DISTINCT MovieKey 
	FROM #changedMovie
	
	EXCEPT
	
	SELECT MovieKey 
	FROM ETL.ChangedInventoryMovies

END
