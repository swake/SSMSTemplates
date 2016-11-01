-- BI Environments - #1
EXEC UBD.dbo.[CheckEnvironment] 'ES2SB';
EXEC UBD.dbo.[CheckEnvironment] 'DV1';
EXEC UBD.dbo.[CheckEnvironment] 'ES2INTEG';

--BI Environments - #2
EXEC UBD.dbo.[CheckEnvironment] 'ES1SB';
EXEC UBD.dbo.[CheckEnvironment] 'VR1';
EXEC UBD.dbo.[CheckEnvironment] 'ES1INTEG';

--BI Prod Support Environments
EXEC UBD.dbo.[CheckEnvironment] 'ES2CI';
EXEC UBD.dbo.[CheckEnvironment] 'ES2QA';

--BI Other Environments
EXEC UBD.dbo.[CheckEnvironment] 'ES1CI';
EXEC UBD.dbo.[CheckEnvironment] 'ES1QA';