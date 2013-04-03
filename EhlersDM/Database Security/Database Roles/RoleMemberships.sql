EXECUTE sp_addrolemember @rolename = N'db_owner', @membername = N'EhlersApp' ;
GO

EXECUTE sp_addrolemember @rolename = N'db_owner', @membername = N'Ehlers\SQL-Users' ;
GO

EXECUTE sp_addrolemember @rolename = N'db_datareader', @membername = N'EhlersReportUser' ;
