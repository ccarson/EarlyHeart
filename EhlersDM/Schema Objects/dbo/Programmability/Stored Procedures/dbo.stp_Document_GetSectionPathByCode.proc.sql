/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/27/2011
-- Description: Get the path for a given 
--				document section by section code.
-- =============================================
CREATE PROCEDURE [dbo].[stp_Document_GetSectionPathByCode] 
	@DocumentID				int,
	@DocumentSectionCode	varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		DocumentPath,
		SectionStoredProcedure,
		DocumentSectionID
	FROM
		Documents.DocumentSections
	WHERE
		DocumentID = @DocumentID
	AND
		DocumentSectionCode = @DocumentSectionCode
	
END
*/