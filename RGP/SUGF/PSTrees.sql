use RGPWork
go

if exists
	(
	select
		o.object_id
	from
		sys.objects o
		inner join sys.schemas s on
			s.schema_id = o.schema_id
	where
		o.[name] = 'Trees'
		and s.name = 'PS'
	)
	drop table PS.Trees
go

create table PS.Trees
	(
	treeTypeName varchar(30) not null
	, treeName varchar(20) not null
	, treeDesc varchar(30) not null
	, effectiveDate date not null
	, obsoleteDate date not null
	, accountRangeMin varchar(30) null
	, accountRangeMax varchar(30) null
	, leafLevelNum int null
	, level1Name varchar(20) null
	, level1Desc varchar(30) null
	, level2Name varchar(20) null
	, level2Desc varchar(30) null
	, level3Name varchar(20) null
	, level3Desc varchar(30) null
	, level4Name varchar(20) null
	, level4Desc varchar(30) null
	, level5Name varchar(20) null
	, level5Desc varchar(30) null
	, level6Name varchar(20) null
	, level6Desc varchar(30) null
	, level7Name varchar(20) null
	, level7Desc varchar(30) null
	, level8Name varchar(20) null
	, level8Desc varchar(30) null
	, level9Name varchar(20) null
	, level9Desc varchar(30) null
	, level10Name varchar(20) null
	, level10Desc varchar(30) NULL
	)
go

create clustered index IX_Trees_name on PS.Trees
	(
	treeTypeName asc
	, treeName asc
	)
go

use RGPWork  
go

-- Load TreeNode data (replaces peoplesoft view)
declare @treeNode table
	(
	SETID char(5) null
	, TREE_NAME varchar(20) null
	, EFFDT datetime null
	, TREE_NODE_NUM int null
	, TREE_NODE varchar(20) null
	, TREE_BRANCH varchar(20) null
	, TREE_NODE_NUM_end int null
	, TREE_LEVEL_NUM smallint null
	, TREE_NODE_TYPE char(1) null
	, PARENT_NODE_NUM int null
	, PARENT_NODE_NAME varchar(20) null
	, DESCR varchar(30) null
	)

insert into
	@treeNode
select
	tn.SETID
	, tn.TREE_NAME
	, tn.EFFDT
	, tn.TREE_NODE_NUM
	, tn.TREE_NODE
	, tn.TREE_BRANCH
	, tn.TREE_NODE_NUM_end
	, tn.TREE_LEVEL_NUM
	, tn.TREE_NODE_TYPE
	, tn.PARENT_NODE_NUM
	, tn.PARENT_NODE_NAME
	, tnt.DESCR
from
	PS.PSTREENODE tn
	inner join PS.PS_TREE_NODE_TBL tnt on
		tnt.SETID = tn.SETID
		and tnt.TREE_NODE = tn.TREE_NODE
where
	tn.SETID = 'SHARE'
	and tnt.EFF_STATUS = 'A'
	and tnt.EFFDT = 
		(
		select	max(tntE.EFFDT)
		from	PS.PS_TREE_NODE_TBL tntE
		where	tntE.SETID = tnt.SETID
				and tntE.TREE_NODE = tnt.TREE_NODE
				and tntE.EFFDT < = tnt.EFFDT
		)

-- Load Trees
insert into
	PS.Trees
