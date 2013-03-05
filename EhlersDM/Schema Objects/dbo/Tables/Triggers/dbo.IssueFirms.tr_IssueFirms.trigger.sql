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


    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processIssueFirms procedure
    2)  Stop processing unless the new FirmCategories actually appear on edata.IssueProfSvcs
    3)  Update edata.Issues with relevant data from dbo.Issue

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processIssueFirms AS VARBINARY(128) = CAST( 'processIssueFirms' AS VARBINARY(128) ) ;

    DECLARE @changedIssues AS TABLE ( IssueID INT ) ;

    DECLARE @legacyChecksum AS INT = 0
          , @convertedChecksum AS INT = 0 ;


--  1)  Stop processing when trigger is invoked by Conversion.processIssues procedure
    IF  CONTEXT_INFO() = @processIssueFirms
        RETURN ;


--  2)  INSERT IssueID from trigger tables into @changedIssues
    INSERT  @changedIssues
    SELECT  IssueID FROM inserted
        UNION
    SELECT  IssueID FROM deleted ;


--  2)  Continue processing only if data that relates edata.IssueProfSvcs has changed
    SELECT  @legacyChecksum = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_IssueFirms( 'Legacy' ) AS l
     WHERE  EXISTS ( SELECT 1 FROM @changedIssues AS i WHERE i.IssueID = l.IssueID ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_IssueFirms( 'Converted' ) AS c
     WHERE  EXISTS ( SELECT 1 FROM @changedIssues AS i WHERE i.IssueID = c.IssueID ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        RETURN ;


--  3)  Clear out edata.IssueProfSvcs for affected firms
    UPDATE  edata.IssueProfSvcs
       SET  FirmID   = 0
          , Firmname = NULL
      FROM  edata.IssueProfSvcs AS ips
INNER JOIN  @changedIssues          AS iss ON iss.IssueID = ips.IssueID ;


--  4)  UPDATE edata.IssueProfSvcs with current dbo.IssueFirms data
    UPDATE  edata.IssueProfSvcs
       SET  FirmID   = isf.FirmID
          , Firmname = isf.FirmName
      FROM  edata.IssueProfSvcs                  AS ips
INNER JOIN  Conversion.tvf_IssueFirms( 'Converted' ) AS isf ON isf.IssueID = ips.IssueID AND isf.Category = ips.Category
INNER JOIN  @changedIssues AS iss ON iss.IssueID = ips.IssueID ;

END