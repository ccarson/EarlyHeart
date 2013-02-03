/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/23/2010
-- Description: Get the list of document sections
--				based on a document section ID.
-- =============================================
CREATE PROCEDURE [dbo].[stp_DocumentSectionListForSection]
	@DocumentSectionID	varchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT
		DocumentSectionName,
		DocumentSectionCode,
		DocumentSectionID,
		SectionStoredProcedure
	FROM
		Documents.DocumentSections
	WHERE
		DocumentID = (SELECT DocumentID 
										FROM Documents.DocumentSections
										WHERE DocumentSectionID = @DocumentSectionID)
	ORDER BY
		DocumentSectionName
		
END
*/