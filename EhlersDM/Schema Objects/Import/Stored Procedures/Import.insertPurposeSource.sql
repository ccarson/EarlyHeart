CREATE PROCEDURE Import.insertPurposeSource ( @IssueID      AS VARCHAR (30)
                                            , @PurposeName  AS VARCHAR (150)
                                            , @SourceName   AS VARCHAR (100)
                                            , @DisplayOrder AS VARCHAR (30)
                                            , @Amount       AS VARCHAR (30) ) 
AS
/*
************************************************************************************************************************************

  Procedure:    Import.insertPurposeSource
     Author:    Chris Carson
    Purpose:    INSERTs records onto dbo.PurposeSource from MunexImport Data


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

     
--  1)  Insert PurposeSource
    INSERT  dbo.PurposeSource (
                PurposeID
              , SourceName
              , Amount
              , DisplayOrder
              , ModifiedDate
              , ModifiedUser )
        SELECT  @PurposeID
              , @SourceName 
              , CAST( @Amount AS DECIMAL(15,2) )
              , CAST( @DisplayOrder AS INT )
              , GETDATE()
              , dbo.udf_GetSystemUser() ;

END