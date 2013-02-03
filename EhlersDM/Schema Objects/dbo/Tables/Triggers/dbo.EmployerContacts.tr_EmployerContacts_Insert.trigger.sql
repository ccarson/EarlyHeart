CREATE TRIGGER dbo.tr_EmployerContacts_Insert ON dbo.EmployerContacts
AFTER INSERT
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
          , 'I'
          , GETDATE()
          , @SystemUser
      FROM  inserted ;
END
