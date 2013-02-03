CREATE TRIGGER dbo.tr_ClientEmployers_Update ON dbo.ClientEmployers
AFTER UPDATE
AS 
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

    INSERT  dbo.ClientEmployersAudit (
            ClientEmployersID
          , ClientID
          , EmployerID
          , ChangeType
          , ModifiedDate
          , ModifiedUser )
    SELECT  ClientEmployersID
          , ClientID
          , EmployerID
          , 'U'
          , GETDATE()
          , @SystemUser
      FROM  inserted ;
END

