CREATE TRIGGER  tr_FirmContacts_Insert
            ON  dbo.FirmContacts
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    tr_FirmContacts_Insert
     Author:    Chris Carson
    Purpose:    Synchronizes contact data back to dbo.FirmContacts

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
    2)  SELECT current ContactID from edata.FirmContacts for INSERT
    3)  INSERT into Conversion.LegacyContacts from trigger tables
    4)  MERGE new Contact data onto edata.FirmContacts

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


--  2)  SELECT current ContactID from edata.FirmContacts for INSERT
    SELECT  @currentContactID = ISNULL( MAX( ContactID ), 0 )
      FROM  edata.FirmContacts ;


--  3)  INSERT into Conversion.LegacyContacts from trigger tables
    INSERT  Conversion.LegacyContacts ( ContactID, LegacyTableName, LegacyContactID )
    SELECT  ContactID       = ContactID
          , LegacyTableName = 'FirmContacts'
          , LegacyContactID = @currentContactID + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
      FROM  inserted ;


--  4)  INSERT new Contact data onto edata.FirmContacts
      WITH  insertData AS (
            SELECT  ContactID   = b.LegacyContactID
                  , FirmID      = i.FirmID
                  , FDN         = a.Firm + ' [' + a.City + ',' + a.State + ']'
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
        INNER JOIN  edata.Firms                 AS a ON a.FirmID  = i.FirmID
        INNER JOIN  Conversion.LegacyContacts       AS b ON b.ContactID = i.ContactID
        INNER JOIN  Conversion.vw_ConvertedContacts AS c ON c.ContactID = i.ContactID  ) 
            
    INSERT  edata.FirmContacts (
            ContactID, FirmID, FDN, NamePrefix, FirstName, LastName, Title, Department
                , Phone, Email, Fax, CellPhone, Notes, ChangeCode, ChangeDate, ChangeBy )
    SELECT  * FROM insertData ; 

END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
