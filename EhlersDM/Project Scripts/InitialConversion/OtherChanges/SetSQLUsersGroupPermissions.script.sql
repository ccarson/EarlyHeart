DECLARE @memberName AS SYSNAME ;

IF  ( '$(TargetServer)' LIKE 'EHLERS%' ) 
    BEGIN 
        SELECT @memberName = N'EHLERS\SQL-Users' ;
        CREATE USER [EHLERS\SQL-Users] FOR LOGIN [EHLERS\SQL-Users] ;
        GRANT CONNECT TO [EHLERS\SQL-Users] ;
    END
ELSE 
    BEGIN
        SELECT @memberName = N'$(TargetServer)\SQL-Users' ;
        CREATE USER [$(TargetServer)\SQL-Users] FOR LOGIN [$(TargetServer)\SQL-Users] ;
        GRANT CONNECT TO [$(TargetServer)\SQL-Users] ;
    END


EXECUTE sp_addrolemember @rolename = N'db_datareader', @membername = @memberName ;
EXECUTE sp_addrolemember @rolename = N'db_datawriter', @membername = @memberName ;