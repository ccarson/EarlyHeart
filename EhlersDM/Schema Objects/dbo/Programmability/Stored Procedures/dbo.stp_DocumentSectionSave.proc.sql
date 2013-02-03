/*
CREATE PROCEDURE [dbo].[stp_DocumentSectionSave]
	@NewSectionName			varchar(50),
	@CurrDocumentSectionID	int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/23/2010
-- Description: Save a new section.
-- =============================================
	-- interfering with SELECT statements.
	
	DECLARE @DocumentIDToUse	int
	DECLARE @NewSectionCode		varchar(50)
	DECLARE @Pos				int
	DECLARE @CurrChar			char(1)
	
	SELECT 
		@DocumentIDToUse = DocumentID
	FROM
		Documents.DocumentSections
	WHERE
		DocumentSectionID = @CurrDocumentSectionID

	-- Remove all non-alphanumeric characters from the section code.
	SET @NewSectionCode = ''
	SET @Pos = 1

	WHILE @Pos <= LEN(@NewSectionName)
	BEGIN
		SET @CurrChar = SUBSTRING(@NewSectionName, @Pos, 1)

		IF (ASCII(@CurrChar) >= 48 AND ASCII(@CurrChar) <= 57)
			OR (ASCII(@CurrChar) >= 65 AND ASCII(@CurrChar) <= 90)
			OR (ASCII(@CurrChar) >= 97 AND ASCII(@CurrChar) <= 122)
		BEGIN
			SET @NewSectionCode = @NewSectionCode + @CurrChar
		END

		SET @Pos = @Pos + 1
	END

	
	
	INSERT INTO Documents.DocumentSections (DocumentID, DocumentSectionName,  DocumentSectionCode)
								VALUES(@DocumentIDToUse,   @NewSectionName,   @NewSectionCode)
END
*/