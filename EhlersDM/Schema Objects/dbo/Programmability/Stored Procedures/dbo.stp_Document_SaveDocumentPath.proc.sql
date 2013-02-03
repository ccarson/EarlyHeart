/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/27/2011
-- Description:	Store the document path for the
--				specified document section.
-- =============================================
CREATE PROCEDURE [dbo].[stp_Document_SaveDocumentPath]
	@DocumentSectionID	int, 
	@DocumentPath		varchar(2000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE 
		Documents.DocumentSections
	SET 
		DocumentPath = @DocumentPath
	WHERE  
		DocumentSectionID = @DocumentSectionID
END
*/