CREATE FUNCTION Conversion.tvf_LegacyMailings( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_LegacyMailings
     Author:    Chris Carson
    Purpose:    returns Mailings data into a legacy CSV format for comparison


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source         VARCHAR(20)     'Legacy'|'Converted'

    Notes:
    Instead of 'Legacy'|'Converted' for source, use the sourceTable as noted above

************************************************************************************************************************************
*/
RETURN
  WITH  optOutCodes ( MailingCode, OptOutCode ) AS (
        SELECT    'NI',  'USEM'    UNION ALL
        SELECT    'NM',  'USEM'    UNION ALL
        SELECT    'NW',  'USEM'    UNION ALL
        SELECT    'EMA', 'OOEA'    UNION ALL
        SELECT    'BWC', 'OOMC'    UNION ALL
        SELECT    'P',   'OOS'     UNION ALL
        SELECT    'S',   'OOS' ) ,

        firmsData AS (
        SELECT  LegacyContactID = fc.ContactID
              , LegacyTableName = 'FirmContacts'
              , ContactID       = lc.ContactID
              , Mailing         = fc.Mailing
          FROM  edata.FirmContacts    AS fc
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.LegacyContactID = fc.ContactID
         WHERE  lc.LegacyTableName = 'FirmContacts' AND fc.Mailing <> '' AND @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 FROM edata.Firms AS f WHERE f.FirmID = fc.FirmID ) ) ,

        clientsData AS (
        SELECT  LegacyContactID = cc.ContactID
              , LegacyTableName = 'ClientContacts'
              , ContactID       = lc.ContactID
              , Mailing         = cc.Mailing
          FROM  edata.ClientContacts  AS cc
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.LegacyContactID = cc.ContactID
         WHERE  lc.LegacyTableName = 'ClientContacts' AND cc.Mailing <> '' AND @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 FROM edata.Clients AS c WHERE c.ClientID = cc.ClientID ) ) ,

        contactsData AS (
        SELECT  LegacyContactID, LegacyTableName, ContactID, Mailing FROM firmsData
            UNION ALL
        SELECT  LegacyContactID, LegacyTableName, ContactID, Mailing FROM clientsData ) ,

        legacy AS (
        SELECT  LegacyContactID = cd.LegacyContactID
              , LegacyTableName = cd.LegacyTableName
              , ContactID       = cd.ContactID
              , Item            = UPPER( x.Item )
          FROM  contactsData AS cd
   CROSS APPLY  dbo.tvf_CSVSplit( Mailing , ',' ) AS x
         WHERE  EXISTS ( SELECT 1 FROM dbo.MailingType WHERE LegacyValue = x.Item AND LegacyValue <> '' )
            OR  EXISTS ( SELECT 1 FROM optOutCodes WHERE OptOutCode = x.Item ) ) , 

        converted AS (
        SELECT  LegacyContactID = lc.LegacyContactID
              , LegacyTableName = lc.LegacyTableName
              , ContactID       = cm.ContactID
              , Item            = mt.LegacyValue
          FROM  dbo.ContactMailings       AS cm
    INNER JOIN  dbo.MailingType           AS mt ON cm.MailingTypeID = mt.MailingTypeID
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.ContactID     = cm.ContactID
         WHERE  @Source = 'Converted' AND OptOut = 0
            UNION
        SELECT  LegacyContactID = lc.LegacyContactID
              , LegacyTableName = lc.LegacyTableName
              , ContactID       = cm.ContactID
              , Item            = oo.OptOutCode
          FROM  dbo.ContactMailings       AS cm
    INNER JOIN  dbo.MailingType           AS mt ON cm.MailingTypeID = mt.MailingTypeID
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.ContactID     = cm.ContactID
    INNER JOIN  optOutCodes               AS oo ON MailingCode      = mt.LegacyValue
         WHERE  @Source = 'Converted' AND OptOut = 1 ) ,

        inputData AS (
        SELECT  LegacyContactID, LegacyTableName, ContactID, Item FROM legacy
            UNION ALL
        SELECT  LegacyContactID, LegacyTableName, ContactID, Item FROM converted ) 

SELECT  DISTINCT
        LegacyContactID = LegacyContactID
      , LegacyTableName = LegacyTableName
      , ContactID       = ContactID
      , Mailing = CAST( STUFF( ( SELECT  ',' + Item
                                   FROM  inputData AS a
                                  WHERE  a.LegacyContactID     = b.LegacyContactID
                                         AND a.LegacyTableName = b.LegacyTableName
                                         AND a.ContactID       = b.ContactID
                                  ORDER  BY ',' + Item
                                    FOR  XML PATH ('') ), 1, 1, '' ) AS VARCHAR(50) )
  FROM  inputData AS b ;
