CREATE TRIGGER dbo.tr_ContactMailings ON dbo.ContactMailings
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ContactMailings
     Author:    Chris Carson
    Purpose:    writes Mailings changes back to legacy Contacts


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
    2)  Pull unique list of triggered ContactIDs into temp storage
    3)  Stop processing unless Contacts mailing data has actually changed
    4)  update legacy Contacts with new Mailings field

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processMailings AS VARBINARY(128) = CAST( 'processMailings' AS VARBINARY(128) ) ;
    
    DECLARE @changes AS TABLE ( ContactID INT ) ; 
    

    CREATE TABLE #mailings  ( LegacyContactID INT
                            , LegacyTableName VARCHAR (20)
                            , ContactID       INT
                            , Mailing         VARCHAR (50)
                            , ModifiedDate    DATETIME
                            , ModifiedUser    VARCHAR (20) ) ;
                            
    
--  1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @processMailings RETURN ;


--  2)  Pull unique list of triggered ContactIDs into temp storage
    INSERT  @changes
    SELECT  ContactID FROM inserted
        UNION 
    SELECT  ContactID FROM deleted ; 

    
--  3)  update edata.FirmContacts with new Mailing data
      WITH  mailings AS (
            SELECT  c.ContactID
                  , m.LegacyContactID
                  , m.Mailing
              FROM  @changes AS c 
         LEFT JOIN  Conversion.tvf_LegacyMailings( 'Converted' ) AS m ON m.ContactID = c.ContactID 
             WHERE  ISNULL( m.LegacyTableName, 'FirmContacts' ) = 'FirmContacts' ) , 

            contactData AS (
            SELECT  ContactID
                  , ModifiedDate
                  , ModifiedUser
              FROM  dbo.Contact AS a
             WHERE  EXISTS ( SELECT 1 FROM @changes AS b WHERE b.ContactID = a.ContactID ) )
             
    UPDATE  edata.FirmContacts
       SET  Mailing     = md.Mailing
          , ChangeCode  = 'CVMailing'
          , ChangeDate  = cd.ModifiedDate
          , ChangeBy    = cd.ModifiedUser
      FROM  edata.FirmContacts  AS fc
INNER JOIN  mailings                AS md ON md.LegacyContactID = fc.ContactID
INNER JOIN  contactData             AS cd ON cd.ContactID       = md.ContactID ;


--  4)  update edata.ClientContacts with new Mailing data
      WITH  mailings AS (
            SELECT  c.ContactID
                  , m.LegacyContactID
                  , m.Mailing
              FROM  @changes AS c 
         LEFT JOIN  Conversion.tvf_LegacyMailings( 'Converted' ) AS m ON m.ContactID = c.ContactID 
             WHERE  ISNULL( m.LegacyTableName, 'ClientContacts' ) = 'ClientContacts' ) , 

            contactData AS (
            SELECT  ContactID
                  , ModifiedDate
                  , ModifiedUser
              FROM  dbo.Contact AS a
             WHERE  EXISTS ( SELECT 1 FROM @changes AS b WHERE b.ContactID = a.ContactID ) )
             
    UPDATE  edata.ClientContacts
       SET  Mailing     = md.Mailing
          , ChangeCode  = 'CVMailing'
          , ChangeDate  = cd.ModifiedDate
          , ChangeBy    = cd.ModifiedUser
      FROM  edata.ClientContacts AS cc
INNER JOIN  mailings                 AS md ON md.LegacyContactID = cc.ContactID
INNER JOIN  contactData              AS cd ON cd.ContactID       = md.ContactID ;

END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH


END