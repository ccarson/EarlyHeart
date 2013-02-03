/*
CREATE PROCEDURE dbo.usp_InsertRatingFirmsForIssue ( @IssueID INT )
AS
-- =============================================
-- Author:      mike kiemen
-- Create date: 7/5/2012
-- Description: inserts rows into IssueFirms table for the rating agencies
-- =============================================
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @MoodyFC    AS INT ;
    DECLARE @SPFC       AS INT ;
    DECLARE @FitchFC    AS INT ;

    SELECT  @MoodyFC = FirmCategoriesID
      FROM  dbo.FirmCategories
     WHERE  FirmCategoryID = 15 
            AND FirmID = ( SELECT FirmID FROM dbo.Firm WHERE FirmName = 'Moody''s Investors Service' ) ;

    SELECT  @SPFC = FirmCategoriesID
      FROM  dbo.FirmCategories
     WHERE  FirmCategoryID = 15 
            AND FirmID = ( SELECT FirmID FROM dbo.Firm WHERE FirmName = 'Standard & Poor''s' ) ;

    SELECT  @FitchFC = FirmCategoriesID
      FROM  dbo.FirmCategories
     WHERE  FirmCategoryID = 15 
            AND FirmID = ( SELECT FirmID FROM dbo.Firm WHERE FirmName = 'Fitch IBCA' ) ;

    IF NOT EXISTS(SELECT 1 from dbo.IssueFirms where IssueID = @IssueID and FirmCategoriesID = @MoodyFC)
        INSERT INTO dbo.IssueFirms (IssueID, FirmCategoriesID) VALUES (@IssueID,@MoodyFC ) ;

    IF NOT EXISTS(SELECT 1 from dbo.IssueFirms where IssueID = @IssueID and FirmCategoriesID = @SPFC)
        INSERT INTO dbo.IssueFirms (IssueID, FirmCategoriesID) VALUES (@IssueID,@SPFC ) ;

    IF NOT EXISTS(SELECT 1 from dbo.IssueFirms where IssueID = @IssueID and FirmCategoriesID = @FitchFC)
        INSERT INTO dbo.IssueFirms (IssueID, FirmCategoriesID) VALUES (@IssueID,@FitchFC ) ;
END
*/
