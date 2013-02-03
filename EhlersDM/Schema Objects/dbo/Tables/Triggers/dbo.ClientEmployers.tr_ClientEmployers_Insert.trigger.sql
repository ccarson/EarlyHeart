CREATE TRIGGER dbo.tr_ClientEmployers_Insert ON dbo.ClientEmployers
AFTER INSERT
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
          , 'I'
          , GETDATE()
          , @SystemUser
      FROM  inserted ;
END

