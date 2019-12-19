IF EXISTS (SELECT * FROM aa_Version)
UPDATE aa_Version SET AppVersion = '4.3', DBVersion = '4.3.0.2', AppDate = CAST('10-Dec-2019' as DATE)
, UpdateDate = GETDATE() 
WHERE AppName = 'IQTools'
ELSE
INSERT INTO aa_Version (AppName, AppVersion, AppDate, DBVersion, AppAuthor, AppManager, UpdateDate)
VALUES
('IQTools','4.3',CAST('10-Dec-2019' as DATE), '4.3.0.2','UoN', 'UoN', GETDATE())