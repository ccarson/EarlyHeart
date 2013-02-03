CREATE VIEW Conversion.vw_ConvertedContacts
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedContacts
     Author:    Chris Carson
    Purpose:    translates converted dbo.Contact data to legacy format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  ContactID       = c.ContactID
          , LegacyContactID = lc.LegacyContactID
          , LegacyTableName = lc.LegacyTableName
          , NamePrefix      = c.NamePrefix
          , FirstName       = c.FirstName
          , LastName        = c.LastName
          , Department      = c.Department
          , Title           = c.Title
          , Phone           = CASE LEN(c.extension)
                                  WHEN 0 THEN c.Phone
                                  ELSE c.Phone + ' x' + c.Extension
                              END
          , Fax             = c.Fax
          , CellPhone       = c.CellPhone
          , Email           = c.Email
          , Notes           = c.Notes
          , ChangeDate      = c.ModifiedDate
          , ChangeBy        = c.ModifiedUser
      FROM  dbo.Contact AS c
INNER JOIN  Conversion.LegacyContacts AS lc ON  lc.ContactID = c.ContactID ;
