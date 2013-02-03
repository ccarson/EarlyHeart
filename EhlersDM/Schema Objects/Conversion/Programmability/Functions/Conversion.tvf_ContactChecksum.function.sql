CREATE FUNCTION Conversion.tvf_ContactChecksum ( @Source AS VARCHAR (20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ContactChecksum
     Author:    Chris Carson
    Purpose:    computes the checksum for a given ContactID


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR (20)    'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  ContactID       = ContactID
              , LegacyContactID = LegacyContactID
              , LegacyTableName = LegacyTableName
              , NamePrefix      = NamePrefix
              , FirstName       = QUOTENAME( FirstName )
              , LastName        = QUOTENAME( LastName )
              , Department      = QUOTENAME( Department )
              , Title           = QUOTENAME( Title )
              , Phone           = QUOTENAME( CASE LEN( Extension )
                                                WHEN 0 THEN Phone
                                                ELSE Phone + ' x' + Extension
                                             END )
              , CellPhone       = QUOTENAME( CellPhone )
              , Fax             = QUOTENAME( Fax )
              , Email           = Email
              , Notes           = Notes
          FROM  Conversion.vw_LegacyContacts
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ContactID       = ContactID
              , LegacyContactID = LegacyContactID
              , LegacyTableName = LegacyTableName
              , NamePrefix      = NamePrefix
              , FirstName       = QUOTENAME( FirstName )
              , LastName        = QUOTENAME( LastName )
              , Department      = QUOTENAME( Department )
              , Title           = QUOTENAME( Title )
              , Phone           = QUOTENAME( Phone )
              , CellPhone       = QUOTENAME( CellPhone )
              , Fax             = QUOTENAME( Fax )
              , Email           = Email
              , Notes           = Notes
          FROM  Conversion.vw_ConvertedContacts
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  ContactID, LegacyContactID, LegacyTableName, NamePrefix, FirstName, LastName
                    , Department, Title, Phone, CellPhone, Fax, Email, Notes
          FROM  legacy
            UNION ALL
        SELECT  ContactID, LegacyContactID, LegacyTableName, NamePrefix, FirstName, LastName
                    , Department, Title, Phone, CellPhone, Fax, Email, Notes
          FROM  converted )

SELECT  ContactID       = ContactID
      , LegacyContactID = LegacyContactID
      , LegacyTableName = LegacyTableName
      , ContactChecksum = CAST( HASHBYTES ( 'md5', CAST( ContactID       AS VARCHAR(20) )
                                                 + CAST( LegacyContactID AS VARCHAR(20) )
                                                 + LegacyTableName
                                                 + NamePrefix
                                                 + FirstName
                                                 + LastName
                                                 + Department
                                                 + Title
                                                 + Phone
                                                 + CellPhone
                                                 + Fax
                                                 + Email
                                                 + Notes ) AS VARBINARY(128) )
  FROM  inputData ;
