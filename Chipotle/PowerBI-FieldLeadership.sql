SELECT SI.PKStoreID AS [StoreID]
	,SI.FKEntityID
	,S.StoreAddress
	,S.StoreCity
	,S.StoreState
	,S.StoreZip
    ,CASE WHEN S.StoreState = 'GB' THEN 'Great Britain' WHEN S.StoreState = 'ON' THEN 'Canada' WHEN S.StoreState = 'BC' THEN 'Canada' ELSE 'USA' END AS StoreCountry
	,COALESCE(SI.ATLEmpID,SI.AMEmpID,SI.TLEmpID,SI.TDEmpID) AS [FieldLeaderEmpID]
	,COALESCE(SI.ATLName,SI.[Area Mgr],SI.TeamLeader,SI.TeamDirector) AS [FieldLeaderName]
	,PD.ADDRESS1 AS FieldLeaderAddress
	,PD.CITY AS FieldLeaderCity
	,PD.[STATE] AS FieldLeaderState
	,PD.POSTAL AS FieldLeaderZip
	,PD.COUNTRY AS FieldLeaderCountry
	,CASE WHEN COALESCE(SI.RestaurateurEmpID,SI.Restaurateur2EmpID,SI.Restaurateur3EmpID,SI.Restaurateur4EmpID) IS NULL 
			THEN 0
			ELSE 1
	 END AS [Restaurateur]
	,CAST(S.Latitude AS decimal(14,11)) AS [Latitude]
	,CAST(S.Longitude AS decimal(14,11)) AS [Longitude]
	,EH.EntityLevel1 AS [Company]
	,EH.EntityLevel2 AS [InternationalorDomestic]
	,EH.EntityLevel3 AS Region
	,EH.EntityLevel4 AS [Sub-Region]
	,EH.EntityLevel6 AS [Market]
	,EH.EntityLevel7 AS [Patch]
FROM vwStoreInfo SI
INNER JOIN tblStores S
	ON SI.FKEntityID = S.FKEntityID
INNER JOIN tblEntityHierarchy EH
	ON SI.FKEntityID = EH.FKEntityID
LEFT OUTER JOIN HR.dbo.PS_PERSONAL_DATA PD
	ON COALESCE(SI.ATLEmpID,SI.AMEmpID,SI.TLEmpID,SI.TDEmpID) = PD.EMPLID
WHERE COALESCE(SI.ATLEmpID,SI.AMEmpID,SI.TLEmpID,SI.TDEmpID) IS NOT NULL
	AND S.OpenDate <= GETDATE() 
	AND S.CloseDate IS NULL 
	AND S.PKStoreID < 90000
	AND S.Latitude IS NOT NULL
	AND S.Longitude IS NOT NULL
	AND EH.EntityLevel1 IS NOT NULL
	AND EH.EntityLevel2 IS NOT NULL
	AND EH.EntityLevel3 IS NOT NULL
	AND EH.EntityLevel4 IS NOT NULL
	AND EH.EntityLevel5 IS NOT NULL
	AND EH.EntityLevel6 IS NOT NULL
	AND EH.EntityLevel7 IS NOT NULL
ORDER BY SI.AMEmpID
	,SI.PKStoreID
	,SI.FKEntityID