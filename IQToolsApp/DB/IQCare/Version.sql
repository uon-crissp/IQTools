IF EXISTS (SELECT * FROM aa_Version)
UPDATE aa_Version SET AppVersion = '4.2', DBVersion = '4.2.1.0', AppDate = CAST('2018/02/13' as DATE)
, UpdateDate = GETDATE() 
WHERE AppName = 'IQTools'
ELSE
INSERT INTO aa_Version (AppName, AppVersion, AppDate, DBVersion, AppAuthor, AppManager, UpdateDate)
VALUES
('IQTools','4.2',CAST('2018/02/13' as DATE), '4.2.1.0','Palladium Group', 'Palladium Group', GETDATE())