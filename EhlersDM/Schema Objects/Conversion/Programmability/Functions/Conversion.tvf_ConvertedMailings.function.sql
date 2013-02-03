CREATE FUNCTION Conversion.tvf_ConvertedMailings( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ConvertedMailings
     Author:    Chris Carson
    Purpose:    returns Mailings in a table format for comparision


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source         VARCHAR(20)     'Legacy'|'Converted'
    '

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
          FROM  edata.dbo.FirmContacts    AS fc
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.LegacyContactID = fc.ContactID
         WHERE  lc.LegacyTableName = 'FirmContacts' AND fc.Mailing <> '' AND @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 FROM edata.dbo.Firms AS f WHERE f.FirmID = fc.FirmID ) ) ,

        clientsData AS (
        SELECT  LegacyContactID = cc.ContactID
              , LegacyTableName = 'ClientContacts'
              , ContactID       = lc.ContactID
              , Mailing         = cc.Mailing
          FROM  edata.dbo.ClientContacts  AS cc
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.LegacyContactID = cc.ContactID
         WHERE  lc.LegacyTableName = 'ClientContacts' AND cc.Mailing <> '' AND @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 FROM edata.dbo.Clients AS c WHERE c.ClientID = cc.ClientID ) ) ,


        contactsData AS (
        SELECT  LegacyContactID, LegacyTableName, ContactID, Mailing FROM firmsData
            UNION ALL
        SELECT  LegacyContactID, LegacyTableName, ContactID, Mailing FROM clientsData ) ,


        legacyOptOuts AS (
        SELECT  LegacyContactID = cd.LegacyContactID
              , LegacyTableName = cd.LegacyTableName
              , ContactID       = cd.ContactID
              , MailingTypeID   = mt.MailingTypeID
              , OptOut          = 1
          FROM  contactsData AS cd
   CROSS APPLY  dbo.tvf_CSVSplit( cd.Mailing, ',' ) AS x
    INNER JOIN  optOutCodes     AS oo ON oo.OptOutCode  = x.Item
    INNER JOIN  dbo.MailingType AS mt ON mt.LegacyValue = oo.MailingCode ) ,


        legacyMailings AS (
        SELECT  LegacyContactID = cd.LegacyContactID
              , LegacyTableName = cd.LegacyTableName
              , ContactID       = cd.ContactID
              , MailingTypeID   = mt.MailingTypeID
              , OptOut          = 0
          FROM  contactsData AS cd
   CROSS APPLY  dbo.tvf_CSVSplit( cd.Mailing, ',' ) AS x
    INNER JOIN  dbo.MailingType AS mt ON mt.LegacyValue = x.Item
         WHERE  NOT EXISTS ( SELECT 1 FROM legacyOptOuts AS oo
                              WHERE oo.ContactID = cd.ContactID AND oo.MailingTypeID = mt.MailingTypeID ) ) ,


        converted AS (
        SELECT  LegacyContactID = lc.LegacyContactID
              , LegacyTableName = lc.LegacyTableName
              , ContactID       = cm.ContactID
              , MailingTypeID   = cm.MailingTypeID
              , OptOut          = cm.OptOut
          FROM  dbo.ContactMailings AS cm
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.ContactID = cm.ContactID
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  LegacyContactID, LegacyTableName, ContactID , MailingTypeID, OptOut FROM legacyOptOuts
            UNION ALL
        SELECT  LegacyContactID, LegacyTableName, ContactID , MailingTypeID, OptOut FROM legacyMailings
            UNION ALL
        SELECT  LegacyContactID, LegacyTableName, ContactID , MailingTypeID, OptOut FROM converted )


SELECT  DISTINCT
        LegacyContactID
      , LegacyTableName
      , ContactID
      , MailingTypeID
      , OptOut
  FROM  inputData ;
