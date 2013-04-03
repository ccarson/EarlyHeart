CREATE TRIGGER tr_IssueFirms ON dbo.IssueFirms
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_IssueFirms
     Author:    Chris Carson
    Purpose:    Synchronizes IssueFirms data back to edata.IssueProfSvcs


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          Issues Conversion Bug #40 ( FA Firm not appearing )



************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT ON ;

    IF  NOT EXISTS ( SELECT 1 FROM inserted )
            AND
        NOT EXISTS ( SELECT 1 FROM deleted )
        RETURN ;

    DECLARE @processIssueFirms  AS VARBINARY(128)   = CAST( 'processIssueFirms' AS VARBINARY(128) ) ;

    DECLARE @codeBlockDesc01    AS SYSNAME          = ' do not process when trigger is invoked by conversion package'
          , @codeBlockDesc02    AS SYSNAME          = ' build temp storage with data from trigger tables'
          , @codeBlockDesc03    AS SYSNAME          = ' zero out temp storage where category does not exist in converted system'
          , @codeBlockDesc04    AS SYSNAME          = ' MERGE temp storage into edata.IssueProfSvcs ON INSERTs and UPDATEs'
          , @codeBlockDesc05    AS SYSNAME          = ' UPDATE edata.IssueProfSvcs FROM temp storage on DELETEs'
          , @codeBlockDesc06    AS SYSNAME          = ' UPDATE edata.Issues with FA Firm Data'
          , @codeBlockDesc07    AS SYSNAME          = ' UPDATE edata.Issues with DisseminationAgent Data' ;
    
    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @errorTypeID        AS INT
          , @errorSeverity      AS INT
          , @errorState         AS INT
          , @errorNumber        AS INT
          , @errorLine          AS INT
          , @errorProcedure     AS SYSNAME
          , @errorMessage       AS VARCHAR (MAX)    = NULL
          , @errorData          AS VARCHAR (MAX)    = NULL ;
          

    DECLARE @changedIssueData   AS TABLE ( IssueID  INT
                                         , Category VARCHAR (5)
                                         , FirmID   INT
                                         , FirmName VARCHAR (100) ) ;

    DECLARE @legacyChecksum     AS INT              = 0
          , @convertedChecksum  AS INT              = 0 ;

    DECLARE @categories         AS TABLE ( Category VARCHAR(5) ) ;


/**/SELECT  @codeBlockNum  = 1
/**/      , @codeBlockDesc = @codeBlockDesc01 ; -- do not process when trigger is invoked by conversion package

    IF  CONTEXT_INFO() = @processIssueFirms
        RETURN ;


/**/SELECT  @codeBlockNum  = 2
/**/      , @codeBlockDesc = @codeBlockDesc02 ; -- build temp storage with data from trigger tables

      WITH  changedIssues AS (
            SELECT  IssueID FROM inserted
                UNION
            SELECT  IssueID FROM deleted ) ,

            categories ( Category ) AS (
            SELECT 'esa' UNION ALL
            SELECT 'esc' UNION ALL
            SELECT 'pay' UNION ALL
            SELECT 'tru' UNION ALL
            SELECT 'und' UNION ALL
            SELECT 'bc' )

    INSERT  @changedIssueData ( IssueID, Category )
    SELECT  IssueID, Category FROM changedIssues CROSS JOIN categories ;

    
/**/SELECT  @codeBlockNum  = 3
/**/      , @codeBlockDesc = @codeBlockDesc03 ; -- zero out temp storage where category does not exist in converted system

    UPDATE  @changedIssueData
       SET  FirmID      = ISNULL( isf.FirmID, 0 )
          , FirmName    = isf.FirmName
      FROM  @changedIssueData AS a
 LEFT JOIN  Conversion.tvf_IssueFirms( 'Converted' ) AS isf ON isf.IssueID = a.IssueID AND isf.Category = a.Category ;


/**/SELECT  @codeBlockNum  = 4
/**/      , @codeBlockDesc = @codeBlockDesc04 ; -- MERGE temp storage into edata.IssueProfSvcs ON INSERTs and UPDATEs

    IF  EXISTS ( SELECT 1 FROM inserted ) 
         MERGE  edata.IssueProfSvcs AS tgt
         USING  @changedIssueData   AS src ON src.IssueID = tgt.IssueID AND src.Category = tgt.Category
          WHEN  MATCHED THEN
                UPDATE SET FirmID      = src.FirmID
                         , FirmName    = src.FirmName

          WHEN  NOT MATCHED BY TARGET THEN
                INSERT ( IssueID, Category, FirmID, FirmName )
                VALUES ( src.IssueID, src.Category, src.FirmID, src.FirmName ) ;
                
    ELSE

/**/SELECT  @codeBlockNum  = 5
/**/      , @codeBlockDesc = @codeBlockDesc05 ; -- UPDATE edata.IssueProfSvcs FROM temp storage on DELETEs

        UPDATE  edata.IssueProfSvcs
           SET  FirmID      = chg.FirmID
              , FirmName    = chg.FirmName
          FROM  edata.IssueProfSvcs AS ips
    INNER JOIN  @changedIssueData   AS chg ON chg.IssueID = ips.IssueID AND chg.Category = ips.Category ; 


/**/SELECT  @codeBlockNum  = 6
/**/      , @codeBlockDesc = @codeBlockDesc06 ; -- UPDATE edata.Issues with FA Firm Data

      WITH  newData AS (
            SELECT  IssueID, FirmID, FirmName, Category
              FROM  Conversion.tvf_IssueFirms( 'Converted' ) AS isf
             WHERE  EXISTS ( SELECT 1 FROM @changedIssueData AS chg WHERE chg.IssueID = isf.IssueID )
               AND  isf.Category = 'faf' )
    UPDATE  edata.Issues
       SET  FAFirmID    = isf.FirmID
          , FAFirm      = isf.FirmName
      FROM  edata.Issues    AS iss
INNER JOIN  newData         AS isf ON isf.IssueID = iss.IssueID ;


/**/SELECT  @codeBlockNum  = 7
/**/      , @codeBlockDesc = @codeBlockDesc07 ; -- UPDATE edata.Issues with DisseminationAgent Data

      WITH  newData AS (
            SELECT  IssueID, FirmID, FirmName, Category
              FROM  Conversion.tvf_IssueFirms( 'Converted' ) AS isf
             WHERE  EXISTS ( SELECT 1 FROM @changedIssueData AS chg WHERE chg.IssueID = isf.IssueID )
               AND  isf.Category = 'DS' )
    UPDATE  edata.Issues
       SET  DissemAgentID   = isf.FirmID
      FROM  edata.Issues    AS iss
INNER JOIN  newData         AS isf ON isf.IssueID = iss.IssueID ;


END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION ;
    EXECUTE dbo.processEhlersError ;
END CATCH
END