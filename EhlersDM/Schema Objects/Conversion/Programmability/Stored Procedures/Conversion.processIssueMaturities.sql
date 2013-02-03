CREATE PROCEDURE Conversion.processIssueMaturities
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processIssueMaturities
     Author:    Chris Carson
    Purpose:    converts legacy Issue Maturities data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Load edata.dbo.Maturities data into temporary storage
    2)  Load dbo.IssueMaturity with data from temporary storage
    3)  Load dbo.Purpose with data from temporary storage
    4)  Load dbo.Purpose with data from temporary storage
    5)  Load dbo.PurposeMaturityRefunding with data from temporary storage
    6)  Print control totals


************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @IssueMaturityRecords               AS INT = 0
          , @PurposeRecords                     AS INT = 0
          , @PurposeMaturityRecords             AS INT = 0
          , @PurposeMaturityRefundingRecords    AS INT = 0 
          , @rc                                 AS INT = 0 
          , @SystemDate                         AS DATETIME = GETDATE() ;


--  1)  Compute CHECKSUM for each view of data used in proc
    SELECT  IssueMaturityID = IDENTITY( INT, 1, 1 ), *
      INTO  #legacyMaturities
      FROM  Conversion.vw_legacyMaturities ;
    SELECT  @IssueMaturityRecords = @@ROWCOUNT ;


--  2)  Load dbo.IssueMaturity with data from temporary storage
    SET IDENTITY_INSERT dbo.IssueMaturity ON ;
    INSERT  dbo.IssueMaturity (
            IssueMaturityID, IssueID
          , InsuranceFirmCategoriesID, LegacyInsuranceCode
          , PaymentDate
          , Cusip3
          , InterestRate, Term, PriceToCall
          , ReofferingYield, NotReoffered
          , ModifiedDate, ModifiedUser )
    SELECT  IssueMaturityID, IssueID
          , InsuranceFirmCategoriesID, Insurance
          , PaymentDate
          , Cusip3
          , InterestRate, Term, PriceToCall
          , ReofferingYield, NotReoffered
          , GETDATE(), 'convertMaturities'
      FROM  #legacyMaturities ;
    SET IDENTITY_INSERT dbo.IssueMaturity OFF ;


--  3)  Load dbo.Purpose with data from temporary storage
    SET IDENTITY_INSERT dbo.Purpose ON ;
    INSERT  dbo.Purpose (
            PurposeID
          , IssueID
          , PurposeName
          , ModifiedDate
          , ModifiedUser )
    SELECT  IssueID
          , IssueID
          , CAST( 'Conversion Purpose' AS VARCHAR(150) )
          , GETDATE()
          , 'convertMaturities'
      FROM  dbo.Issue ;
    SET IDENTITY_INSERT dbo.Purpose OFF ;


--  4)  Load dbo.PurposeMaturity with data from temporary storage
    INSERT  dbo.PurposeMaturity (
            PurposeID, PaymentDate, PaymentAmount, ModifiedDate, ModifiedUser )
    SELECT  IssueID, PaymentDate, IssueAmount, @SystemDate, 'convertMaturities'
      FROM  #legacyMaturities ;


--  5)  Load dbo.PurposeMaturityRefunding with data from temporary storage
    INSERT  dbo.PurposeMaturityRefunding (
            PurposeMaturityID, Amount, ModifiedDate, ModifiedUser )
    SELECT  PurposeMaturityID, RefundAmount, @SystemDate, 'convertMaturities'
      FROM  dbo.PurposeMaturity AS pm
INNER JOIN  #legacyMaturities AS l
        ON  l.IssueID = pm.PurposeID
            AND l.PaymentDate = pm.PaymentDate
     WHERE  l.RefundAmount > 0 ;


--  6) Print control totals
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Records loaded to dbo.IssueMaturity  = ' + CAST( @IssueMaturityRecords AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
