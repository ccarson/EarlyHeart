CREATE VIEW Conversion.vw_ConvertedClients
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedClients
     Author:    Chris Carson
    Purpose:    shows Legacy version of dbo.ClientData


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  ClientID              = c.ClientID
          , ClientDescriptiveName = ISNULL( c.ClientName, '' ) + ' | ' + ISNULL( cp.LegacyValue, '' ) + ' | ' + ISNULL ( a.State, '' )
          , ClientName            = c.ClientName
          , InformalName          = c.InformalName
          , Prefix                = cp.LegacyValue
          , SchoolDistrictNumber  = c.SchoolDistrictNumber
          , Status                = cs.LegacyValue
          , StatusDate            = c.StatusChangeDate
          , TaxID                 = c.TaxID
          , FiscalYearEnd         = c.FiscalYearEnd
          , Phone                 = c.Phone
          , Fax                   = c.Fax
          , TollFree              = c.TollFreePhone
          , TypeJurisdiction      = jt.LegacyValue
          , GovernBoard           = gb.LegacyValue
          , Population            = c.Population
          , NewspaperName         = c.Newspaper
          , WebSite               = c.WebSite
          , Notes                 = c.Notes
          , QBClient              = c.QuickBookName
          , AcctClass             = ej.LegacyValue
          , ChangeDate            = c.ModifiedDate
          , ChangeBy              = c.ModifiedUser
      FROM  dbo.Client           AS c
 LEFT JOIN  dbo.ClientAddresses  AS ca ON ca.ClientID           = c.ClientID AND ca.AddressTypeID = 3
 LEFT JOIN  dbo.Address          AS a  ON a.AddressID           = ca.AddressID
 LEFT JOIN  dbo.ClientPrefix     AS cp ON cp.ClientPrefixID     = c.ClientPrefixID
 LEFT JOIN  dbo.ClientStatus     AS cs ON cs.ClientStatusID     = c.ClientStatusID
 LEFT JOIN  dbo.JurisdictionType AS jt ON jt.JurisdictionTypeID = c.JurisdictionTypeID
 LEFT JOIN  dbo.GoverningBoard   AS gb ON gb.GoverningBoardID   = c.GoverningBoardID
 LEFT JOIN  dbo.EhlersJobTeam    AS ej ON ej.EhlersJobTeamID    = c.EhlersJobTeamID ;
