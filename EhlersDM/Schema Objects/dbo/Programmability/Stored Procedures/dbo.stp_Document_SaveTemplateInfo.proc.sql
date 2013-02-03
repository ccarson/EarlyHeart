/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/20/2010
-- Description:	Store the information about a 
--				Document Template.
-- =============================================
CREATE PROCEDURE [dbo].[stp_Document_SaveTemplateInfo]
	@TemplateID			int			= -1, 
	@TemplateName		varchar(500),
	@DocumentSectionID	int,
	@OrderWithinSection	smallint,
	@Condition			varchar(max),
	@TemplateType		varchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @TemplateID = -1
	BEGIN
		INSERT INTO Documents.Templates (TemplateName, 
										DocumentSectionID, 
										OrderWithinSection,
										Condition,
										TemplateType)
								VALUES (@TemplateName, 
										@DocumentSectionID,
										@OrderWithinSection,
										@Condition,
										@TemplateType)
										
		SET @TemplateID = SCOPE_IDENTITY() 
	END
	ELSE
	BEGIN
		UPDATE 
			Documents.Templates
		SET 
			TemplateName = @TemplateName,
			DocumentSectionID = @DocumentSectionID,
			OrderWithinSection = @OrderWithinSection,
			Condition = @Condition,
			TemplateType = @TemplateType
		WHERE  
			TemplateID = @TemplateID
	END
	
	SELECT @TemplateID AS TemplateID
END
*/