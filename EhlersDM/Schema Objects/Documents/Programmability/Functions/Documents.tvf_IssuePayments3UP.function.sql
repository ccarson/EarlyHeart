CREATE FUNCTION Documents.tvf_IssuePayments3UP ( @IssueID AS INT )
RETURNS TABLE 
WITH SCHEMABINDING 
AS
/*
************************************************************************************************************************************

   Function:    Documents.tvf_IssuePayments3UP
     Author:    Chris Carson
    Purpose:    returns Issue Maturities and payments data in a 3-wide format

    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created

    Function Arguments:
    @IssueID         int                IssueID for which function will extract data

    Notes:

************************************************************************************************************************************
*/
RETURN

      WITH  groupings AS ( 
            SELECT  N = NTILE( 3 ) OVER ( ORDER BY PaymentDate ), PaymentDate, Amount 
              FROM  Documents.vw_IssueMaturityAmounts 
             WHERE  IssueID = @IssueID ) ,

            column1 AS ( 
            SELECT  N = ROW_NUMBER() OVER ( ORDER BY PaymentDate ), PaymentDate, Amount 
              FROM  groupings
             WHERE  N = 1 ) ,

            column2 AS ( 
            SELECT  N = ROW_NUMBER() OVER ( ORDER BY PaymentDate ), PaymentDate, Amount 
              FROM  groupings
             WHERE  N = 2 ) ,

            column3 AS ( 
            SELECT  N = ROW_NUMBER() OVER ( ORDER BY PaymentDate ), PaymentDate, Amount 
              FROM  groupings
             WHERE  N = 3 )
             
    SELECT  TOP 100 PERCENT
            N               = a.N
          , PaymentDate1    = a.PaymentDate
          , Amount1         = a.Amount
          , PaymentDate2    = b.PaymentDate
          , Amount2         = b.Amount
          , PaymentDate3    = c.PaymentDate
          , Amount3         = c.Amount
      FROM  column1 AS a 
 LEFT JOIN  column2 AS b ON b.N = a.N
 LEFT JOIN  column3 AS c ON c.N = a.N 
     ORDER  BY a.N ;
