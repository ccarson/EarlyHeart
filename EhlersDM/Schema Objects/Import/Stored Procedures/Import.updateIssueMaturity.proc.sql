CREATE PROCEDURE Import.updateIssueMaturity ( @IssueID AS VARCHAR (30) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.updateIssueMaturity
     Author:    Chris Carson
    Purpose:    INSERTs record into dbo.IssueMaturity not found in MunexImport Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created

    Logic Summary:
    1)  SELECT first and last payment dates for Issue
    2)  Build a complete IssueMaturity table by filling in data for missing Maturities
    3)  INSERT missing records into IssueMaturity table

    Notes:
    The MunexImport spreadsheet Pricing Summary contains a summary of all maturities for an issue.
    Sometimes ( for Term Bonds ) certain maturity years are not shown in the Pricing Summary
    Those payment dates need to be kept in the system, so we use a recursive CTE to "fill in the blanks"
    
    This proc also needs to update records, because 

************************************************************************************************************************************
*/
BEGIN
SET NOCOUNT ON ;

    DECLARE @lastPayment AS DATE
          , @firstPayment AS DATE ;


--  1)  SELECT first and last payment dates for Issue
    SELECT  @lastPayment =  MAX( PaymentDate ) FROM dbo.IssueMaturity WHERE IssueID = @IssueID ;
    SELECT  @firstPayment = MIN ( PaymentDate ) FROM dbo.IssueMaturity WHERE IssueID = @IssueID ;


--  2)  Build a complete IssueMaturity table by filling in data for missing Maturities
      WITH  maturities AS (
            SELECT  IssueID
                  , PaymentDate
                  , InterestRate
                  , Term
                  , PriceToCall
                  , ReofferingYield
                  , ModifiedDate
                  , ModifiedUser
              FROM  dbo.IssueMaturity WHERE IssueID = @IssueID
                UNION ALL
             SELECT IssueID
                  , DATEADD( year, -1, PaymentDate )
                  , InterestRate
                  , Term
                  , PriceToCall
                  , ReofferingYield
                  , ModifiedDate
                  , ModifiedUser
              FROM  maturities
             WHERE  NOT EXISTS ( SELECT 1 FROM dbo.IssueMaturity
                                  WHERE IssueID = @IssueID AND PaymentDate = DATEADD( yy, -1, maturities.PaymentDate ) )
               AND  DATEADD( yy, -1, maturities.PaymentDate ) > @firstPayment )

--  3)  INSERT missing records into IssueMaturity table
    INSERT  dbo.IssueMaturity (
            IssueID, InsuranceFirmCategoriesID, LegacyInsuranceCode, PaymentDate
                , Cusip3, RefundedCusip, UnrefundedCusip, InterestRate, Term
                , PriceToCall, ReofferingYield, NotReoffered
                , ModifiedDate, ModifiedUser )
    SELECT  IssueID, NULL, '', PaymentDate
                , '', '', '', InterestRate, Term
                , PriceToCall, ReofferingYield, 0
                , ModifiedDate, ModifiedUser
      FROM  maturities AS m
     WHERE  NOT EXISTS ( SELECT 1 FROM dbo.IssueMaturity AS im
                          WHERE im.IssueID = m.IssueID AND im.PaymentDate = m.PaymentDate ) ;
END