CREATE TRIGGER dbo.tr_EmployerContacts_Delete ON dbo.EmployerContacts
AFTER DELETE
AS 
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

    INSERT  dbo.EmployerContactsAudit (
            EmployerContactsID
          , EmployerID
          , ContactID
          , ChangeType
          , ModifiedDate
          , ModifiedUser )
    SELECT  EmployerContactsID
          , EmployerID
          , ContactID
          , 'D'
          , GETDATE()
          , @SystemUser
      FROM  deleted ;
END
