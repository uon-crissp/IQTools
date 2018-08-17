IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreatePregnanciesMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreatePregnanciesMaster]
GO

CREATE PROC [dbo].[pr_CreatePregnanciesMaster] 

AS 
BEGIN 
		EXEC
		('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_Pregnancies'') AND type in (N''U''))
		DROP TABLE tmp_Pregnancies')

		EXEC('SELECT DISTINCT a.PatientPK,
					m.PatientID,
					m.FacilityID,
					m.RegistrationDate,
					e.StartARTDate,
	               
					CASE
						WHEN Min(a.LMP) IS NULL
							 OR Min(a.LMP) = Cast('''' AS datetime) THEN DateAdd(mm, -9, Min(a.EDD))
						ELSE Min(a.LMP)
					END AS LMP,
					DateAdd(mm, 9, CASE WHEN Min(a.LMP) IS NULL
							OR Min(a.LMP) = Cast('''' AS datetime) THEN DateAdd(mm, -9, Min(a.EDD)) ELSE Min(a.LMP) END) EDD,
					CASE
						WHEN m.registrationDate BETWEEN CASE
															WHEN Min(a.LMP) IS NULL
																 OR Min(a.LMP) = Cast('''' AS datetime) THEN DateAdd(mm, -9, Min(a.EDD))
															ELSE Min(a.LMP)
														END AND DateAdd(mm, 9, CASE WHEN Min(a.LMP) IS NULL
																		OR Min(a.LMP) = Cast('''' AS datetime) THEN DateAdd(mm, -9, Min(a.EDD)) ELSE Min(a.LMP) END) THEN 1
						ELSE 0
					END AS PregnantOnEnrollment,
					CASE
						WHEN e.startARTDate BETWEEN CASE
														WHEN Min(a.LMP) IS NULL
															 OR Min(a.LMP) = Cast('''' AS datetime) THEN DateAdd(mm, -9, Min(a.EDD))
														ELSE Min(a.LMP)
													END AND DateAdd(mm, 9, CASE WHEN Min(a.LMP) IS NULL
																	OR Min(a.LMP) = Cast('''' AS datetime) THEN DateAdd(mm, -9, Min(a.EDD)) ELSE Min(a.LMP) END) THEN 1
						ELSE 0
					END AS PregnantOnARTStart,
					CASE
						WHEN GetDate() BETWEEN CASE
												   WHEN Min(a.LMP) IS NULL
														OR Min(a.LMP) = Cast('''' AS datetime) THEN DateAdd(mm, -9, Min(a.EDD))
												   ELSE Min(a.LMP)
											   END AND DateAdd(mm, 9, CASE WHEN Min(a.LMP) IS NULL
															   OR Min(a.LMP) = Cast('''' AS datetime) THEN DateAdd(mm, -9, Min(a.EDD)) ELSE Min(a.LMP) END) THEN 1
						ELSE 0
					END AS PregnantNow
	                
	INTO tmp_Pregnancies
	               
	FROM tmp_ClinicalEncounters a
	INNER JOIN tmp_PatientMaster m ON a.PatientPK = m.PatientPK
	LEFT JOIN tmp_ARTPatients e ON a.PatientPK = e.PatientPK
	WHERE a.Pregnant = ''Yes''
	  AND (a.LMP > Cast('''' AS datetime)
		   OR a.EDD > Cast('''' AS datetime))
	GROUP BY a.PatientPK,
			 m.patientID,
			 m.FacilityID,
			 m.registrationDate,
			 e.startARTDate,
			 Year(CASE WHEN a.LMP IS NULL
				  OR a.LMP = Cast('''' AS datetime) THEN DateAdd(mm, -9, a.EDD) ELSE a.LMP END)')

		EXEC('
		CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
		[dbo].[tmp_Pregnancies] ([PatientPK] ASC )
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
GO