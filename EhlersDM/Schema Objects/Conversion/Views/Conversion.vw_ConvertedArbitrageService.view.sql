CREATE VIEW Conversion.vw_ConvertedArbitrageService
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedArbitrageService
     Author:    Chris Carson
    Purpose:    Provides legacy view of converted dbo.ArbitrageService table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  ID                          =  a.ArbitrageServiceID
          , IssueID                     =  a.IssueID
          , DtService                   =  a.ServiceDate
          , ComputationType             =  ac.LegacyValue
          , ynDataReq                   =  a.DataRequested
          , ynDataIn                    =  a.DataReceived
          , ynReport                    =  a.ArbitrageReport
          , Fee                         =  a.ArbitrageFee
      FROM  dbo.ArbitrageService AS a
INNER JOIN  dbo.ArbitrageComputationType AS ac
        ON  ac.ArbitrageComputationTypeID = a.ArbitrageComputationTypeID ;


