CREATE TRIGGER dbo.tr_ContactAddresses_Delete ON dbo.ContactAddresses
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ContactAddresses_Delete
     Author:    Chris Carson
    Purpose:    Applies address data to specified edata.ClientContacts or edata.FirmContacts records

    Revision History:
    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create ContactAddressesAudit record reflecting DELETE
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Clear out Address fields on edata.FirmContacts records
    4)  Clear out Address fields on edata.ClientContacts records
    5)  Delete Conversion.LegacyAddresses records

    Notes:

********************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processAddresses AS VARBINARY(128) = CAST( 'processAddresses' AS VARBINARY(128) ) ;
    DECLARE @SystemUser       AS VARCHAR(20)    = dbo.udf_GetSystemUser() ;


--  1)  Create ContactAddressesAudit record reflecting DELETE
    INSERT  dbo.ContactAddressesAudit (
                ContactAddressesID, ContactID, AddressID
                    , AddressTypeID, ChangeType
                    , ModifiedDate, ModifiedUser )
    SELECT  ContactAddressesID, ContactID, AddressID
                    , AddressTypeID, 'D'
                    , GETDATE(), @SystemUser
      FROM  deleted ;


--  2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    IF  CONTEXT_INFO() = @processAddresses RETURN ;


--  3)  Clear out Address fields on edata.FirmContacts records
    UPDATE  edata.FirmContacts
       SET  Address1    = ''
          , Address2    = ''
          , City        = ''
          , State     = ''
          , Zip         = ''
          , ChangeDate  = GETDATE()
          , ChangeBy    = @SystemUser
          , ChangeCode  = 'CVAddress'
      FROM  deleted AS d
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = d.AddressID
INNER JOIN  edata.FirmContacts AS fc
        ON  fc.ContactID = la.LegacyID ;


--  4)  Clear out Address fields on edata.ClientContacts records
    UPDATE  edata.ClientContacts
       SET  Address1    = ''
          , Address2    = ''
          , City        = ''
          , State     = ''
          , Zip         = ''
          , ChangeDate  = GETDATE()
          , ChangeBy    = @SystemUser
          , ChangeCode  = 'CVAddress'
      FROM  deleted AS d
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = d.AddressID
INNER JOIN  edata.ClientContacts AS cc
        ON  cc.ContactID = la.LegacyID ;


--  5)  Delete Conversion.LegacyAddresses records
    DELETE  Conversion.LegacyAddresses
      FROM  Conversion.LegacyAddresses AS a
     WHERE  EXISTS ( SELECT 1 FROM deleted AS b WHERE b.AddressID = a.AddressID ) ;
END
