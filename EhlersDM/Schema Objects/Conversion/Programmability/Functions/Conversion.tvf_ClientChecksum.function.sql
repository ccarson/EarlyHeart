CREATE FUNCTION Conversion.tvf_ClientChecksum ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ClientChecksum
     Author:    Chris Carson
    Purpose:    computes the checksum for a given ClientID


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @SourceTable    VARCHAR(20)     'Legacy|Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  ClientID              = ClientID
              , ClientName            = ClientName
              , InformalName          = InformalName
              , Prefix                = ISNULL( Prefix, 0 )
              , SchoolDistrictNumber  = ISNULL( SchoolDistrictNumber, '' )
              , Status                = ISNULL( Status, 0 )
              , StatusDate            = CONVERT( VARCHAR(10), COALESCE( StatusDate, '1900-01-01' ), 120 )
              , TaxID                 = CAST( TaxID AS CHAR(10) )
              , FiscalYearEnd         = CAST( FiscalYearEnd AS CHAR(5) )
              , Phone                 = QUOTENAME( Phone )
              , Fax                   = QUOTENAME( Fax )
              , TollFree              = QUOTENAME( TollFree )
              , TypeJurisdiction      = ISNULL( TypeJurisdiction, 0 )
              , GovernBoard           = ISNULL( GovernBoard, 0 )
              , Population            = Population
              , NewspaperName         = NewspaperName
              , WebSite               = WebSite
              , Notes                 = Notes
              , QBClient              = QBClient
              , AcctClass             = ISNULL( AcctClass, 0 )
          FROM  Conversion.vw_legacyClients 
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ClientID              = ClientID
              , ClientName            = ClientName
              , InformalName          = InformalName
              , Prefix                = ISNULL( ClientPrefixID, 0 )
              , SchoolDistrictNumber  = SchoolDistrictNumber
              , Status                = ISNULL( ClientStatusID, 0 )
              , StatusDate            = CONVERT( VARCHAR(10), COALESCE( StatusChangeDate, '1900-01-01' ), 120 )
              , TaxID                 = TaxID
              , FiscalYearEnd         = FiscalYearEnd
              , Phone                 = QUOTENAME( c.Phone )
              , Fax                   = QUOTENAME( c.Fax )
              , TollFree              = QUOTENAME( c.TollFreePhone )
              , TypeJurisdiction      = ISNULL( c.JurisdictionTypeID, 0 )
              , GovernBoard           = ISNULL( c.GoverningBoardID, 0 )
              , Population            = Population
              , NewspaperName         = Newspaper
              , WebSite               = WebSite
              , Notes                 = Notes
              , QBClient              = QuickBookName
              , AcctClass             = ISNULL( c.EhlersJobTeamID, 0 )
          FROM  dbo.Client AS c
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  ClientID, ClientName, InformalName, Prefix
                    , SchoolDistrictNumber, Status, StatusDate
                    , TaxID, FiscalYearEnd, Phone, Fax, TollFree
                    , TypeJurisdiction, GovernBoard, Population
                    , NewspaperName, WebSite, Notes, QBClient, AcctClass
        FROM legacy
            UNION ALL
        SELECT  ClientID, ClientName, InformalName, Prefix
                    , SchoolDistrictNumber, Status, StatusDate
                    , TaxID, FiscalYearEnd, Phone, Fax, TollFree
                    , TypeJurisdiction, GovernBoard, Population
                    , NewspaperName, WebSite, Notes, QBClient, AcctClass
        FROM converted )

SELECT  ClientID        = ClientID
      , ClientChecksum  = CAST( HASHBYTES ( 'md5', CAST( ClientID AS VARCHAR(20) )
                                                       + ClientName
                                                       + InformalName
                                                       + CAST( Prefix AS VARCHAR(20) )
                                                       + SchoolDistrictNumber
                                                       + CAST( Status AS VARCHAR(20) )
                                                       + StatusDate
                                                       + TaxID
                                                       + FiscalYearEnd
                                                       + Phone
                                                       + Fax
                                                       + TollFree
                                                       + CAST( TypeJurisdiction AS VARCHAR(20) )
                                                       + CAST( GovernBoard AS VARCHAR(20) )
                                                       + CAST( Population AS VARCHAR(20) )
                                                       + NewspaperName
                                                       + WebSite
                                                       + Notes
                                                       + QBClient
                                                       + CAST( AcctClass AS VARCHAR(20) ) 
                                                       ) AS VARBINARY(128) )
  FROM  inputData ;
