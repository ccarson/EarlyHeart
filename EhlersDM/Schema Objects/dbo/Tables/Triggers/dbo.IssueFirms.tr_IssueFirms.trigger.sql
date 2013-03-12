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


    Logic Summary:
    1)  do not process when trigger is invoked by conversion package
    2)  INSERT IssueID into @changedIssues
    3)  Clear out edata.IssueProfSvcs for affected firms
    4)  UPDATE edata.IssueProfSvcs with current dbo.IssueFirms data
    5)  UPDATE edata.Issues with FA Firm Data


************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT ON ;

    IF  NOT EXISTS ( SELECT 1 FROM inserted CROSS JOIN deleted )
        RETURN ;

    DECLARE @processIssueFirms  AS VARBINARY(128) = CAST( 'processIssueFirms' AS VARBINARY(128) ) ;

    DECLARE @codeBlockDesc01    AS VARCHAR (128)    = 'do not process when trigger is invoked by conversion package'
          , @codeBlockDesc02    AS VARCHAR (128)    = 'INSERT IssueID into @changedIssues'
          , @codeBlockDesc03    AS VARCHAR (128)    = 'Clear out edata.IssueProfSvcs for affected firms'
          , @codeBlockDesc04    AS VARCHAR (128)    = 'UPDATE edata.IssueProfSvcs with current dbo.IssueFirms data'
          , @codeBlockDesc05    AS VARCHAR (128)    = 'UPDATE edata.Issues with FA Firm Data' ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS VARCHAR (128)
          , @errorTypeID        AS INT
          , @errorSeverity      AS INT
          , @errorState         AS INT
          , @errorNumber        AS INT
          , @errorLine          AS INT
          , @errorProcedure     AS VARCHAR (128)
          , @errorMessage       AS VARCHAR (MAX) = NULL
          , @errorData          AS VARCHAR (MAX) = NULL ;

    DECLARE @changedIssues      AS TABLE ( IssueID INT PRIMARY KEY CLUSTERED ) ;

    DECLARE @legacyChecksum     AS INT = 0
          , @convertedChecksum  AS INT = 0 ;


/**/SELECT  @codeBlockNum  = 1
/**/      , @codeBlockDesc = @codeBlockDesc01 ; -- do not process when trigger is invoked by conversion package

    IF  CONTEXT_INFO() = @processIssueFirms
        RETURN ;


/**/SELECT  @codeBlockNum  = 2
/**/      , @codeBlockDesc = @codeBlockDesc02 ; -- INSERT IssueID into @changedIssues

    INSERT  @changedIssues
    SELECT  IssueID FROM inserted
        UNION
    SELECT  IssueID FROM deleted ;


/**/SELECT  @codeBlockNum  = 3
/**/      , @codeBlockDesc = @codeBlockDesc03 ; -- Clear out edata.IssueProfSvcs for affected firms

    UPDATE  edata.IssueProfSvcs
       SET  FirmID   = 0
          , Firmname = NULL
      FROM  edata.IssueProfSvcs AS ips
INNER JOIN  @changedIssues      AS iss ON iss.IssueID = ips.IssueID ;


/**/SELECT  @codeBlockNum  = 4
/**/      , @codeBlockDesc = @codeBlockDesc04 ; -- UPDATE edata.IssueProfSvcs with current dbo.IssueFirms data

      WITH  newData AS (
            SELECT  IssueID, FirmID, FirmName, Category
              FROM  Conversion.tvf_IssueFirms( 'Converted' ) AS isf
             WHERE  EXISTS ( SELECT 1 FROM @changedIssues AS chg WHERE chg.IssueID = isf.IssueID ) )
    UPDATE  edata.IssueProfSvcs
       SET  FirmID   = isf.FirmID
          , Firmname = isf.FirmName
      FROM  edata.IssueProfSvcs AS ips
INNER JOIN  newData             AS isf ON isf.IssueID = ips.IssueID ;


/**/SELECT  @codeBlockNum  = 5
/**/      , @codeBlockDesc = @codeBlockDesc05 ; -- UPDATE edata.Issues with FA Firm Data

      WITH  newData AS (
            SELECT  IssueID, FirmID, FirmName, Category
              FROM  Conversion.tvf_IssueFirms( 'Converted' ) AS isf
             WHERE  EXISTS ( SELECT 1 FROM @changedIssues AS chg WHERE chg.IssueID = isf.IssueID )
               AND  isf.Category = 'faf' )
    UPDATE  edata.Issues
       SET  FAFirmID    = isf.FirmID
          , FAFirm      = isf.FirmName
      FROM  edata.Issues    AS iss
INNER JOIN  newData         AS isf ON isf.IssueID = iss.IssueID ;


END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION ;
    EXECUTE dbo.processEhlersError ;
END CATCH
END