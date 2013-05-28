CREATE TRIGGER  tr_IssueEhlersEmployees
            ON  dbo.IssueEhlersEmployees
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_IssueEhlersEmployees
     Author:    ccarson
    Purpose:    writes EhlersFA, DisclosureCoordinator, and OriginatingFA data back to legacy dbo.Clients


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processClientAnalysts procedure
    2)  INSERT ClientIDs from trigger tables into temp storage
    3)  Stop processing if Analyst or DC data has not changed because not all clientAnalysts data writes back to edata.Clients 
    4)  UPDATE new analyst and DC data onto edata.Clients

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  NOT EXISTS ( SELECT 1 FROM inserted )
        IF  NOT EXISTS ( SELECT 1 FROM deleted )
            RETURN ;

    SET NOCOUNT ON ;

    DECLARE  @processIssueAnalysts   AS VARBINARY(128)    = CAST( 'processIssueAnalysts' AS VARBINARY(128) ) 
          , @systemTime                 AS DATETIME         = GETDATE()
          , @systemUser                 AS VARCHAR(20)      = dbo.udf_GetSystemUser() ;
    
    DECLARE @changedClients             AS TABLE ( ClientID INT ) ;
    
    DECLARE @legacyAnalystChecksum      AS INT = 0 
          , @convertedAnalystChecksum   AS INT = 0 
          , @legacyDCChecksum           AS INT = 0 
          , @convertedDCChecksum        AS INT = 0 ;
    
    
--  1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @processIssueAnalysts
        RETURN ;


--  2)  INSERT ClientIDs from trigger tables into temp storage
      WITH  changes AS (
            SELECT  IssueID FROM inserted
                UNION
            SELECT  IssueID FROM deleted ) ,

            changedData AS (
            SELECT  TOP 100 PERCENT
                    IssueID         = chg.IssueID
                  , FA1             = tvf.FA1
                  , FA2             = tvf.FA2
                  , FA3             = tvf.FA3
                  , Analyst         = tvf.Analyst
                  , BSC             = tvf.BSC
                  , ChangeBy        = @systemUser
                  , ChangeCode      = 'CVAnalyst'
                  , ChangeDate      = @systemTime
              FROM  changes                                             AS chg
         LEFT JOIN  Conversion.tvf_LegacyIssueAnalysts ( 'Converted' )  AS tvf ON tvf.IssueID = chg.IssueID
             ORDER  BY IssueID ) ,

            issues  AS (
            SELECT  * FROM edata.Issues
             WHERE  IssueId IN ( SELECT IssueID FROM changes ) )

     MERGE  issues      AS tgt
     USING  changedData AS src ON src.IssueID = tgt.IssueId
      WHEN  MATCHED THEN
            UPDATE SET  FA1             = src.FA1
                      , FA2             = src.FA2
                      , FA3             = src.FA3
                      , Analyst         = src.Analyst
                      , BSC             = src.BSC
                      , ChangeBy        = @systemUser
                      , ChangeDate      = @systemTime

      WHEN  NOT MATCHED BY SOURCE THEN
            UPDATE SET  FA1             = NULL
                      , FA2             = NULL
                      , FA3             = NULL
                      , Analyst         = NULL
                      , BSC             = NULL
                      , ChangeBy        = @systemUser
                      , ChangeDate      = @systemTime ;
    
 
END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END