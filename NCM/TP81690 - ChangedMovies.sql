WITH MoviesChanged AS
(
	SELECT m.[MovieKey]
	FROM [DDS].[DimMovie] m
	JOIN
	(
	SELECT lm.[MovieID]
		,lm.Genre1
		,lm.Genre2
		,lm.MPAARating
		,lm.NCMRating
		,lm.ReleaseDate
		,lm.VersionDateTime
	FROM 
	(
		SELECT MovieID
			,Genre1
			,Genre2
			,MPAARating
			,NCMRating
			,ReleaseDate
			,VersionDateTime
			,ROW_NUMBER() OVER(PARTITION BY MovieID ORDER BY VersionDateTime DESC) rn
		FROM [RDS].[Movie]
	) lm
	WHERE rn = 1
		AND VersionDateTime >= '2016-08-01'
	) s
		ON m.MovieKey = s.MovieID
	WHERE m.Genre1 COLLATE DATABASE_DEFAULT <> s.Genre1 COLLATE DATABASE_DEFAULT
		OR m.Genre2 COLLATE DATABASE_DEFAULT <> s.Genre2 COLLATE DATABASE_DEFAULT
		OR m.MPAARating COLLATE DATABASE_DEFAULT <> s.MPAARating COLLATE DATABASE_DEFAULT
		OR m.NCMRating COLLATE DATABASE_DEFAULT <> s.NCMRating COLLATE DATABASE_DEFAULT
		OR m.ReleaseDate <> s.ReleaseDate
)

SELECT DISTINCT Orderline_InvKey
FROM DDS.FactInventory
WHERE MovieKey IN (SELECT MovieKey FROM MoviesChanged)