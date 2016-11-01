USE tempdb;
GO
DROP TABLE dbo.TestRethrow
SET XACT_ABORT ON
CREATE TABLE dbo.TestRethrow
(    ID INT PRIMARY KEY
);
BEGIN TRY
BEGIN TRANSACTION
    INSERT dbo.TestRethrow(ID) VALUES(1);
--  Force error 2627, Violation of PRIMARY KEY constraint to be raised.
    INSERT dbo.TestRethrow(ID) VALUES(1);
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
    PRINT 'In catch block.';
	
	IF (XACT_STATE()) <> 0
        ROLLBACK TRANSACTION;
	--THROW; 
END CATCH;