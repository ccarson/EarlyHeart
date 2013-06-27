CREATE PROCEDURE Import.insertPurposeMaturity ( @IssueID          AS VARCHAR (30)
                                              , @PurposeName      AS VARCHAR (150)
                                              , @PaymentDate      AS VARCHAR (30)
                                              , @PaymentAmount    AS VARCHAR (30)
                                              , @InterestAmount   AS VARCHAR (30) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.insertPurposeMaturity
     Author:    Chris Carson
    Purpose:    INSERTs records onto dbo.PurposeMaturity and PurposeMaturityInterest from MunexImport Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  INSERT input data into IssueMaturity ( CASTing relevant data as required )

************************************************************************************************************************************
*/
BEGIN
SET NOCOUNT ON ;

    DECLARE @PurposeID          AS INT ;
    DECLARE @PurposeMaturityID  AS INT ;

    SELECT  @PurposeID = PurposeID
      FROM  dbo.Purpose
     WHERE  IssueID = CAST( @IssueID AS INT ) AND PurposeName = @PurposeName ;

--  1)  Insert PurposeMaturity
    IF  ( CAST( @PaymentAmount AS DECIMAL(15,2) ) > 0 )
    BEGIN
        INSERT  dbo.PurposeMaturity (
                PurposeID
              , PaymentDate
              , PaymentAmount
              , ModifiedDate
              , ModifiedUser )
        SELECT  @PurposeID
              , CAST( @PaymentDate   AS DATE )
              , CAST( @PaymentAmount AS DECIMAL(15,2) )
              , GETDATE()
              , dbo.udf_GetSystemUser() ;
        SELECT  @PurposeMaturityID = SCOPE_IDENTITY() ;
    END
    ELSE
        SELECT  TOP 1
                @PurposeMaturityID = PurposeMaturityID
          FROM  dbo.PurposeMaturity
         WHERE  PurposeID = @PurposeID AND CAST( @PaymentDate AS DATE ) < PaymentDate
         ORDER  BY PaymentDate ;

    IF  ( CAST( @InterestAmount AS DECIMAL(15,2) ) > 0 )
    INSERT  dbo.PurposeMaturityInterest (
            PurposeMaturityID
          , Amount
          , InterestDate
          , ModifiedDate
          , ModifiedUser )
    SELECT  @PurposeMaturityID
          , CAST( @InterestAmount   AS DECIMAL(15, 2) )
          , CAST( @PaymentDate     AS DATE )
          , GETDATE()
          , dbo.udf_GetSystemUser() ;

END