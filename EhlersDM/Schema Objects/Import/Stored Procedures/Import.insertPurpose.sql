CREATE PROCEDURE Import.insertPurpose  ( @IssueID          AS VARCHAR(30)
                                       , @PurposeName      AS VARCHAR(150)
                                       , @PurposeOrder     AS VARCHAR(30) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.insertPurpose
     Author:    Chris Carson
    Purpose:    INSERTs record onto dbo.Purpose from MunexImport Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  INSERT input data into IssuePostBond ( CASTing relevant data as required )

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    INSERT  dbo.Purpose (
            IssueID
          , PurposeName
          , FinanceTypeID
          , UseProceedID
          , SubIssue
          , PurposeOrder
          , FundingSourceTypeID
          , BackingPayment
          , ModifiedDate
          , ModifiedUser )

    VALUES  ( 
            CAST( @IssueID          AS INT )
          , @PurposeName
          , NULL
          , NULL
          , 0
          , @PurposeOrder
          , NULL
          , ''
          , GETDATE()
          , dbo.udf_GetSystemUser() ) ;
END