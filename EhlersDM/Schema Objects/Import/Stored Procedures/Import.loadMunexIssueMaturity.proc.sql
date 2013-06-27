CREATE PROCEDURE Import.loadMunexIssueMaturity ( @IssueID          AS VARCHAR (30)
                                               , @PaymentDate      AS VARCHAR (30)
                                               , @InterestRate     AS VARCHAR (30)
                                               , @Term             AS VARCHAR (30)
                                               , @PriceToCall      AS VARCHAR (30)
                                               , @ReofferingYield  AS VARCHAR (30)
                                               , @NotReoffered     AS VARCHAR (30) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.loadMunexIssueMaturity
     Author:    Chris Carson
    Purpose:    given an issue Maturity record from Munex, apply it to Ehlers


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created

    Logic Summary:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

SET NOCOUNT ON ;

    IF  EXISTS ( SELECT  1 FROM dbo.IssueMaturity AS i
                  WHERE  i.IssueID = CAST( @IssueID AS INT )
                    AND  i.PaymentDate = CAST (@PaymentDate AS DATE ) )
        UPDATE  dbo.IssueMaturity
           SET  InterestRate     = CAST( @InterestRate AS DECIMAL( 7,4 ) )
              , Term             = CAST( @Term AS SMALLINT )
              , PriceToCall      = CAST( @PriceToCall AS BIT )
              , ReofferingYield  = CAST( @ReofferingYield AS DECIMAL( 7,4 ) )
              , NotReoffered     = CAST( @NotReoffered AS BIT )
              , ModifiedDate     = GETDATE()
              , ModifiedUser     = dbo.udf_GetSystemUser()
         WHERE  IssueID     = CAST( @IssueID AS INT )
           AND  PaymentDate = CAST (@PaymentDate AS DATE )
    ELSE
        INSERT  dbo.IssueMaturity (
                IssueID
              , PaymentDate
              , InterestRate
              , Term
              , PriceToCall
              , ReofferingYield
              , NotReoffered
              , ModifiedDate
              , ModifiedUser )
        SELECT  IssueID         = CAST( @IssueID AS INT )
              , PaymentDate     = CAST( @PaymentDate AS DATE )
              , InterestRate    = CAST( @InterestRate AS DECIMAL( 7,4 ) )
              , Term            = CAST( @Term AS SMALLINT )
              , PriceToCall     = CAST( @PriceToCall AS BIT )
              , ReofferingYield = CAST( @ReofferingYield AS DECIMAL( 7,4 ) )
              , NotReoffered    = CAST( @NotReoffered AS BIT )
              , ModifiedDate    = GETDATE()
              , ModifiedUser    = dbo.udf_GetSystemUser() ; 
              
END TRY
BEGIN CATCH
END CATCH
END