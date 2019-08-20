IF EXISTS (SELECT * FROM aa_Version)
UPDATE aa_Version SET AppVersion = '4.2', DBVersion = '4.2.6.0', AppDate = CAST('2019/07/30' as DATE)
, UpdateDate = GETDATE() 
WHERE AppName = 'IQTools'
ELSE
INSERT INTO aa_Version (AppName, AppVersion, AppDate, DBVersion, AppAuthor, AppManager, UpdateDate)
VALUES
('IQTools','4.2',CAST('2019/07/30' as DATE), '4.2.6.0','UoN', 'UoN', GETDATE())