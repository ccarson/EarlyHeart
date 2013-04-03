CREATE PROCEDURE dbo.deletePurpose ( @purposeID                 AS INT 
                                   , @ignoreErrors              AS BIT          = 0
                                   , @adminAuthority            AS VARCHAR(20)  = NULL ) 
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.deletePurpose
     Author:    Chris Carson
    Purpose:    drops a purpose from the Ehlers System


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created ( Issues Conversion ) 

    Logic Summary:
    1)  Validate purpose delete
    2)  delete sources for purpose
    3)  delete uses for purpose
    4)  delete other stuff for purpose
    5)  delete pm refunding for purpose
    6)  delete refunding for purpose
    7)  delete pm interest
    8)  delete pm
    9)  delete purpose


    Notes:

************************************************************************************************************************************
*/
BEGIN

BEGIN TRY

    SET NOCOUNT ON ;

--    DECLARE @codeBlockDesc01        AS VARCHAR (128)    = 'SET CONTEXT_INFO, to inhibit triggers that would ordinarily fire'
--          , @codeBlockDesc02        AS VARCHAR (128)    = 'SELECT initial control counts'
--          , @codeBlockDesc03        AS VARCHAR (128)    = 'INSERT changed recordIDs into temp storage'
--          , @codeBlockDesc04        AS VARCHAR (128)    = 'Stop processing if there are no data changes'
--          , @codeBlockDesc05        AS VARCHAR (128)    = 'INSERT new data into temp storage'
--          , @codeBlockDesc06        AS VARCHAR (128)    = 'INSERT updated data into temp storage'
--          , @codeBlockDesc07        AS VARCHAR (128)    = 'UPDATE changed data to remove invalid ObligorClientID'
--          , @codeBlockDesc08        AS VARCHAR (128)    = 'MERGE temp storage into dbo.Issues'
--          , @codeBlockDesc09        AS VARCHAR (128)    = 'SELECT final control counts'
--          , @codeBlockDesc10        AS VARCHAR (128)    = 'Control Total Validation'
--          , @codeBlockDesc11        AS VARCHAR (128)    = 'Reset CONTEXT_INFO to remove restrictions on triggers'
--          , @codeBlockDesc12        AS VARCHAR (128)    = 'Print control totals' ;
--
--
--    DECLARE @codeBlockNum           AS INT
--          , @codeBlockDesc          AS VARCHAR (128)
--          , @errorTypeID            AS INT
--          , @errorSeverity          AS INT
--          , @errorState             AS INT
--          , @errorNumber            AS INT
--          , @errorLine              AS INT
--          , @errorProcedure         AS VARCHAR (128)
--          , @errorMessage           AS VARCHAR (MAX) = NULL
--          , @errorData              AS VARCHAR (MAX) = NULL ;
--          
--    DECLARE @adminOverride          AS BIT = 0 ; 
--          
--          
--/**/SELECT  @codeBlockNum   = 1
--/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- validate override authority
--
--    IF  ( @ignoreErrors = 1 ) 
--        IF  ( @adminAuthority = 'FULL PURGE' ) 
--            SELECT  @adminOverride = 1 ; 
--        ELSE 
--            RAISERROR ( 'Cannot allow override without correct adminAuthority' 16, 1 ) ; 
--            
--        
--        
--/**/SELECT  @codeBlockNum   = 2
--/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- validate purpose delete
--
--    SELECT  @saleDate = ISNULL( SaleDate, DatedDate ) 
--      FROM  dbo.Issue AS iss
--     WHERE  EXISTS ( SELECT 1 FROM dbo.Purpose AS pur
--                      WHERE pur.IssueID = iss.IssueID ) ;
--                      
--    IF  ( @saleData < GETDATE() )
--            AND
--        ( @adminOverride = 0 ) 
--        RAISERROR ( 'Cannot purge purposes after sale date is passed' 16, 1 ) ; 
--
--        
--/**/SELECT  @codeBlockNum   = 3
--/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- delete sources for Purpose
--
--    DELETE  dbo.PurposeSource
--     WHERE  purposeID = @purposeID ; 
--     
--     
--/**/SELECT  @codeBlockNum   = 4
--/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- delete uses for Purpose
--
--    DELETE  dbo.PurposeUses
--     WHERE  purposeID = @purposeID ; 
--     
--     
--/**/SELECT  @codeBlockNum   = 2
--/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- validate purpose delete
--
--    SELECT  @saleDate = ISNULL( SaleDate, DatedDate ) 
--      FROM  dbo.Issue AS iss
--     WHERE  EXISTS ( SELECT 1 FROM dbo.Purpose AS pur
--                      WHERE pur.IssueID = iss.IssueID ) ;
--                      
--    IF  ( @saleData < GETDATE() )
--            AND
--        ( @adminOverride = 0 ) 
--        RAISERROR ( 'Cannot purge purposes after sale date is passed' 16, 1 ) ; 
--        
--        
--
--
--
--
--        SELECT  @issueSaleDate = ISNULL( iss.saleDate, iss.DatedDate ) 
--      FROM  dbo.issue AS iss
--INNER JOIN  dbo.Purpose AS pur ON pur.IssueID = iss.IssueID 
--     WHERE  pur.PurposeID = @purposeID     
--    SET CONTEXT_INFO @processIssues ;
--
--
--/**/SELECT  @codeBlockNum   = 2
--/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- SELECT initial control counts
--
--    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyIssues ;
--    SELECT  @convertedCount     = COUNT(*) FROM Conversion.vw_ConvertedIssues ;
--    SELECT  @convertedActual    = @convertedCount ;
--
--
--/**/SELECT  @codeBlockNum   = 3
--/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- INSERT changed recordIDs into temp storage
--
--    INSERT  @changedIssueIDs
--    SELECT  IssueID           = a.IssueID
--          , legacyChecksum    = a.IssueChecksum
--          , convertedChecksum = b.IssueChecksum
--      FROM  Conversion.tvf_IssueChecksum( 'Legacy' )    AS a
-- LEFT JOIN  Conversion.tvf_IssueChecksum( 'Converted' ) AS b
--        ON  a.IssueID = b.IssueID
--     WHERE  b.IssueChecksum IS NULL OR a.IssueChecksum <> b.IssueChecksum ;
--    SELECT  @changesCount = @@ROWCOUNT ;          
    
    
end try
begin catch
end catch
end