select
	treeTypeName
	, treeName
	, treeDesc
	, effectiveDate
	, isnull(obsoleteDate, cast('2999-01-01' as date)) as obsoleteDate
	, accountRangeMin
	, accountRangeMax
	, leafLevelNum
	, coalesce(level10Name,level9Name,level8Name,level7Name,level6Name,level5Name,level4Name,level3Name,level2Name,level1Name) as level10Name
	, coalesce(level10Desc,level9Desc,level8Desc,level7Desc,level6Desc,level5Desc,level4Desc,level3Desc,level2Desc,level1Desc) as level10Desc
	, coalesce(level9Name,level8Name,level7Name,level6Name,level5Name,level4Name,level3Name,level2Name,level1Name) as level9Name
	, coalesce(level9Desc,level8Desc,level7Desc,level6Desc,level5Desc,level4Desc,level3Desc,level2Desc,level1Desc) as level9Desc
	, coalesce(level8Name,level7Name,level6Name,level5Name,level4Name,level3Name,level2Name,level1Name) as level8Name
	, coalesce(level8Desc,level7Desc,level6Desc,level5Desc,level4Desc,level3Desc,level2Desc,level1Desc) as level8Desc
	, coalesce(level7Name,level6Name,level5Name,level4Name,level3Name,level2Name,level1Name) as level7Name
	, coalesce(level7Desc,level6Desc,level5Desc,level4Desc,level3Desc,level2Desc,level1Desc) as level7Desc
	, coalesce(level6Name,level5Name,level4Name,level3Name,level2Name,level1Name) as level6Name
	, coalesce(level6Desc,level5Desc,level4Desc,level3Desc,level2Desc,level1Desc) as level6Desc
	, coalesce(level5Name,level4Name,level3Name,level2Name,level1Name) as level5Name
	, coalesce(level5Desc,level4Desc,level3Desc,level2Desc,level1Desc) as level5Desc
	, coalesce(level4Name,level3Name,level2Name,level1Name) as level4Name
	, coalesce(level4Desc,level3Desc,level2Desc,level1Desc) as level4Desc
	, coalesce(level3Name,level2Name,level1Name) as level3Name
	, coalesce(level3Desc,level2Desc,level1Desc) as level3Desc
	, coalesce(level2Name,level1Name) as level2Name
	, coalesce(level2Desc,level1Desc) as level2Desc
	, level1Name
	, level1Desc
