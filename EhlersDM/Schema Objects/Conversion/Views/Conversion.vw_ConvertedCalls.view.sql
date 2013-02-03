CREATE VIEW Conversion.vw_ConvertedCalls
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedCalls
     Author:    Chris Carson
    Purpose:    Provides legacy view of converted dbo.IssueCall table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
SELECT  ic.IssueCallID
      , IssueID
      , FirstCallDate       = CallDate
      , CallPrice           = CallPricePercent
      , CallableMatDate     = FirstCallableMatDate
  FROM  dbo.IssueCall AS ic
 WHERE  CallTypeID = 3 ;
