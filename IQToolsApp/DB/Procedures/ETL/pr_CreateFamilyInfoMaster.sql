IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateFamilyInfoMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateFamilyInfoMaster
GO

CREATE PROCEDURE [dbo].pr_CreateFamilyInfoMaster

as 
begin 
exec
('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_FamilyInfo'') AND type in (N''U''))
DROP TABLE tmp_FamilyInfo')

	exec('
			select a.Ptn_pk PatientPK
			, pb.PatientID
			, a.ReferenceId RPatientPK
			, p.PatientID RPatientID
			, r.Name Relationship
			, d1.Name RGender
			, case when a.createdate is null 
					then
					cast((isnull(a.AgeMonth,0)+isnull(a.AgeYear*12,0))/12.0 as decimal(3,1))
					else 
					Cast((datediff(day, dateadd(yy, -(cast((isnull(a.AgeMonth,0) + isnull(a.AgeYear,0)*12)/12.0 as decimal(3,1))), a.createdate), GETDATE()) / 365.25) as decimal(3,1))
					end RAgeCurrent
			, d2.Name RHIVStatus
			, h.Name RHIVCareStatus
						
			INTO tmp_FamilyInfo
						
			from dbo.dtl_FamilyInfo a
			left join dbo.mst_Decode d1 on a.Sex = d1.ID
			left join dbo.mst_Decode d2 on a.HIVStatus = d2.ID
			left join mst_RelationshipType r on a.RelationshipType = r.ID
			left join mst_HIVCareStatus h on h.ID = a.HivCareStatus
			left join tmp_PatientMaster p on p.PatientPK = a.ReferenceId
			left join tmp_PatientMaster pb on pb.PatientPK = a.Ptn_pk
			where a.DeleteFlag = 0 or a.DeleteFlag is null
		')
	
	
Exec('
CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
[dbo].[tmp_FamilyInfo] ([PatientPK] ASC )
WITH (PAD_INDEX  = OFF
, STATISTICS_NORECOMPUTE  = OFF
, SORT_IN_TEMPDB = OFF
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = OFF
, ALLOW_ROW_LOCKS  = ON
, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 ')

end

GO