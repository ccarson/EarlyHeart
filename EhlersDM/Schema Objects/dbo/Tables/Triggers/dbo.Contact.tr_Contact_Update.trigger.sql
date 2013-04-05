CREATE TRIGGER  tr_Contact_Update
            ON  dbo.Contact
AFTER UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_Contact_Update
     Author:    Chris Carson
    Purpose:    Synchronizes Contact data back to legacy systems


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
    2)  Stop processing unless Contacts data has actually changed
    3)  Update legacy contact on table that's linked to the contact record

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;

    DECLARE @legacyContactChecksum      AS INT = 0
          , @convertedContactChecksum   AS INT = 0

--  1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;


--  2)  Stop processing unless Contacts data has actually changed
    SELECT  @legacyContactChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ContactChecksum( 'Legacy' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS b WHERE b.ContactID = a.ContactID ) ;

    SELECT  @convertedContactChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ContactChecksum( 'Converted' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS b WHERE b.ContactID = a.ContactID ) ;

    IF  ( @legacyContactChecksum = @convertedContactChecksum )
        RETURN ;


--  3)  UPDATE legacy contact on table that's linked to the contact record
    UPDATE  edata.FirmContacts
       SET  NamePrefix  = c.NamePrefix
          , FirstName   = c.FirstName
          , LastName    = c.LastName
          , Department  = c.Department
          , Title       = c.Title
          , Phone       = c.Phone
          , Email       = c.Email
          , Fax         = c.Fax
          , CellPhone   = c.CellPhone
          , Notes       = c.Notes
          , ChangeCode  = 'CVContact'
          , ChangeDate  = c.ChangeDate
          , ChangeBy    = c.ChangeBy
      FROM  Conversion.vw_ConvertedContacts  AS c
INNER JOIN  edata.FirmContacts           AS f ON f.ContactID = c.LegacyContactID
     WHERE  c.LegacyTableName = 'FirmContacts'
       AND  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ContactID = c.ContactID ) ;

    UPDATE  edata.ClientContacts
       SET  NamePrefix  = c.NamePrefix
          , FirstName   = c.FirstName
          , LastName    = c.LastName
          , Department  = c.Department
          , Title       = c.Title
          , Phone       = c.Phone
          , Email       = c.Email
          , Fax         = c.Fax
          , CellPhone   = c.CellPhone
          , Notes       = c.Notes
          , ChangeCode  = 'CVContact'
          , ChangeDate  = c.ChangeDate
          , ChangeBy    = c.ChangeBy
      FROM  Conversion.vw_ConvertedContacts  AS c
INNER JOIN  edata.ClientContacts         AS cc ON cc.ContactID = c.LegacyContactID
     WHERE  c.LegacyTableName = 'ClientContacts'
       AND  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ContactID = c.ContactID ) ;

END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
