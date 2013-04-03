CREATE PROCEDURE Import.updatePurposeFromMunex ( @purposeID         AS VARCHAR(30)
                                               , @purposeName       AS VARCHAR(150) ) 
AS
/*
************************************************************************************************************************************

  Procedure:    Import.updatePurposeFromMunex
     Author:    Chris Carson
    Purpose:    UPDATEs purpose with new name from Munex Import


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created

    Logic Summary:
    1)  UPDATE IssueName and IssueAmount on dbo.Issue ( CASTing relevant data as required )

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    UPDATE  dbo.Purpose
       SET  PurposeName     = @purposeName 
     WHERE  PurposeID       = CAST( @purposeID AS INT ) ;

END
