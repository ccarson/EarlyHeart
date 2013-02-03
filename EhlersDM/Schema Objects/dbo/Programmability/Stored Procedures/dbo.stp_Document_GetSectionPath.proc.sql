/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/27/2011
-- Description: Get the path for a given 
--				document section.
-- =============================================
CREATE PROCEDURE [dbo].[stp_Document_GetSectionPath] 
	@DocumentSectionID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		DocumentPath
	FROM
		Documents.DocumentSections
	WHERE
		DocumentSectionID = @DocumentSectionID
	
END
*/