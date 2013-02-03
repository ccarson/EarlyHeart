/*
CREATE PROCEDURE [dbo].[stp_DocumentMergeFieldList]
	@DocumentSectionID	varchar(15),
	@CurrSectionOnly	bit = 0
AS
BEGIN
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/10/2010
-- Description: Get the list of merge fields  
--				defined for a given document.
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @DocSectionName		varchar(251)
	DECLARE @MainDocSectionID	int
	
	SELECT
		@DocSectionName = doc.DocumentName + CHAR(13) + CHAR(10) + thisSec.DocumentSectionName,
		@MainDocSectionID = mainSec.DocumentSectionID
	FROM
		Documents.DocumentSections thisSec
	JOIN
		Documents.Documents doc ON thisSec.DocumentID = doc.DocumentID
	JOIN 
		Documents.DocumentSections mainSec ON thisSec.DocumentID = mainSec.DocumentID
											AND mainSec.DocumentSectionName = 'Main'
	WHERE
		thisSec.DocumentSectionID = CONVERT(int, @DocumentSectionID)

	SELECT 
		FieldName,
		FieldCode,
		@DocSectionName AS DocumentSectionName,
		FieldDescription AS Comment,
		DocumentSectionID, 
		CASE WHEN @DocumentSectionID = DocumentSectionID THEN 1 ELSE 0 END AS DirectAssociation,
		@DocumentSectionID AS CurrentDocumentSection,
		MergeFieldID 
	FROM
		Documents.MergeFields
	WHERE 
		(DocumentSectionID = CONVERT(int, @DocumentSectionID)
	OR
		(DocumentSectionID = @MainDocSectionID AND @CurrSectionOnly = 0))
		AND MergeFieldID NOT IN (--selects the MergeFieldID where DocumentSectionCode = 'Main' AND MergeFieldCode is in both Main and the current @DocumentSection
									select b.MergeFieldID 
									 from 
									(select m.MergeFieldID, m.DocumentSectionID, m.FieldCode,  s.DocumentID,s.DocumentSectionCode
									from documents.MergeFields m
									inner join documents.DocumentSections s on m.DocumentSectionID = s.DocumentSectionID 
									where s.DocumentSectionName <> 'Main'
									) a

									INNER JOIN 

									(select m.MergeFieldID, m.DocumentSectionID, m.FieldCode,  s.DocumentID,s.DocumentSectionCode
									from documents.MergeFields m
									inner join documents.DocumentSections s on m.DocumentSectionID = s.DocumentSectionID 
									where s.DocumentSectionName = 'Main'
									) b
									ON a.DocumentID = b.DocumentID AND a.FieldCode = b.FieldCode
									where a.DocumentSectionID = @DocumentSectionID)
	ORDER BY
		FieldName
END
*/