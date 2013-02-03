CREATE VIEW Conversion.vw_LegacyClients
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyClients
     Author:    ccarson
    Purpose:    shows "scrubbed" version of Clients


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  ClientID                =   c.ClientID
          , ClientName              =   ISNULL( ClientName, '' )
          , InformalName            =   ISNULL( InformalName, '' )
          , Prefix                  =   cp.ClientPrefixID
          , SchoolDistrictNumber    =   ISNULL( SchoolDistrictNumber, '' )
          , Status                  =   cs.ClientStatusID
          , StatusDate              =   StatusDate
          , TaxID                   =   ISNULL( TaxID, '' )
          , FiscalYearEnd           =   ISNULL( FiscalYearEnd, '' )
          , Phone                   =   ISNULL( Phone, '' )
          , Fax                     =   ISNULL( Fax, '' )
          , TollFree                =   ISNULL( TollFree, '' )
          , TypeJurisdiction        =   jt.JurisdictionTypeID
          , JurisdictionTypeOS      =   ISNULL( jt.DefaultOSValue, '' )
          , GovernBoard             =   gb.GoverningBoardID
          , Population              =   ISNULL( Population, 0 )
          , NewspaperName           =   ISNULL( NewspaperName, '' )
          , WebSite                 =   ISNULL( WebSite, '')
          , Notes                   =   CAST( ISNULL( c.Notes, '' ) AS VARCHAR(MAX) )
          , QBClient                =   ISNULL( QBClient, '' )
          , AcctClass               =   ej.EhlersJobTeamID
          , ChangeDate              =   ISNULL( ChangeDate, GETDATE() )
          , ChangeBy                =   ISNULL( ChangeBy, 'processClients' )
      FROM  edata.dbo.Clients    AS c
 LEFT JOIN  edata.dbo.Disclosure AS d  ON d.ClientID = c.ClientID
 LEFT JOIN  dbo.ClientPrefix     AS cp ON cp.LegacyValue = c.Prefix
 LEFT JOIN  dbo.ClientStatus     AS cs ON cs.LegacyValue = c.Status
 LEFT JOIN  dbo.JurisdictionType AS jt ON c.TypeJurisdiction = jt.LegacyValue
 LEFT JOIN  dbo.GoverningBoard   AS gb ON gb.Value = c.GovernBoard
 LEFT JOIN  dbo.EhlersJobTeam    AS ej ON ej.Value = c.AcctClass ;
 
