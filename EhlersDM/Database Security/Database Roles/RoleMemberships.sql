EXECUTE sp_addrolemember @rolename = N'db_datawriter', @membername = N'EhlersApp' ;
GO

EXECUTE sp_addrolemember @rolename = N'db_datareader', @membername = N'EhlersApp' ;
