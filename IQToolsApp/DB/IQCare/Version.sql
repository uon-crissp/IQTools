IF EXISTS (SELECT * FROM aa_Version)
UPDATE aa_Version SET AppVersion = '4.0', DBVersion = '4.0.0.1', AppDate = CAST('2018/02/13' as DATE)
, UpdateDate = GETDATE() 
WHERE AppName = 'IQTools'
ELSE
INSERT INTO aa_Version (AppName, AppVersion, AppDate, DBVersion, AppAuthor, AppManager, UpdateDate)
VALUES
('IQTools','4.0',CAST('2018/02/13' as DATE), '4.0.0.1','Palladium Group', 'Palladium Group', GETDATE())