CREATE TRIGGER dbo.tr_EmployerContacts_Update ON dbo.EmployerContacts
AFTER UPDATE
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
          , 'U'
          , GETDATE()
          , @SystemUser
      FROM  inserted ;
END
