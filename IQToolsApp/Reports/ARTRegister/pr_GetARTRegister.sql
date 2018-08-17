IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetARTRegister]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetARTRegister]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetARTRegister]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pr_GetARTRegister] AS' 
END
GO

ALTER procedure [dbo].[pr_GetARTRegister](@fromdate as date, @todate as date)
as
BEGIN

declare @numMonths as int = DATEDIFF(mm, @fromdate, getdate())
declare @i as int = 0
declare @patientpk as int, @startartdate as date
declare @cohort as cursor
declare @insertsql as varchar(max)
set @cohort = cursor for
select patientpk, StartARTDate from tmp_ARTPatients where StartARTDate between @fromdate and @todate

declare @tableCreate as varchar(max) = 'IF EXISTS(Select Name FROM sys.tables WHERE name = ''tmp_ARTRegisterFollowUp'') DROP TABLE tmp_ARTRegisterFollowUp;
CREATE TABLE tmp_ARTRegisterFollowUp (PatientPK INT NOT NULL '

WHILE(@i <= @numMonths)
BEGIN

set @tableCreate+= '
, Month'+cast(@i as varchar(10))+' VARCHAR(100) NULL'
	if(@i%6=0 AND @i>5)
	begin
	 set @tableCreate+= '
, Weight'+cast(@i as varchar(10))+' VARCHAR(100) NULL
, ViralLoad'+cast(@i as varchar(10))+' VARCHAR(100) NULL
, TBStatus'+cast(@i as varchar(10))+' VARCHAR(100) NULL'
	end
set @i+=1
END

set @tableCreate+=');'
exec(@tableCreate)


set @i = 0

open @cohort
fetch next from @cohort into @patientpk, @startartdate
while @@FETCH_STATUS = 0
begin
insert into tmp_ARTRegisterFollowUp(patientpk) values (@patientpk)
set @numMonths = DATEDIFF(mm
				, (select startartdate from tmp_artpatients where patientpk = @patientpk)
				, (select coalesce(exitdate, lastartdate) lastdate from tmp_artpatients where patientpk = @patientpk))

while(@i <= @numMonths)
begin
	set @insertsql = 'update tmp_ARTRegisterFollowUp 
set Month'+cast(@i as varchar(10))+' = dbo.fn_GetARTRegisterFollowUp('+cast(@patientpk as varchar(10))+', DATEADD(MM, '+cast(@i as varchar(10))+', cast('''+cast(@startartdate as varchar(10))+''' as date)))
where patientpk = '+cast(@patientpk as varchar(10))+''
	EXEC(@insertsql)
	if(@i%6=0 AND @i>5)
	begin
	set @insertsql = 'update tmp_ARTRegisterFollowUp 
	set Weight'+cast(@i as varchar(10))+' = dbo.fn_GetARTRegisterWeight('+cast(@patientpk as varchar(10))+', DATEADD(MM, '+cast(@i as varchar(10))+', cast('''+cast(@startartdate as varchar(10))+''' as date)))
	, ViralLoad'+cast(@i as varchar(10))+' = dbo.fn_GetARTRegisterVL('+cast(@patientpk as varchar(10))+', '+cast(@i as varchar(10))+', cast('''+cast(@startartdate as varchar(10))+''' as date))
	, TBStatus'+cast(@i as varchar(10))+' = dbo.fn_GetARTRegisterTBStatus('+cast(@patientpk as varchar(10))+', '+cast(@i as varchar(10))+', cast('''+cast(@startartdate as varchar(10))+''' as date))
	where patientpk = '+cast(@patientpk as varchar(10))+''
	exec(@insertsql)
	end
	set @i+=1
end
set @i=0;
fetch next from @cohort into @patientpk, @startartdate
end
close @cohort
deallocate @cohort


Select Top 100 Percent Row_Number() 
Over (Order By a.[ART Start Date]) [Serial]
, * 
FROM 
(Select Distinct 
CAST(b.StartARTDate as DATE) [ART Start Date]
, a.PatientID [Unique Patient Number]
, a.PatientName [Patients Name]
, a.Gender [Sex]
, a.DOB
, b.AgeARTStart [Age]
, a.[Address] [Physical]
, a.PhoneNumber 
, 'TODO' [Population Type]
, 'TODO' [Discordance]
, d.bWHO [WHO Stage]
, c.bCD4 [CD4 Value or %]
, PHeight.Height [Height For Child]
, AWeight.[Weight] [Weight (kgs)]
, CTX.CTXStart
, INH.INHStart
, TB.TBTreatmentStartDate [Start Date] 
, 'TODO' TBRegNumber 
, j.EDD EDD1 
, j.ANCNumber ANC1 
, NULL EDD2 
, NULL ANC2 
, NULL EDD3 
, NULL ANC3  
, COALESCE(dbo.fn_GetARTRegisterFollowUp(b.PatientPK, b.StartARTDate), b.StartRegimen) [Original Regimen] 
, COALESCE(dbo.fn_GetARTRegisterFollowUp(h.PatientPK, h.Sub1Date), h.Sub1Regimen) [1st Sub]   
, h.Sub1Date  [1st Sub Date]
, NULL [1st Sub Reason]  
, NULL [2nd Sub]   
, NULL [2nd Sub Date]   
, NULL [2nd Sub Reason]   
, COALESCE(dbo.fn_GetARTRegisterFollowUp(i.PatientPK, i.SecondLineRegimenStart), i.SecondLineRegimen)[2nd Line Switch 1]   
, i.SecondLineRegimenStart [2nd Line Switch 1 Date]
, NULL [2nd Line Switch 1 Reason]   
, NULL [2nd Line Switch 2]   
, NULL [2nd Line Switch 2 Date]   
, NULL [2nd Line Switch 2 Reason] 
, k.*

FROM tmp_PatientMaster AS a
INNER JOIN
  (SELECT patientpk,
          startartdate,
          ageartstart,
          StartRegimen
   FROM tmp_artpatients) b ON a.PatientPK = b.PatientPK
LEFT OUTER JOIN IQC_bCD4 AS c ON a.PatientPK = c.PatientPK
LEFT OUTER JOIN IQC_bWHO AS d ON a.PatientPK = d.PatientPK
LEFT JOIN
  (SELECT b.PatientPK,
          Max(a.Height) Height
   FROM tmp_ClinicalEncounters a
   INNER JOIN
     (SELECT a.PatientPK,
             Max(a.VisitDate) HDate
      FROM tmp_ClinicalEncounters a
      INNER JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK
      WHERE b.StartARTDate > a.VisitDate
        AND b.AgeARTStart < 15
      GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
   AND a.VisitDate = b.HDate
   GROUP BY b.PatientPK) PHeight ON a.PatientPK = PHeight.PatientPK
LEFT JOIN
  (SELECT b.PatientPK,
          Max(a.Weight) Weight
   FROM tmp_ClinicalEncounters a
   INNER JOIN
     (SELECT a.PatientPK,
             Max(a.VisitDate) WDate
      FROM tmp_ClinicalEncounters a
      INNER JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK
      WHERE b.StartARTDate > a.VisitDate
      GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
   AND a.VisitDate = b.WDate
   GROUP BY b.PatientPK) AWeight ON a.PatientPK = AWeight.PatientPK
LEFT JOIN
  (SELECT a.PatientPK,
          Min(a.DispenseDate) CTXStart
   FROM tmp_Pharmacy a
   INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK
   WHERE a.ProphylaxisType = 'CTX'
   GROUP BY a.PatientPK) CTX ON a.PatientPK = CTX.PatientPK
LEFT JOIN
  (SELECT a.PatientPK,
          Min(a.DispenseDate) INHStart
   FROM tmp_Pharmacy a
   INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK
   WHERE a.Drug LIKE 'Isoniazid%'
   GROUP BY a.PatientPK) INH ON a.PatientPK = INH.PatientPK
LEFT JOIN
  (SELECT patientpk,
          tbtreatmentstartdate
   FROM tmp_tbpatients) TB ON a.PatientPK = TB.PatientPK
LEFT JOIN
  (SELECT a.PatientPK,
          a.Drug Sub1Regimen,
          b.Sub1Date
   FROM tmp_Pharmacy a
   INNER JOIN
     (SELECT a.PatientPK,
             MIN(DispenseDate) Sub1Date
      FROM tmp_ARTPatients a
      INNER JOIN tmp_Pharmacy b ON a.PatientPK = b.PatientPK
      WHERE b.RegimenLine = 'First line substitute'
        AND a.StartRegimen <> b.Drug
      GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
   AND a.DIspenseDate = b.Sub1Date
   INNER JOIN tmp_PatientMaster c ON a.PatientPK = c.PatientPK
   WHERE a.RegimenLine = 'First line substitute') h ON a.PatientPK = h.PatientPK
LEFT JOIN
  (SELECT a.PatientPK,
          a.Drug SecondLineRegimen,
          b.SecondLineRegimenStart
   FROM tmp_Pharmacy a
   INNER JOIN
     (SELECT a.PatientPK,
             MIN(DispenseDate) SecondLineRegimenStart
      FROM tmp_ARTPatients a
      INNER JOIN tmp_Pharmacy b ON a.PatientPK = b.PatientPK
      WHERE b.RegimenLine = 'Second line'
        AND a.StartRegimen <> b.Drug
      GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
   AND a.DispenseDate = b.SecondLineRegimenStart
   INNER JOIN tmp_PatientMaster c ON a.PatientPK = c.PatientPK
   WHERE a.RegimenLine = 'Second line') i ON a.PatientPK = i.PatientPK
LEFT JOIN
  (SELECT b.PatientPK,
          a.ANCNumber,
          b.EDD
   FROM mst_Patient a
   INNER JOIN
     (SELECT a.PatientPK,
             MIN(a.LMP) LMP,
             MIN(a.EDD) EDD
      FROM tmp_Pregnancies a
      INNER JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK
      WHERE b.StartARTDate BETWEEN a.LMP AND a.EDD
        OR b.StartARTDate <= a.LMP
      GROUP BY a.PatientPK) b ON a.Ptn_pk = b.PatientPK) j ON a.PatientPK = j.PatientPK
LEFT JOIN tmp_ARTRegisterFollowUp k ON a.PatientPK = k.PatientPK
WHERE b.StartARTDate BETWEEN Cast(@FromDate AS datetime) AND Cast(@ToDate AS datetime)) A

END
GO
