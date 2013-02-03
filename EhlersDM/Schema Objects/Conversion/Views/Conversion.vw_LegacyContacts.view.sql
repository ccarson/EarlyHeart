CREATE VIEW Conversion.vw_LegacyContacts
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyContacts
     Author:    Chris Carson
    Purpose:    shows legacy Contacts data transformed for converted dbo.Contacts format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:
        Phone is LEFT(14), assumes format of (nnn) nnn-nnnn for input
        Extension is all digits after the x in Phone
        Notes is CAST from text to VARCHAR(MAX)
        ChangeDate is now defaulted to GETDATE(), NULLs not allowed in new system

        Orphaned legacy contacts are excluded from the view.

************************************************************************************************************************************
*/
AS
  WITH  firms AS ( SELECT FirmID FROM edata.dbo.Firms ) ,

        firmContacts AS (
        SELECT  ContactID       =  ISNULL( lc.ContactID, 0 )
              , LegacyContactID =  fc.ContactID
              , LegacyTableName =  'FirmContacts'
              , SourceID        =  fc.FirmID
              , NamePrefix      =  ISNULL( fc.NamePrefix, '' )
              , FirstName       =  ISNULL( fc.FirstName, '' )
              , LastName        =  ISNULL( fc.LastName, '' )
              , Department      =  ISNULL( fc.Department, '' )
              , Title           =  ISNULL( fc.Title, '' )
              , Phone           =  ISNULL( LEFT( fc.Phone, 14 ),'')
              , Extension       =  CASE ISNULL( CHARINDEX( 'x', fc.Phone ), 0 )
                                       WHEN 0 THEN ''
                                       ELSE STUFF( fc.Phone, 1, CHARINDEX( 'x', fc.Phone ),'' )
                                   END
              , CellPhone       =  ISNULL( fc.CellPhone, '' )
              , Fax             =  ISNULL( fc.Fax, '' )
              , Email           =  ISNULL( fc.Email, '' )
              , Notes           =  CAST( ISNULL( fc.Notes, '' ) AS VARCHAR(MAX) )
              , ChangeBy        =  ISNULL( NULLIF( fc.ChangeBy, '' ), 'processContacts' )
              , ChangeDate      =  ISNULL( fc.ChangeDate, GETDATE() )
          FROM  edata.dbo.FirmContacts      AS fc
    INNER JOIN  firms                       AS f  ON f.FirmID = fc.FirmID
     LEFT JOIN  Conversion.LegacyContacts   AS lc ON lc.LegacyContactID = fc.ContactID AND lc.LegacyTableName = 'FirmContacts'
         WHERE  ISNULL( lc.LegacyTableName, 'FirmContacts' ) = 'FirmContacts' ) ,


        clients AS ( SELECT ClientID FROM edata.dbo.Clients ) ,

        clientContacts AS (
        SELECT  ContactID       =  ISNULL( lc.ContactID, 0 )
              , LegacyContactID =  cc.ContactID
              , LegacyTableName =  'ClientContacts'
              , SourceID        =  cc.ClientID
              , NamePrefix      =  ISNULL( cc.NamePrefix, '' )
              , FirstName       =  ISNULL( cc.FirstName, '' )
              , LastName        =  ISNULL( cc.LastName, '' )
              , Department      =  ISNULL( cc.Department, '' )
              , Title           =  ISNULL( cc.Title, '' )
              , Phone           =  ISNULL( LEFT( cc.Phone, 14 ),'')
              , Extension       =  CASE ISNULL( CHARINDEX( 'x', cc.Phone ), 0 )
                                       WHEN 0 THEN ''
                                       ELSE STUFF( cc.Phone, 1, CHARINDEX( 'x', cc.Phone ),'' )
                                   END
              , CellPhone       =  ISNULL( cc.CellPhone, '' )
              , Fax             =  ISNULL( cc.Fax, '' )
              , Email           =  ISNULL( cc.Email, '' )
              , Notes           =  CAST( ISNULL( cc.Notes, '' ) AS VARCHAR(MAX) )
              , ChangeDate      =  ISNULL( cc.ChangeDate, GETDATE() )
              , ChangeBy        =  ISNULL( NULLIF( cc.ChangeBy, '' ), 'processContacts' )
          FROM  edata.dbo.ClientContacts    AS cc
    INNER JOIN  clients                     AS c  ON c.ClientID         = cc.ClientID
     LEFT JOIN  Conversion.LegacyContacts   AS lc ON lc.LegacyContactID = cc.ContactID  AND lc.LegacyTableName = 'ClientContacts'
         WHERE  ISNULL( lc.LegacyTableName, 'ClientContacts' ) = 'ClientContacts' )

SELECT  ContactID, LegacyContactID, LegacyTableName, SourceID
            , NamePrefix, FirstName, LastName, Department, Title
            , Phone, Extension, CellPhone, Fax, Email, Notes
            , ChangeDate, ChangeBy
  FROM  firmContacts
    UNION ALL
SELECT  ContactID, LegacyContactID, LegacyTableName, SourceID
            , NamePrefix, FirstName, LastName, Department, Title
            , Phone, Extension, CellPhone, Fax, Email, Notes
            , ChangeDate, ChangeBy
  FROM  clientContacts ;
