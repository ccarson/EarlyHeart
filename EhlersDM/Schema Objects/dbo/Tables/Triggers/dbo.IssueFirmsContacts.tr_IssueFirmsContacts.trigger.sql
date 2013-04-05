CREATE TRIGGER tr_IssueFirmsContacts ON dbo.IssueFirmsContacts
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_IssueFirmsContacts
     Author:    Chris Carson
    Purpose:    Synchronizes dbo.IssueFirmsContacts data back to edata.Issues ( specifically Bond Attorney )


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         ###DATE###          Issues Conversion Bug #40 ( FA Firm not appearing )

    
************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT ON ;

    IF  NOT EXISTS ( SELECT 1 FROM inserted )
            AND
        NOT EXISTS ( SELECT 1 FROM deleted )
        RETURN ;

    DECLARE @fromConversion     AS VARBINARY(128)   = CAST( 'fromConversion' AS VARBINARY(128) ) ;

    DECLARE @codeBlockDesc01    AS SYSNAME          = ' do not process when trigger is invoked by conversion package'
          , @codeBlockDesc02    AS SYSNAME          = ' build temp storage with data from trigger tables'
          , @codeBlockDesc03    AS SYSNAME          = ' zero out temp storage where category does not exist in converted system'
          , @codeBlockDesc04    AS SYSNAME          = ' MERGE temp storage into edata.IssueProfSvcs ON INSERTs and UPDATEs'
          , @codeBlockDesc05    AS SYSNAME          = ' UPDATE edata.IssueProfSvcs FROM temp storage on DELETEs'
          , @codeBlockDesc06    AS SYSNAME          = ' UPDATE edata.Issues with FA Firm Data'
          , @codeBlockDesc07    AS SYSNAME          = ' UPDATE edata.Issues with DisseminationAgent Data' ;
    
    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @errorTypeID        AS INT
          , @errorSeverity      AS INT
          , @errorState         AS INT
          , @errorNumber        AS INT
          , @errorLine          AS INT
          , @errorProcedure     AS SYSNAME
          , @errorMessage       AS VARCHAR (MAX)    = NULL
          , @errorData          AS VARCHAR (MAX)    = NULL ;
          

/**/SELECT  @codeBlockNum  = 1
/**/      , @codeBlockDesc = @codeBlockDesc01 ; -- do not process when trigger is invoked by conversion package

    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;


/**/SELECT  @codeBlockNum  = 2
/**/      , @codeBlockDesc = @codeBlockDesc02 ; -- stop processing unless there are Bond Attorney changes
    
    IF  NOT EXISTS ( 
        SELECT  1 
          FROM  inserted                AS ins
    INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ins.ContactJobFunctionsID
    INNER JOIN  dbo.JobFunction         AS jf  ON jf.JobFunctionID          = cjf.JobFunctionID
         WHERE  jf.Value = 'Bond Attorney' ) 
         
    AND NOT EXISTS ( 
        SELECT  1 
          FROM  deleted                 AS del
    INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = del.ContactJobFunctionsID
    INNER JOIN  dbo.JobFunction         AS jf  ON jf.JobFunctionID          = cjf.JobFunctionID
         WHERE  jf.Value = 'Bond Attorney' ) 
        RETURN ; 
        

/**/SELECT  @codeBlockNum  = 3
/**/      , @codeBlockDesc = @codeBlockDesc03 ; -- apply updates to edata.Issue ( happens on INSERT and UPDATE )
      
      WITH  bondAttorneys AS ( 
            SELECT  IssueID, Attorney 
              FROM  Conversion.tvf_BondAttorney( 'Converted' ) AS tvf 
        INNER JOIN  inserted                                   AS ins
                ON  ins.IssueFirmsID = tvf.IssueFirmsID AND ins.ContactJobFunctionsID = tvf.ContactJobFunctionsID )

    UPDATE  edata.Issues 
       SET  Attorney = bat.Attorney
      FROM  edata.Issues    AS iss
INNER JOIN  bondAttorneys   AS bat ON bat.IssueID = iss.IssueID ; 


/**/SELECT  @codeBlockNum  = 4
/**/      , @codeBlockDesc = @codeBlockDesc04 ; -- set edata.Issues.Attorney to NULL on DELETE
    
      WITH  bondAttorneyIssues AS ( 
            SELECT  isf.IssueID 
              FROM  deleted                 AS del 
        INNER JOIN  dbo.IssueFirms          AS isf ON isf.IssueFirmsID          = del.IssueFirmsID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = del.ContactJobFunctionsID
        INNER JOIN  dbo.JobFunction         AS jf  ON jf.JobFunctionID          = cjf.JobFunctionID
             WHERE  jf.Value = 'Bond Attorney' 
               AND  NOT EXISTS ( SELECT 1 FROM inserted ) )
               
    UPDATE  edata.Issues 
       SET  Attorney = NULL
      FROM  edata.Issues        AS iss
INNER JOIN  bondAttorneyIssues  AS bat ON bat.IssueID = iss.IssueID ; 


END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION ;
    EXECUTE dbo.processEhlersError ;
END CATCH
END