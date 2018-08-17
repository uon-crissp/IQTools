IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateIPTMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateIPTMaster
GO

CREATE PROCEDURE [dbo].[pr_CreateIPTMaster] WITH ENCRYPTION
As

BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'tmp_IPT') AND type in (N'U'))
	DROP TABLE tmp_IPT;
	
	CREATE TABLE tmp_IPT
	(PatientPK INT NOT NULL	
	, IPTStartDate DATE NULL
	, LastIPTDispense DATE NULL
	, MonthsOnIPT INT NULL	
	, Medication VARCHAR(200) NULL
	, IPTOutcome VARCHAR(100) NULL
	, DateOfOutcome DATE NULL
	, DiscontinuationReason VARCHAR(200) NULL);

	EXEC('WITH IPTStart AS (
	Select a.PatientPK
	, Min(Coalesce(a.DispenseDate, b.visitdate)) IPTStartDate
	, MAX(Coalesce(a.DispenseDate, b.visitdate)) LastIPTDispense
	, Max(a.Drug) Medication    
	From tmp_Pharmacy a      
	Inner Join ord_visit b On a.VisitID = b.visit_id   
	inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK    
	Where a.Drug LIKE ''Isoniazid%'' Group By a.PatientPK)

	, Discountinued AS (
	select a.Ptn_Pk PatientPK
	, MAX(c.Name) DiscontinuationReason
	, MAX(COALESCE(CASE WHEN YEAR(INHEndDate) < 2000 THEN NULL ELSE a.INHEndDate END, b.VisitDate)) INHDiscontinuedDate
	from dtl_TBScreening a 
	INNER JOIN ord_Visit b ON a.Visit_Pk = b.Visit_Id
	INNER JOIN mst_Decode c ON a.IPTDiscontinued = c.ID
	WHERE b.DeleteFlag = 0 OR b.DeleteFlag IS NULL
	GROUP BY a.Ptn_Pk)

	, Outcomes AS  
	(Select a.PatientPK  
	, CASE WHEN DATEDIFF(MM, a.IPTStartDate, b.LastVisit) > 6 
		AND (c.ExitDate IS NULL OR c.ExitDate > DATEADD(MM, 6, a.IPTStartDate))
		AND d.PatientPK IS NULL	
		THEN ''TC'' 
		WHEN d.PatientPK IS NOT NULL THEN ''Discontinued''
		ELSE c.ExitReason END AS IPTOutcome  

	, CASE WHEN d.PatientPK IS NOT NULL THEN d.DiscontinuationReason ELSE NULL END AS ReasonForDiscountinuation  
	, CASE WHEN DATEDIFF(MM, a.IPTStartDate, b.LastVisit) > 6 
		AND (c.ExitDate IS NULL OR c.ExitDate > DATEADD(MM, 6, a.IPTStartDate))  
		AND d.PatientPK IS NULL

		THEN DATEADD(MM, 6, a.IPTStartDate) 
		WHEN d.PatientPK IS NOT NULL THEN d.INHDiscontinuedDate
		ELSE c.ExitDate END AS DateOfOutcome  

	FROM IPTStart a INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK  
	LEFT JOIN     
		(Select a.PatientPK
		, MAX(CASE ExitReason WHEN ''Transfer'' THEN ''TO''   WHEN ''Death'' THEN ''D''   WHEN ''Lost'' THEN ''LTF'' ELSE NULL END) ExitReason 
		, MAX(ExitDate) ExitDate 
		FROM   tmp_LastStatus a left join tmp_PatientMaster b on a.PatientPK = b.PatientPK   
		WHERE ExitReason IN (''Transfer'',''Death'',''Lost'')  GROUP BY a.PatientPK) c 
	ON a.PatientPK = c.PatientPK
	LEFT JOIN Discountinued d ON a.PatientPK = d.PatientPK
	) 

	INSERT INTO tmp_IPT
	SELECT a.PatientPK
	, CAST(a.IPTStartDate as DATE) IPTStartDate
	, CAST(a.LastIPTDispense as DATE) LastIPTDispense
	, DATEDIFF(mm, a.IPTStartDate, a.LastIPTDispense) MonthsOnIPT 
	, a.Medication
	, b.IPTOutcome
	, CAST(b.DateOfOutcome as DATE) DateOfOutcome
	, b.ReasonForDiscountinuation
	FROM 
	IPTStart a LEFT JOIN Outcomes b ON a.PatientPK = b.PatientPK')

	Exec('
	CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
	[dbo].[tmp_IPT] ([PatientPK] ASC )
	WITH (PAD_INDEX  = OFF
	, STATISTICS_NORECOMPUTE  = OFF
	, SORT_IN_TEMPDB = OFF
	, IGNORE_DUP_KEY = OFF
	, DROP_EXISTING = OFF
	, ONLINE = OFF
	, ALLOW_ROW_LOCKS  = ON
	, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	 ')

END