from
	(
	select
		case ts.DTL_RECNAME
			when 'DEPT_TBL' then 'Department'
			when 'FUND_TBL' then 'Fund'
			when 'GL_ACCOUNT_TBL' then 'Account'
			end as treeTypeName
		, td.TREE_NAME as treeName
		, td.DESCR as treeDesc
		, cast(td.EFFDT as date) as effectiveDate
		, (
			select	cast(min(td2.EFFDT) - 1 as date)
			from	PS.PSTREEDEFN td2
			where	td2.SETID = td.SETID
					and td2.SETCNTRLVALUE = td.SETCNTRLVALUE
					and td2.TREE_NAME = td.TREE_NAME
					and td2.EFFDT > td.EFFDT
			) as obsoleteDate
		, case isNumeric(tl.RANGE_FROM) when 1 then tl.RANGE_FROM else 0 end accountRangeMin
		, case isNumeric(tl.RANGE_TO) when 1 then tl.RANGE_TO else 0 end as accountRangeMax
		, tnleaf.TREE_LEVEL_NUM as leafLevelNum
		, case
			when tnleaf.TREE_LEVEL_NUM = 10 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 10 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 10 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 10 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 10 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 10 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 10 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 10 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 10 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 10 then tn1.TREE_NODE
			end as level10Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 10 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 10 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 10 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 10 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 10 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 10 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 10 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 10 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 10 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 10 then tn1.DESCR
			end as level10Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 9 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 9 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 9 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 9 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 9 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 9 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 9 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 9 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 9 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 9 then tn1.TREE_NODE
			end as level9Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 9 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 9 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 9 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 9 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 9 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 9 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 9 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 9 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 9 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 9 then tn1.DESCR
			end as level9Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 8 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 8 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 8 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 8 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 8 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 8 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 8 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 8 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 8 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 8 then tn1.TREE_NODE
			end as level8Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 8 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 8 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 8 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 8 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 8 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 8 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 8 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 8 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 8 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 8 then tn1.DESCR
			end as level8Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 7 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 7 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 7 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 7 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 7 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 7 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 7 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 7 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 7 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 7 then tn1.TREE_NODE
			end as level7Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 7 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 7 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 7 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 7 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 7 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 7 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 7 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 7 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 7 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 7 then tn1.DESCR
			end as level7Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 6 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 6 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 6 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 6 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 6 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 6 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 6 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 6 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 6 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 6 then tn1.TREE_NODE
			end as level6Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 6 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 6 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 6 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 6 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 6 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 6 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 6 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 6 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 6 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 6 then tn1.DESCR
			end as level6Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 5 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 5 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 5 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 5 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 5 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 5 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 5 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 5 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 5 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 5 then tn1.TREE_NODE
			end as level5Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 5 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 5 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 5 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 5 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 5 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 5 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 5 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 5 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 5 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 5 then tn1.DESCR
			end as level5Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 4 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 4 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 4 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 4 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 4 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 4 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 4 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 4 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 4 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 4 then tn1.TREE_NODE
			end as level4Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 4 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 4 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 4 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 4 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 4 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 4 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 4 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 4 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 4 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 4 then tn1.DESCR
			end as level4Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 3 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 3 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 3 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 3 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 3 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 3 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 3 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 3 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 3 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 3 then tn1.TREE_NODE
			end as level3Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 3 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 3 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 3 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 3 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 3 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 3 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 3 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 3 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 3 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 3 then tn1.DESCR
			end as level3Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 2 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 2 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 2 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 2 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 2 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 2 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 2 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 2 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 2 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 2 then tn1.TREE_NODE
			end as level2Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 2 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 2 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 2 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 2 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 2 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 2 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 2 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 2 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 2 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 2 then tn1.DESCR
			end as level2Desc
		, case
			when tnleaf.TREE_LEVEL_NUM = 1 then tnleaf.TREE_NODE
			when tn9.TREE_LEVEL_NUM = 1 then tn9.TREE_NODE when tn8.TREE_LEVEL_NUM = 1 then tn8.TREE_NODE when tn7.TREE_LEVEL_NUM = 1 then tn7.TREE_NODE
			when tn6.TREE_LEVEL_NUM = 1 then tn6.TREE_NODE when tn5.TREE_LEVEL_NUM = 1 then tn5.TREE_NODE when tn4.TREE_LEVEL_NUM = 1 then tn4.TREE_NODE
			when tn3.TREE_LEVEL_NUM = 1 then tn3.TREE_NODE when tn2.TREE_LEVEL_NUM = 1 then tn2.TREE_NODE when tn1.TREE_LEVEL_NUM = 1 then tn1.TREE_NODE
			end as level1Name
		, case
			when tnleaf.TREE_LEVEL_NUM = 1 then tnleaf.DESCR
			when tn9.TREE_LEVEL_NUM = 1 then tn9.DESCR when tn8.TREE_LEVEL_NUM = 1 then tn8.DESCR when tn7.TREE_LEVEL_NUM = 1 then tn7.DESCR
			when tn6.TREE_LEVEL_NUM = 1 then tn6.DESCR when tn5.TREE_LEVEL_NUM = 1 then tn5.DESCR when tn4.TREE_LEVEL_NUM = 1 then tn4.DESCR
			when tn3.TREE_LEVEL_NUM = 1 then tn3.DESCR when tn2.TREE_LEVEL_NUM = 1 then tn2.DESCR when tn1.TREE_LEVEL_NUM = 1 then tn1.DESCR
			end as level1Desc
	from
		PS.PSTREESTRCT ts
		inner join PS.PSTREEDEFN td on
			td.TREE_STRCT_ID = ts.TREE_STRCT_ID
		inner join PS.PSTREELEAF tl on
			tl.SETID = td.SETID
			and tl.TREE_NAME = td.TREE_NAME
		inner join @treeNode tnleaf on
			tnleaf.SETID = tl.SETID
			and tnleaf.TREE_NAME = tl.TREE_NAME
			and tnleaf.TREE_NODE_NUM = tl.TREE_NODE_NUM
			and tnleaf.EFFDT =
				(
				select	max(tn1ED.EFFDT)
				from	@treeNode tn1ED
				where	tn1ED.SETID = tnleaf.SETID
						and tn1ED.TREE_NAME = tnleaf.TREE_NAME
						and tn1ED.EFFDT <= tl.EFFDT
				)
		left outer join @treeNode tn9 on
			tn9.SETID = tnleaf.SETID
			and tn9.TREE_NAME = tnleaf.TREE_NAME
			and tn9.TREE_NODE_NUM = tnleaf.PARENT_NODE_NUM
			and tn9.EFFDT =
				(
				select	max(tn9ED.EFFDT)
				from	@treeNode tn9ED
				where	tn9ED.SETID = tnleaf.SETID
						and tn9ED.TREE_NAME = tnleaf.TREE_NAME
						and tn9ED.EFFDT <= tnleaf.EFFDT
				)
		left outer join @treeNode tn8 on
			tn8.SETID = tn9.SETID
			and tn8.TREE_NAME = tn9.TREE_NAME
			and tn8.TREE_NODE_NUM = tn9.PARENT_NODE_NUM
			and tn8.EFFDT =
				(
				select	max(tn8ED.EFFDT)
				from	@treeNode tn8ED
				where	tn8ED.SETID = tn9.SETID
						and tn8ED.TREE_NAME = tn9.TREE_NAME
						and tn8ED.EFFDT <= tn9.EFFDT
				)
		left outer join @treeNode tn7 on
			tn7.SETID = tn8.SETID
			and tn7.TREE_NAME = tn8.TREE_NAME
			and tn7.TREE_NODE_NUM = tn8.PARENT_NODE_NUM
			and tn7.EFFDT =
				(
				select	max(tn7ED.EFFDT)
				from	@treeNode tn7ED
				where	tn7ED.SETID = tn8.SETID
						and tn7ED.TREE_NAME = tn8.TREE_NAME
						and tn7ED.EFFDT <= tn8.EFFDT
				)
		left outer join @treeNode tn6 on
			tn6.SETID = tn7.SETID
			and tn6.TREE_NAME = tn7.TREE_NAME
			and tn6.TREE_NODE_NUM = tn7.PARENT_NODE_NUM
			and tn6.EFFDT =
				(
				select	max(tn6ED.EFFDT)
				from	@treeNode tn6ED
				where	tn6ED.SETID = tn7.SETID
						and tn6ED.TREE_NAME = tn7.TREE_NAME
						and tn6ED.EFFDT <= tn7.EFFDT
				)
		left outer join @treeNode tn5 on
			tn5.SETID = tn6.SETID
			and tn5.TREE_NAME = tn6.TREE_NAME
			and tn5.TREE_NODE_NUM = tn6.PARENT_NODE_NUM
			and tn5.EFFDT =
				(
				select	max(tn5ED.EFFDT)
				from	@treeNode tn5ED
				where	tn5ED.SETID = tn6.SETID
						and tn5ED.TREE_NAME = tn6.TREE_NAME
						and tn5ED.EFFDT <= tn6.EFFDT
				)
		left outer join @treeNode tn4 on
			tn4.SETID = tn5.SETID
			and tn4.TREE_NAME = tn5.TREE_NAME
			and tn4.TREE_NODE_NUM = tn5.PARENT_NODE_NUM
			and tn4.EFFDT =
				(
				select	max(tn4ED.EFFDT)
				from	@treeNode tn4ED
				where	tn4ED.SETID = tn5.SETID
						and tn4ED.TREE_NAME = tn5.TREE_NAME
						and tn4ED.EFFDT <= tn5.EFFDT
				)
		left outer join @treeNode tn3 on
			tn3.SETID = tn4.SETID
			and tn3.TREE_NAME = tn4.TREE_NAME
			and tn3.TREE_NODE_NUM = tn4.PARENT_NODE_NUM
			and tn3.EFFDT =
				(
				select	max(tn3ED.EFFDT)
				from	@treeNode tn3ED
				where	tn3ED.SETID = tn4.SETID
						and tn3ED.TREE_NAME = tn4.TREE_NAME
						and tn3ED.EFFDT <= tn4.EFFDT
				)
		left outer join @treeNode tn2 on
			tn2.SETID = tn3.SETID
			and tn2.TREE_NAME = tn3.TREE_NAME
			and tn2.TREE_NODE_NUM = tn3.PARENT_NODE_NUM
			and tn2.EFFDT =
				(
				select	max(tn2ED.EFFDT)
				from	@treeNode tn2ED
				where	tn2ED.SETID = tn3.SETID
						and tn2ED.TREE_NAME = tn3.TREE_NAME
						and tn2ED.EFFDT <= tn3.EFFDT
				)
		left outer join @treeNode tn1 on
			tn1.SETID = tn2.SETID
			and tn1.TREE_NAME = tn2.TREE_NAME
			and tn1.TREE_NODE_NUM = tn2.PARENT_NODE_NUM
			and tn1.EFFDT =
				(
				select	max(tn1ED.EFFDT)
				from	@treeNode tn1ED
				where	tn1ED.SETID = tn2.SETID
						and tn1ED.TREE_NAME = tn2.TREE_NAME
						and tn1ED.EFFDT <= tn2.EFFDT
				)
	where
		ts.DTL_RECNAME in ('DEPT_TBL','GL_ACCOUNT_TBL','FUND_TBL')
		and td.SETID = 'SHARE'
		and td.VALID_TREE = 'Y'
		and td.EFF_STATUS = 'A'
		and isnull(tnleaf.TREE_LEVEL_NUM, 0) > 0

	) t
go

select * from PS.Trees
go
