/*
CREATE PROC [dbo].[stp_EstablishDirectAssociation]
	@DocumentSectionID INT,
	@FieldName varchar(50),
	@FieldCode varchar(50)
AS

IF NOT EXISTS(SELECT * FROM documents.MergeFields WHERE DocumentSectionID = @DocumentSectionID AND FieldCode = @FieldCode) 
BEGIN
	INSERT INTO documents.MergeFields(DocumentSectionID,FieldName,FieldCode)
	VALUES(@DocumentSectionID, @FieldName, @FieldCode)
END	
*/