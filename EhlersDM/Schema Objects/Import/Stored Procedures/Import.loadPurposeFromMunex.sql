CREATE PROCEDURE Import.loadPurposeFromMunex  ( @IssueID          AS VARCHAR(30)
                                              , @PurposeName      AS VARCHAR(150)
                                              , @PurposeOrder     AS VARCHAR(30) )                                              
AS
/*
************************************************************************************************************************************

  Procedure:    Import.loadPurposesFromMunex
     Author:    Chris Carson
    Purpose:    updates Ehlers with purpose data from Munex Import


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created

    Logic Summary:

************************************************************************************************************************************
*/

BEGIN
    SET NOCOUNT ON ;
    
      WITH  purposeIn AS ( 
            SELECT  IssueID         = CAST( @IssueID    AS INT )
                  , PurposeName     = @PurposeName
                  , PurposeOrder    = CAST( @PurposeOrder AS INT ) ) 

     MERGE  dbo.Purpose AS tgt
     USING  purposeIn   AS src ON src.IssueID = tgt.IssueID AND src.purposeOrder = tgt.purposeOrder
      WHEN  MATCHED THEN 
            UPDATE SET  PurposeName     = src.PurposeName
                      , ModifiedDate    = GETDATE()
                      , ModifiedUser    = dbo.udf_GetSystemUser() 
            
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, PurposeName, SubIssue, PurposeOrder, BackingPayment
                        , ModifiedDate, ModifiedUser ) 
            VALUES ( src.IssueID, src.PurposeName, 0, src.PurposeOrder, ''
                        , GETDATE(), dbo.udf_GetSystemUser() ) ; 
                        

END    
