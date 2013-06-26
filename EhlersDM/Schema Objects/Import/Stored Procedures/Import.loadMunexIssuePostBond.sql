CREATE PROCEDURE [Import].[loadMunexIssuePostBond] ( @IssueID          AS VARCHAR(30)
                                               , @BondYear         AS VARCHAR(30)
                                               , @ArbitrageYield   AS VARCHAR(30)
                                               , @AICPercent       AS VARCHAR(30)
                                               , @TICPercent       AS VARCHAR(30)
                                               , @NICPercent       AS VARCHAR(30)
                                               , @NICAmount        AS VARCHAR(30)
                                               , @AverageCoupon    AS VARCHAR(30)
                                               , @AverageLife      AS VARCHAR(30) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.insertIssuePostBond
     Author:    Chris Carson
    Purpose:    INSERTs record onto dbo.IssuePostBond from MunexImport Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

SET NOCOUNT ON ;

    DECLARE @FirstInterestDate AS DATE ;


    IF  EXISTS ( SELECT  1 FROM dbo.IssuePostBond AS i
                  WHERE  i.IssueID = CAST( @IssueID AS INT ) ) 
        UPDATE  dbo.IssuePostBond
           SET  BondYear        = CAST( @BondYear         AS DECIMAL(15,2) )
              , ArbitrageYield  = CAST( @ArbitrageYield   AS DECIMAL(11, 8) )
              , AICPercent      = CAST( @AICPercent       AS DECIMAL(11, 8) )
              , TICPercent      = CAST( @TICPercent       AS DECIMAL(11, 8) )
              , NICPercent      = CAST( @NICPercent       AS DECIMAL(11, 8) )
              , NICAmount       = CAST( @NICAmount        AS DECIMAL(15, 2) )
              , AverageCoupon   = CAST( @AverageCoupon    AS DECIMAL(11, 8) )
              , AverageLife     = CAST( @AverageLife      AS DECIMAL(11, 8) )
              , ModifiedDate    = GETDATE()
              , ModifiedUser    = dbo.udf_GetSystemUser() 
         WHERE  IssueID = CAST( @IssueID AS INT ) ; 
         
    ELSE    
        INSERT  dbo.IssuePostBond (
                IssueID
              , BondYear
              , ArbitrageYield
              , AICPercent
              , TICPercent
              , NICPercent
              , NICAmount
              , AverageCoupon
              , AverageLife
              , ModifiedDate
              , ModifiedUser )
        SELECT  
            CAST( @IssueID          AS INT )
          , CAST( @BondYear         AS DECIMAL(15,2) )
          , CAST( @ArbitrageYield   AS DECIMAL(11, 8) )
          , CAST( @AICPercent       AS DECIMAL(11, 8) )
          , CAST( @TICPercent       AS DECIMAL(11, 8) )
          , CAST( @NICPercent       AS DECIMAL(11, 8) )
          , CAST( @NICAmount        AS DECIMAL(15, 2) )
          , CAST( @AverageCoupon    AS DECIMAL(11, 8) )
          , CAST( @AverageLife      AS DECIMAL(11, 8) )
          , GETDATE()
          , dbo.udf_GetSystemUser() ;

    
    SELECT  @FirstInterestDate = MIN(InterestDate) 
      FROM  dbo.PurposeMaturityInterest WHERE PurposeMaturityID IN 
            ( SELECT PurposeMaturityID FROM dbo.PurposeMaturity WHERE PurposeID IN 
                ( SELECT PurposeID FROM dbo.Purpose WHERE issueID = CAST( @IssueID AS INT ) ) ) ;

    UPDATE  dbo.Issue
       SET  FirstInterestDate = @FirstInterestDate
     WHERE  IssueID = CAST( @IssueID AS INT ) ;

END TRY
BEGIN CATCH
END CATCH
END
