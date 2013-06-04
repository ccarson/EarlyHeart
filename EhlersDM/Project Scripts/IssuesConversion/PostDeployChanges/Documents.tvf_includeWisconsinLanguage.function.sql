CREATE FUNCTION Documents.tvf_includeWisconsinLanguage( @IssueID AS INT )
RETURNS TABLE
AS
/*
************************************************************************************************************************************

   Function:    Documents.tvf_includeWisconsinLanguage
     Author:    Chris Carson
    Purpose:    Returns Boolean to determine whether or not Wisconsin-specific language needs to be included in the OS

    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created -- Issues Conversion

    Function Arguments:
    @IssueID         int        IssueID for which function will extract data

    Notes:

************************************************************************************************************************************
*/
RETURN

      WITH  a AS (
            SELECT  TOP 3
                    N=ROW_NUMBER() OVER ( ORDER BY PaymentDate DESC)
                  , PaymentDate
              FROM  Documents.vw_IssueMaturityAmounts
             WHERE  IssueID = @IssueID ) ,

            b AS (
            SELECT  N=ROW_NUMBER() OVER ( ORDER BY N DESC )
                  , PaymentDate
              FROM  a )

    SELECT  N=COUNT(*)
      FROM  a
INNER JOIN  b ON a.N = b.N
     WHERE  a.N = 1 AND DATEDIFF( month, b.PaymentDate, a.PaymentDate) = 18 ;

GO

