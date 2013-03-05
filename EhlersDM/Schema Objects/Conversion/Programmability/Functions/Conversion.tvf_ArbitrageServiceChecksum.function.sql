CREATE FUNCTION Conversion.tvf_ArbitrageServiceChecksum ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ArbitrageServiceChecksum
     Author:    Chris Carson
    Purpose:    computes the checksum for a given IssueArbitrageService


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created


    Function Arguments:
    @Source     VARCHAR(20)     Legacy|Converted

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  ArbitrageServiceID          = ias.ID
              , IssueID                     = ias.IssueID
              , DtService                   = CONVERT( VARCHAR(10), ias.DtService , 120 )
              , ArbitrageComputationTypeID  = ISNULL( t.ArbitrageComputationTypeID, 0 )
              , ynDataReq                   = QUOTENAME( CAST(ias.ynDataReq AS VARCHAR(1) ) )
              , ynDataIn                    = QUOTENAME( CAST(ias.ynDataIn AS VARCHAR(1) ) )
              , ynReport                    = QUOTENAME( CAST(ias.ynReport AS VARCHAR(1) ) )
              , Fee                         = CAST( ISNULL(ias.Fee, 0) AS DECIMAL(15,2) )
          FROM  edata.IssueArbitrageServices AS ias
    INNER JOIN  edata.Issues AS i ON i.IssueID = ias.IssueID
    INNER JOIN  dbo.ArbitrageComputationType AS t ON t.LegacyValue = ias.ComputationType
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ArbitrageServiceID          = s.ArbitrageServiceID
              , IssueID                     = s.IssueID
              , DtService                   = CONVERT( VARCHAR(10), s.ServiceDate, 120 )
              , ArbitrageComputationTypeID  = s.ArbitrageComputationTypeID
              , ynDataReq                   = QUOTENAME( CAST(s.DataRequested AS VARCHAR(1) ) )
              , ynDataIn                    = QUOTENAME( CAST(s.DataReceived AS VARCHAR(1) ) )
              , ynReport                    = QUOTENAME( CAST(s.ArbitrageReport AS VARCHAR(1) ) )
              , Fee                         = s.ArbitrageFee
          FROM  dbo.ArbitrageService AS s
    INNER JOIN  dbo.ArbitrageComputationType AS t
            ON  t.ArbitrageComputationTypeID = s.ArbitrageComputationTypeID
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  ArbitrageServiceID, IssueID, DtService, ArbitrageComputationTypeID, ynDataReq, ynDataIn, ynReport, Fee
          FROM  legacy
            UNION ALL
        SELECT  ArbitrageServiceID, IssueID, DtService, ArbitrageComputationTypeID, ynDataReq, ynDataIn, ynReport, Fee
          FROM  converted )

SELECT  ArbitrageServiceID          = ArbitrageServiceID
      , ArbitrageServiceChecksum    = CAST( HASHBYTES( 'md5', CAST( ArbitrageServiceID AS VARCHAR(20) )
                                                                 +  CAST( IssueID AS VARCHAR(20) )
                                                                 +  DtService
                                                                 +  CAST( ArbitrageComputationTypeID AS VARCHAR(20) )
                                                                 +  ynDataReq
                                                                 +  ynDataIn
                                                                 +  ynReport
                                                                 +  CAST( Fee AS VARCHAR(20) ) ) AS VARBINARY(128) )
  FROM  inputData ;
