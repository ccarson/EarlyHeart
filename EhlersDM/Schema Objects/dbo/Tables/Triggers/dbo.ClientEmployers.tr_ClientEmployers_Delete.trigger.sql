CREATE TRIGGER dbo.tr_ClientEmployers_Delete ON dbo.ClientEmployers
AFTER DELETE
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
          , ModifiedUser  )
    SELECT  ClientEmployersID
          , ClientID
          , EmployerID
          , 'D'
          , GETDATE()
          , @SystemUser
      FROM  deleted ;
END

