CREATE TRIGGER dbo.tr_IssueCall ON dbo.IssueCall
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_IssueCall
     Author:    Chris Carson
    Purpose:    writes IssueCall changes back to legacy dbo.Calls

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processCalls procedure
    2)  Load CTE with temp data from inserted and deleted...
    3)  ...MERGE data from CTE onto edata.Calls

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processCalls AS VARBINARY(128) = CAST( 'processCalls' AS VARBINARY(128) ) ;


--  1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
    IF  CONTEXT_INFO() = @processCalls  RETURN ;


--  2)  Load temp table with data from inserted and deleted...
      WITH  triggerData AS (
            SELECT  IssueCallID         = IssueCallID
                  , IssueID             = IssueID
                  , FirstCallDate       = CallDate
                  , CallPrice           = CallPricePercent
                  , CallableMatDate     = FirstCallableMatDate
                  , isDelete            = CAST( 0 AS BIT )
              FROM  inserted
                UNION ALL
            SELECT  IssueCallID         = IssueCallID
                  , IssueID             = IssueID
                  , FirstCallDate       = CallDate
                  , CallPrice           = CallPricePercent
                  , CallableMatDate     = FirstCallableMatDate
                  , isDelete            = CAST( 1 AS BIT )
              FROM  deleted
             WHERE  IssueCallID NOT IN ( SELECT IssueCallID FROM inserted ) )


--  3)  ...MERGE data from CTE onto edata.Calls
     MERGE  edata.Calls AS tgt
     USING  triggerData     AS src
        ON  tgt.IssueID = src.IssueID
            AND ISNULL( tgt.FirstCallDate,'1900-01-01' ) = ISNULL( src.FirstCallDate,'1900-01-01' )
            AND tgt.CallPrice = src.CallPrice
            AND ISNULL( tgt.CallableMatDate,'1900-01-01' ) = ISNULL( src.CallableMatDate,'1900-01-01' )
      WHEN  MATCHED AND src.isDelete = 1 THEN
            DELETE
      WHEN  MATCHED THEN
            UPDATE
               SET  FirstCallDate   =  src.FirstCallDate
                  , CallPrice       =  src.CallPrice
                  , CallableMatDate =  src.CallableMatDate
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, FirstCallDate
                        , CallPrice, CallableMatDate )
            VALUES ( IssueID, FirstCallDate
                        , CallPrice, CallableMatDate ) ;
END
