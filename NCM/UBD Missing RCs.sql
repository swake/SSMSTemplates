USE [UBD];

EXECUTE [dbo].[MissingRCs] 'VR1';

SELECT * FROM [dbo].[vDWDeployHistory] 
WHERE Environment = 'VR1'
ORDER BY DeployStart DESC;