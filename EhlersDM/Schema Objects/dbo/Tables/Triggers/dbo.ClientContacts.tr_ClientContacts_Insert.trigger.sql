CREATE TRIGGER  tr_ClientContacts_Insert
            ON  dbo.ClientContacts
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ClientContacts_Insert
     Author:    Chris Carson
    Purpose:    Synchronizes contact data back to dbo.ClientContacts


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
    2)  SELECT current ContactID from edata.ClientContacts for INSERT
    3)  INSERT into Conversion.LegacyContacts from trigger tables
    4)  MERGE new Contact data onto edata.ClientContacts

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processContacts    AS VARBINARY(128) = CAST( 'processContacts' AS VARBINARY(128) ) ;
    DECLARE @currentContactID   AS INT = 0 ;

--  1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @processContacts RETURN ;


--  2)  SELECT current ContactID from edata.ClientContacts for INSERT
    SELECT  @currentContactID = ISNULL( MAX( ContactID ), 0 )
      FROM  edata.ClientContacts ;


--  3)  INSERT into Conversion.LegacyContacts from trigger tables
    INSERT  Conversion.LegacyContacts ( ContactID, LegacyTableName, LegacyContactID )
    SELECT  ContactID       = ContactID
          , LegacyTableName = 'ClientContacts'
          , LegacyContactID = @currentContactID + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
      FROM  inserted ;


--  4)  INSERT new Contact data onto edata.ClientContacts
      WITH  insertData AS (
            SELECT  ContactID   = b.LegacyContactID
                  , ClientID    = i.ClientID
                  , CDN         = a.ClientDescriptiveName
                  , NamePrefix  = c.NamePrefix
                  , FirstName   = c.FirstName
                  , LastName    = c.LastName
                  , Title       = c.Title
                  , Department  = c.Department
                  , Phone       = c.Phone
                  , Email       = c.Email
                  , Fax         = c.Fax
                  , CellPhone   = c.CellPhone
                  , Notes       = c.Notes
                  , ChangeCode  = 'CVContact'
                  , ChangeDate  = c.ChangeDate
                  , ChangeBy    = c.ChangeBy
              FROM  inserted                        AS i
        INNER JOIN  edata.Clients               AS a ON a.ClientID  = i.ClientID
        INNER JOIN  Conversion.LegacyContacts       AS b ON b.ContactID = i.ContactID
        INNER JOIN  Conversion.vw_ConvertedContacts AS c ON c.ContactID = i.ContactID  ) 
            
    INSERT  edata.ClientContacts (
            ContactID, ClientID, CDN, NamePrefix, FirstName, LastName, Title, Department
                , Phone, Email, Fax, CellPhone, Notes, ChangeCode, ChangeDate, ChangeBy )
    SELECT  * FROM insertData ; 
    
END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
