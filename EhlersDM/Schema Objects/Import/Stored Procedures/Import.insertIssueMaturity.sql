CREATE PROCEDURE Import.insertIssueMaturity ( @IssueID          AS VARCHAR (30)
                                            , @PaymentDate      AS VARCHAR (30)
                                            , @InterestRate     AS VARCHAR (30)
                                            , @Term             AS VARCHAR (30)
                                            , @PriceToCall      AS VARCHAR (30)
                                            , @ReofferingYield  AS VARCHAR (30)
                                            , @NotReoffered     AS VARCHAR (30) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.insertIssueMaturity
     Author:    Chris Carson
    Purpose:    INSERTs record onto dbo.IssueMaturity from MunexImport Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  INSERT input data into IssueMaturity ( CASTing relevant data as required )

************************************************************************************************************************************
*/
BEGIN
SET NOCOUNT ON ;

    INSERT  dbo.IssueMaturity (
            IssueID
          , InsuranceFirmCategoriesID
          , LegacyInsuranceCode
          , PaymentDate
          , Cusip3
          , RefundedCusip
          , UnrefundedCusip
          , InterestRate
          , Term
          , PriceToCall
          , ReofferingYield
          , NotReoffered
          , ModifiedDate
          , ModifiedUser )
    VALUES (
            CAST( @IssueID AS INT )
          , NULL
          , ''
          , CAST( @PaymentDate AS DATE )
          , ''
          , ''
          , ''
          , CAST( @InterestRate AS DECIMAL( 7,4 ) )
          , CAST( @Term AS SMALLINT )
          , CAST( @PriceToCall AS BIT )
          , CAST( @ReofferingYield AS DECIMAL( 7,4 ) )
          , CAST( @NotReoffered AS BIT )
          , GETDATE()
          , dbo.udf_GetSystemUser() ) ;

END