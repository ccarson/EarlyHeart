CREATE PROCEDURE Import.insertPurposeUse ( @IssueID     AS VARCHAR (30)
                                         , @PurposeName AS VARCHAR (150)
                                         , @UseName     AS VARCHAR (100)
                                         , @Amount      AS VARCHAR (30) ) 
AS
/*
************************************************************************************************************************************

  Procedure:    Import.insertPurposeUse
     Author:    Chris Carson
    Purpose:    INSERTs records onto dbo.PurposeUse from MunexImport Data


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

    SELECT  @PurposeID = PurposeID
      FROM  dbo.Purpose
     WHERE  IssueID = @IssueID and PurposeName = @PurposeName ;

     
--  1)  Insert PurposeUse
    INSERT  dbo.PurposeUse (
                PurposeID
              , UseName
              , Amount
              , ModifiedDate
              , ModifiedUser )
        SELECT  @PurposeID
              , @UseName
              , CAST( @Amount AS DECIMAL(15,2) )
              , GETDATE()
              , dbo.udf_GetSystemUser() ;

END