CREATE PROCEDURE Conversion.processIssueARRA
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processIssueARRA
     Author:  Chris Carson
    Purpose:  converts legacy Issues ARRA data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Validate that dbo.ARRABond is empty
    2)  SELECT initial control counts
    3)  INSERT legacy data into dbo.ARRABond
    4)  SELECT final control counts
    5)  Validate control totals
    6)  Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY
    SET NOCOUNT     ON ;
    SET XACT_ABORT  ON ;

    DECLARE @localTransaction       AS BIT ;

    IF  @@TRANCOUNT = 0
    BEGIN
        SET @localTransaction = 1 ;
        BEGIN TRANSACTION localTransaction ;
    END

    DECLARE @controlTotalsError     AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;

    DECLARE @processStartTime       AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime         AS VARCHAR (30)     = NULL
          , @processElapsedTime     AS INT              = 0 ;

    DECLARE @codeBlockNum           AS INT
          , @codeBlockDesc          AS SYSNAME
          , @codeBlockDesc01        AS SYSNAME = 'SET CONTEXT_INFO to prevent conversion from firing triggers'
          , @codeBlockDesc02        AS SYSNAME = 'Validate that dbo.ARRABond is empty'
          , @codeBlockDesc03        AS SYSNAME = 'INSERT legacy data into dbo.ARRABond'
          , @codeBlockDesc04        AS SYSNAME = 'INSERT BTSC 8038-CP Filing Agent records
          '
          , @codeBlockDesc05        AS SYSNAME = 'Validate control totals'
          , @codeBlockDesc06        AS SYSNAME = 'Print control totals' ;



    DECLARE @convertedActual        AS INT = 0
          , @convertedCount         AS INT = 0
          , @droppedCount           AS INT = 0
          , @legacyCount            AS INT = 0
          , @newCount               AS INT = 0
          , @recordINSERTs          AS INT = 0
          , @total                  AS INT = 0 ;

    DECLARE @mergeResults           AS TABLE ( Action           NVARCHAR (10)
                                             , ClientID         INT
                                             , ClientServiceID  INT
                                             , Active           BIT ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; -- SELECT initial control counts
    SELECT  @legacyCount     = COUNT(*)
      FROM  edata.issues WHERE ARRA IN ( 'B', 'Q', 'R' ) ;
    SELECT  @convertedCount  = COUNT(*) FROM dbo.ARRABond ;
    SELECT  @convertedActual = @convertedCount ;
    
    

/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; -- Validate that dbo.ARRABond is empty
    IF  @convertedCount > 0 
        RAISERROR( 'processIssueARRA cannot execute while there is data in the dbo.ARRABond table', 16, 1 ) ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; -- INSERT legacy data into dbo.ARRABond
      WITH  ARRAType AS ( 
            SELECT * FROM dbo.ARRAType WHERE LegacyValue IN ( 'B', 'Q', 'R' ) ) , 
            
            issues AS ( 
            SELECT  IssueID, ARRA, ARRATo, ARRANotes, ChangeDate
                  , ModifiedUser = ISNULL( NULLIF( LEFT( ChangeBy, 7 ), 'process' ), 'processIssueARRA' )
              FROM  edata.Issues WHERE ARRA IN ( SELECT LegacyValue FROM ARRAType ) ) 
              
    INSERT  dbo.ARRABond ( ARRATypeID, IssueID, CreditRecipient, ReimbursementPercent, ModifiedDate, ModifiedUser ) 
    SELECT  ara.ARRATypeID
          , iss.IssueID
          , CreditRecipient = CASE iss.ARRATo WHEN 0 THEN 'Investor' ELSE 'Issuer' END 
          , ReimbursementPercent = 0
          , ModifiedDate = iss.ChangeDate
          , ModifiedUser = iss.ModifiedUser 
      FROM  issues      AS iss
INNER JOIN  ARRAType    AS ara  ON ara.LegacyValue = iss.ARRA ;
    SELECT  @recordINSERTs = @@ROWCOUNT ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; -- INSERT BTSC 8038-CP Filing Agent records
      WITH  ARRAType AS ( 
            SELECT * FROM dbo.ARRAType WHERE LegacyValue IN ( 'B', 'Q', 'R' ) ) , 
            
            issues AS ( 
            SELECT  IssueID
                  , ChangeDate
                  , ModifiedUser = ISNULL( NULLIF( LEFT( ChangeBy, 7 ), 'process' ), 'processIssueARRA' )
              FROM  edata.Issues 
             WHERE  ARRA IN ( SELECT LegacyValue FROM ARRAType ) AND ARRAbyBTSC = 1 ) , 
             
            btsc AS ( 
            SELECT  FirmCategoriesID 
              FROM  dbo.FirmCategories
             WHERE  FirmID IN ( SELECT FirmID FROM dbo.Firm WHERE FirmName = 'Bond Trust Services Corporation' )
               AND  FirmCategoryID IN ( SELECT FirmCategoryID FROM dbo.FirmCategory WHERE Value = '8038-CP Filing Agent' ) )
               
    INSERT  dbo.IssueFirms ( IssueID, FirmCategoriesID, Ordinal, ModifiedDate, ModifiedUser )
    SELECT  IssueID, FirmCategoriesID, 1, ChangeDate, ModifiedUser
      FROM  btsc CROSS JOIN issues ; 
      
              
    
/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; -- SELECT final control counts
    SELECT  @convertedActual    = COUNT(*) FROM dbo.ARRABond ;



/**/SELECT  @codeBlockNum = 05, @codeBlockDesc = @codeBlockDesc05 ; -- Validate control totals
    IF  @convertedActual <> @legacyCount
        RAISERROR( @controlTotalsError, 16, 1, 'Converted ARRA Bonds', @convertedActual, 'Legacy ARRA Bonds', @legacyCount ) ;

    IF  @convertedActual <> @recordINSERTs
        RAISERROR( @controlTotalsError, 16, 1, 'INSERTed records', @recordINSERTs, 'Legacy Services', @convertedActual ) ;



endOfProc:
/**/SELECT  @codeBlockNum = 06, @codeBlockDesc = @codeBlockDesc06 ; -- Print control totals
    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processIssueARRA CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'Legacy ARRA Bonds                   = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Total records on dbo.ARRABond       = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processIssueARRA START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processIssueARRA   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '          Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;


    IF  @localTransaction = 1 AND XACT_STATE() = 1
        COMMIT TRANSACTION localTransaction ;

    RETURN 0 ;

END TRY
BEGIN CATCH

    IF  @@TRANCOUNT > 0
        ROLLBACK TRANSACTION ;

    EXECUTE dbo.processEhlersError ;

--    DECLARE @errorTypeID            AS INT              = 1
--          , @errorSeverity          AS INT              = ERROR_SEVERITY()
--          , @errorState             AS INT              = ERROR_STATE()
--          , @errorNumber            AS INT              = ERROR_NUMBER()
--          , @errorLine              AS INT              = ERROR_LINE()
--          , @errorProcedure         AS SYSNAME          = ERROR_PROCEDURE()
--          , @errorMessage           AS VARCHAR (MAX)
--          , @formattedErrorMessage  AS VARCHAR (MAX)    = NULL
--          , @errorData              AS VARCHAR (MAX)    = NULL
--          , @errorDataTemp          AS VARCHAR (MAX)    = NULL ;
--
--    IF  @@TRANCOUNT > 0 ROLLBACK TRANSACTION ;
--
--    IF  @errorMessage IS NULL
--    BEGIN
--        SELECT  @errorMessage = ERROR_MESSAGE() ;
--
--        SELECT  @errorDataTemp = '<b>Control Totals</b></br></br>'
--              + '<table border="1">'
--              + '<tr><th>Description</th><th>Count</th></tr>'
--              + '<tr><td>@legacyCount</td><td>'     + STR( @legacyCount, 8 )        + '</td></tr>'
--              + '<tr><td>@convertedCount</td><td>'  + STR( @convertedCount, 8 )     + '</td></tr>'
--              + '<tr><td>@newCount</td><td>'        + STR( @newCount, 8 )           + '</td></tr>'
--              + '<tr><td>@droppedCount</td><td>'    + STR( @droppedCount, 8 )       + '</td></tr>'
--              + '<tr><td>@convertedActual</td><td>' + STR( @convertedActual, 8 )    + '</td></tr>'
--              + '</table></br></br>'
--         WHERE  @errorMessage LIKE '%Control Total Failure%' ;
--        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
--         WHERE  @errorDataTemp IS NOT NULL ;
--
--
--          WITH  inserts AS (
--                SELECT  ClientID, ServiceCode, ClientServiceID, Active = 1 FROM Conversion.vw_LegacyClientServices
--                    EXCEPT
--                SELECT  ClientID, ServiceCode, ClientServiceID, Active = 1 FROM Conversion.vw_ConvertedClientServices ) ,
--
--                changedData AS (
--                SELECT  ins.ClientID, ins.ServiceCode, ins.ClientServiceID, ins.Active
--                      , ModifiedDate = cli.ChangeDate
--                      , ModifiedUser = ISNULL( NULLIF( cli.ChangeBy, 'processClients' ), 'processClientSvcs' )
--                  FROM  inserts                     AS ins
--            INNER JOIN  Conversion.vw_LegacyClients AS cli ON cli.ClientID = ins.ClientID )
--
--        SELECT  @errorDataTemp = '<b>Records to be inserted</b></br></br>'
--              + '<table border="1">'
--              + '<tr><th>ClientID</th><th>ServiceCode</th><th>Active</th><th>ClientServiceID</th>'
--              + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
--              + CAST ( ( SELECT  td = ClientID          , ''
--                               , td = ServiceCode       , ''
--                               , td = Active            , ''
--                               , td = ClientServiceID   , ''
--                               , td = ModifiedDate      , ''
--                               , td = ModifiedUser      , ''
--                           FROM  changedData
--                          ORDER  BY 1, 7
--                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
--              + '</table></br></br>';
--        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
--         WHERE  @errorDataTemp IS NOT NULL ;
--
--
--          WITH  deletes AS (
--                SELECT  ClientID, ServiceCode, ClientServiceID, Active = 0 FROM Conversion.vw_ConvertedClientServices
--                    EXCEPT
--                SELECT  ClientID, ServiceCode, ClientServiceID, Active = 0 FROM Conversion.vw_LegacyClientServices ) ,
--
--                changedData AS (
--                SELECT  del.ClientID, del.ServiceCode, del.ClientServiceID, del.Active
--                      , ModifiedDate = cli.ChangeDate
--                      , ModifiedUser = ISNULL( NULLIF( cli.ChangeBy, 'processClients' ), 'processClientSvcs' )
--                  FROM  deletes                     AS del
--            INNER JOIN  Conversion.vw_LegacyClients AS cli ON cli.ClientID = del.ClientID )
--
--        SELECT  @errorDataTemp = '<b>Records to be inserted</b></br></br>'
--              + '<table border="1">'
--              + '<tr><th>ClientID</th><th>ServiceCode</th><th>Active</th><th>ClientServiceID</th>'
--              + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
--              + CAST ( ( SELECT  td = ClientID          , ''
--                               , td = ServiceCode       , ''
--                               , td = Active            , ''
--                               , td = ClientServiceID   , ''
--                               , td = ModifiedDate      , ''
--                               , td = ModifiedUser      , ''
--                           FROM  changedData
--                          ORDER  BY 1, 7
--                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
--              + '</table></br></br>';
--        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
--         WHERE  @errorDataTemp IS NOT NULL ;
--
--
--        EXECUTE dbo.processEhlersError  @errorTypeID
--                                      , @codeBlockNum
--                                      , @codeBlockDesc
--                                      , @errorNumber
--                                      , @errorSeverity
--                                      , @errorState
--                                      , @errorProcedure
--                                      , @errorLine
--                                      , @errorMessage
--                                      , @errorData ;
--
--        SELECT  @formattedErrorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
--                                       + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: %s ' ;
--
--        RAISERROR( @formattedErrorMessage, @errorSeverity, @codeBlockNum
--                 , @codeBlockNum
--                 , @codeBlockDesc
--                 , @errorNumber
--                 , @errorSeverity
--                 , @errorState
--                 , @errorProcedure
--                 , @errorLine
--                 , @errorMessage ) ;
--
--    END
--        ELSE
--    BEGIN
--        SELECT  @errorMessage   = ERROR_MESSAGE()
--              , @errorSeverity  = ERROR_SEVERITY()
--              , @errorState     = ERROR_STATE()
--
--        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
--
--    END
--
--    RETURN 16 ;

END CATCH
END
