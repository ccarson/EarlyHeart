CREATE PROCEDURE Import.insertPurposeSourcesAndUses ( @SourcesOrUses    AS VARCHAR (30)
                                                    , @IssueID          AS VARCHAR (30)
                                                    , @PurposeName      AS VARCHAR (150)
                                                    , @LineItemName     AS VARCHAR (100)
                                                    , @DisplayOrder     AS VARCHAR (30)
                                                    , @Amount           AS VARCHAR (30) ) 
AS
/*
************************************************************************************************************************************

  Procedure:    Import.insertPurposeSourceAndUses
     Author:    Chris Carson
    Purpose:    INSERTs records onto either dbo.PurposeSource or dbo.PurposeUse from MunexImport Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-06-27          created

    Logic Summary:
    1)  INSERT record into PurposeSources or PurposeUses depending on passed-in input parameter

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
          , @LineItemName 
          , CAST( @Amount AS DECIMAL(15,2) )
          , CAST( @DisplayOrder AS INT )
          , GETDATE()
          , dbo.udf_GetSystemUser() 
     WHERE  @SourcesOrUses = 'Sources' ;

--  2)  Insert PurposeUse
    INSERT  dbo.PurposeUse (
            PurposeID
          , UseName
          , Amount
          , DisplayOrder
          , ModifiedDate
          , ModifiedUser )
    SELECT  @PurposeID
          , @LineItemName 
          , CAST( @Amount AS DECIMAL(15,2) )
          , CAST( @DisplayOrder AS INT )
          , GETDATE()
          , dbo.udf_GetSystemUser() 
     WHERE  @SourcesOrUses = 'Uses' ;


END
GO

