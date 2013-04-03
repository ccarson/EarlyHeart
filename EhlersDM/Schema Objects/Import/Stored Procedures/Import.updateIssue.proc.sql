CREATE PROCEDURE Import.updateIssue  ( @IssueID         AS VARCHAR(30)
                                     , @IssueName       AS VARCHAR(150)
                                     , @IssueAmount     AS VARCHAR(30) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.updateIssue
     Author:    Chris Carson
    Purpose:    UPDATEs current issue with data from Munex Import


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created

    Logic Summary:
    1)  UPDATE IssueName and IssueAmount on dbo.Issue ( CASTing relevant data as required )

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    UPDATE  dbo.Issue
       SET  IssueName       = CAST( @IssueName      AS VARCHAR (150) )
          , IssueAmount     = CAST( @IssueAmount    AS DECIMAL (15,2) )
          , ModifiedDate    = GETDATE()
          , ModifiedUser    = 'Munex - ' + dbo.udf_GetSystemUser()
     WHERE  IssueID         = CAST( @IssueID        AS INT ) ;

END