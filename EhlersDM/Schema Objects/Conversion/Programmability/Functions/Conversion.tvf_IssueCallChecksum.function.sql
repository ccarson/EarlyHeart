CREATE FUNCTION Conversion.tvf_IssueCallChecksum ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_IssueCallChecksum
     Author:    Chris Carson
    Purpose:    Computes the checksum for a given IssueCallID


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source         VARCHAR(20)     Legacy|Converted

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  IssueCallID      = ISNULL( ic.IssueCallID, 0 )
              , IssueID          = c.IssueID
              , FirstCallDate    = CONVERT( VARCHAR(10), ISNULL( FirstCallDate, '1900-01-01' ), 120 )
              , CallPricePercent = CAST( CAST( ISNULL( CallPrice, 100 ) AS DECIMAL(12,8) ) AS VARCHAR(20) )
              , CallableMatDate  = CONVERT( VARCHAR(10), ISNULL( CallableMatDate, '1900-01-01' ), 120 )
          FROM  edata.dbo.Calls AS c
     LEFT JOIN  dbo.IssueCall   AS ic
            ON  ic.IssueID = c.IssueID
                AND ISNULL(ic.CallDate,'1900-01-01') = ISNULL(c.FirstCallDate,'1900-01-01')
                AND ic.CallPricePercent = ISNULL( c.CallPrice, 100 )
                AND ISNULL(ic.FirstCallableMatDate,'1900-01-01') = ISNULL(CallableMatDate,'1900-01-01')
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  IssueCallID      = IssueCallID
              , IssueID          = IssueID
              , FirstCallDate    = CAST( ISNULL( CallDate, '1900-01-01' ) AS VARCHAR(10) )
              , CallPricePercent = CAST( CallPricePercent AS VARCHAR(20) )
              , CallableMatDate  = CAST( ISNULL( FirstCallableMatDate, '1900-01-01' ) AS VARCHAR(10) )
          FROM  dbo.IssueCall AS ic
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  IssueCallID, IssueID, FirstCallDate, CallPricePercent, CallableMatDate FROM legacy UNION ALL
        SELECT  IssueCallID, IssueID, FirstCallDate, CallPricePercent, CallableMatDate FROM converted )

SELECT  IssueCallID
      , IssueCallChecksum = CAST ( HASHBYTES ( 'md5', CAST( IssueCallID AS VARCHAR(20) )
                                                    + CAST( IssueID     AS VARCHAR(20) )
                                                    + FirstCallDate
                                                    + CallPricePercent
                                                    + CallableMatDate ) AS VARBINARY(128) )
  FROM  inputData ;
