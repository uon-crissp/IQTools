IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateLastStatusMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreateLastStatusMaster]
GO

CREATE PROCEDURE [dbo].[pr_CreateLastStatusMaster]
AS
Begin

EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_LastStatus'') AND type in (N''U''))
DROP TABLE tmp_LastStatus')

EXEC('WITH Exits AS 

(Select DISTINCT a.Ptn_Pk PatientPK
, b.ExitDate
, CASE WHEN c.Name like ''%hiv%negative%'' THEN ''HIV Negative''		
		WHEN c.Name IN (''Death'',''Infant Died'') THEN ''Death''		
		WHEN c.Name Like ''%Lost%'' OR c.Name Like ''%ltfu%'' THEN ''Lost''		
		WHEN c.Name like ''%Transfer%'' THEN ''Transfer''		
ELSE c.Name END AS
ExitReason 
FROM dtl_PatientCareEnded a INNER JOIN		
	(select a.Ptn_Pk, MAX(CareEndedDate) ExitDate 
	from dtl_patientcareended a inner join
	dtl_patienttrackingcare b on a.ptn_pk = b.ptn_pk
	and a.trackingid = b.trackingid
	where b.moduleid in (1,2,203, 6)
	and a.CareEnded = 1
	GROUP BY a.Ptn_Pk) b ON a.Ptn_Pk = b.Ptn_Pk AND a.CareEndedDate = b.ExitDate 
	AND a.CareEnded = 1
INNER JOIN mst_Decode c ON a.PatientExitReason = c.ID)

, LastStatus AS (
Select a.PatientPK
, MIN(b.LastVisit) LastVisit
, MIN(a.ExitDate) ExitDate
, MIN(a.ExitReason) ExitReason
, MIN(a.ExitDate) CDCExitDate
, MIN(a.ExitReason) CDCExitReason
, NULL ExitDescription
FROM Exits a INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK
WHERE DATEDIFF(dd, b.LastVisit, a.ExitDate) >= -1
GROUP BY a.PatientPK)

Select * into tmp_LastStatus FROM LastStatus')

Exec('CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
[dbo].[tmp_LastStatus] ([PatientPK] ASC )
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