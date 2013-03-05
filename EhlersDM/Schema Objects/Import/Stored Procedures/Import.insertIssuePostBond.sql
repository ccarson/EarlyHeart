CREATE PROCEDURE Import.insertIssuePostBond ( @IssueID          AS VARCHAR(30)
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
    1)  INSERT input data into IssuePostBond ( CASTing relevant data as required )

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

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

    VALUES  ( 
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
          , dbo.udf_GetSystemUser() ) ;
END