/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 1/31/2011
-- Description:	Create a new document along with
--				the Main section of that document.
-- =============================================
CREATE PROCEDURE [dbo].[stp_Document_CreateDocument]
	@DocumentName varchar(200),
	@DocumentPath varchar(2000),
	@IncludeDefaults bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DocumentID				int
	DECLARE @DocumentSectionID		int
	DECLARE @DefaultStoredProcCall	varchar(300)
	
	
	-- Set the stored procedure call to the default, if Defaults are to
	-- be included. Otherwise, set it to NULL.
	IF @IncludeDefaults = 1
		SET @DefaultStoredProcCall = 'stp_BasicIssueInfo @IssueID'
	ELSE
		SET @DefaultStoredProcCall = NULL
	
	
	-- Create a record for the new document.
	INSERT INTO Documents.Documents (DocumentName)
								VALUES (@DocumentName)
										
	SET @DocumentID = SCOPE_IDENTITY() 
	
	
	-- Create a record for the Main document section for the new document.
	INSERT INTO Documents.DocumentSections (DocumentID,
											DocumentSectionName,
											DocumentSectionCode,
											SectionStoredProcedure,
											DocumentPath)
									VALUES (@DocumentID,
											'Main',
											'Main',
											@DefaultStoredProcCall,
											@DocumentPath)

	SET @DocumentSectionID = SCOPE_IDENTITY() 


	---- Create a record for the template for the new Main section.
	--CREATE TABLE #TemplateInfo (TemplateID int)
	
	--INSERT INTO #TemplateInfo (TemplateID)
	--EXEC stp_Document_SaveTemplateInfo -1, 'Main', @DocumentSectionID, 1, NULL, 'Text'
	
	
	-- If Defaults are to be included, create records for all the default
	-- fields to be associated with the section.
	IF @IncludeDefaults = 1
	BEGIN
		INSERT INTO Documents.MergeFields (DocumentSectionID, FieldName, FieldCode)
		SELECT 
			@DocumentSectionID,
			DescriptiveName, 
			REPLACE(DescriptiveName, ' ', '')
		FROM Documents.DatabaseFields
		WHERE DefaultMergeCode = 1
	
	END
	
	
	SELECT @DocumentSectionID AS DocumentSectionID
END
*/