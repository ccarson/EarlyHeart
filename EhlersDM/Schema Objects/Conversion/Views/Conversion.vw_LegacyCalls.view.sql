CREATE VIEW Conversion.vw_LegacyCalls
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyCalls
     Author:    Chris Carson
    Purpose:    shows "scrubbed" version of legacy Calls data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
SELECT  IssueCallID         = ISNULL(ic.IssueCallID, 0)
      , IssueID             = c.IssueID
      , FirstCallDate       = CAST( c.FirstCallDate   AS DATE )
      , CallPrice           = CAST( ISNULL( c.CallPrice, 100 ) AS DECIMAL(12,8) )
      , CallableMatDate     = CAST( c.CallableMatDate AS DATE )
  FROM  edata.dbo.Calls AS c
  LEFT  JOIN  dbo.IssueCall   AS ic
    ON  ic.IssueID = c.IssueID
        AND ISNULL( ic.CallDate,'1900-01-01' ) = ISNULL( c.FirstCallDate,'1900-01-01' )
        AND ic.CallPricePercent = ISNULL( c.CallPrice, 100 )
        AND ISNULL( ic.FirstCallableMatDate,'1900-01-01' ) = ISNULL( CallableMatDate,'1900-01-01' ) ;
