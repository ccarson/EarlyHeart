CREATE PROCEDURE Conversion.processBondAttorney
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processBondAttorney
     Author:    Chris Carson
    Purpose:    converts legacy Bond Counsel data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:


    Notes:
    This is similar to processIssueFirms, but there is additional processing for the BondCounsel because of the Contact data

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @processName            AS VARCHAR (100)    = 'processBondAttorney'
          , @errorMessage           AS VARCHAR (MAX)    = NULL
          , @errorQuery             AS VARCHAR (MAX)    = NULL
          , @processBondAttorney    AS VARBINARY (128)  = CAST( 'processBondAttorney' AS VARBINARY(128) )
          , @processStartTime       AS DATETIME         = GETDATE()
          , @processEndTime         AS DATETIME         = NULL
          , @processElapsedTime     AS INT              = 0 ;

    DECLARE @changesCount           AS INT = 0
          , @convertedActual        AS INT = 0
          , @convertedChecksum      AS INT = 0
          , @convertedCount         AS INT = 0
          , @droppedCount           AS INT = 0
          , @legacyChecksum         AS INT = 0
          , @legacyCount            AS INT = 0
          , @newCount               AS INT = 0
          , @recordDELETEs          AS INT = 0
          , @recordINSERTs          AS INT = 0 ;

    DECLARE @changedBondAttorney    AS TABLE ( IssueFirmsID             INT
                                             , ContactJobFunctionsID    INT 
                                             , ModifiedDate             DATETIME  
                                             , ModifiedUser             VARCHAR (20) ) ; 


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
BEGIN TRY
    SET CONTEXT_INFO @processBondAttorney ;


--  2)  SELECT initial control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.tvf_BondAttorney( 'Legacy' ) ; 
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.tvf_BondAttorney( 'Converted' ) ; 
    SELECT  @convertedActual    = @convertedCount ;


--  3)  Check for changed BondAttorney data, exit if there are no changes
    SELECT  @legacyChecksum    = CHECKSUM_AGG(CHECKSUM( IssueFirmsID, ContactJobFunctionsID )) 
      FROM  Conversion.tvf_BondAttorney( 'Legacy' ) ; 
    SELECT  @convertedChecksum = CHECKSUM_AGG(CHECKSUM( IssueFirmsID, ContactJobFunctionsID )) 
      FROM  Conversion.tvf_BondAttorney( 'Converted' ) ; 

    IF  ( @legacyChecksum = @convertedChecksum )
        GOTO endOfProc ;


--  4)  INSERT new BondAttorney records into @changedBondAttorney
    INSERT  @changedBondAttorney ( IssueFirmsID, ContactJobFunctionsID, ModifiedDate, ModifiedUser )
    SELECT  IssueFirmsID, ContactJobFunctionsID, ModifiedDate, ModifiedUser
      FROM  Conversion.tvf_BondAttorney( 'Legacy' ) AS l 
     WHERE  NOT EXISTS ( SELECT 1 FROM Conversion.tvf_BondAttorney( 'Converted' ) AS c 
                          WHERE c.IssueFirmsID = l.IssueFirmsID AND c.ContactJobFunctionsID = l.ContactJobFunctionsID ) ; 
    SELECT  @newCount = @@ROWCOUNT ;

--  5)  INSERT dropped BondAttorney records into @changedBondAttorney
    INSERT  @changedBondAttorney ( IssueFirmsID, ContactJobFunctionsID )
    SELECT  IssueFirmsID, ContactJobFunctionsID FROM Conversion.tvf_BondAttorney( 'Converted' ) 
        EXCEPT
    SELECT  IssueFirmsID, ContactJobFunctionsID FROM Conversion.tvf_BondAttorney( 'Legacy' ) ;
    SELECT  @droppedCount = @@ROWCOUNT ;


--  6)  DELETE any existing IssueFirmsContacts records affected by changes
    DELETE  dbo.IssueFirmsContacts
      FROM  dbo.IssueFirmsContacts AS ifc
     WHERE  EXISTS ( SELECT 1 FROM @changedBondAttorney AS cba
                      WHERE cba.IssueFirmsID = ifc.IssueFirmsID 
                        AND cba.ContactJobFunctionsID = ifc.ContactJobFunctionsID        
                        AND cba.ModifiedDate IS NULL ) ;
    SELECT  @recordDELETEs = @@ROWCOUNT ;

--  7)  INSERT new IssueFirmsContacts records from @changedBondAttorney
    INSERT  dbo.IssueFirmsContacts ( IssueFirmsID, ContactJobFunctionsID, Ordinal, ModifiedDate, ModifiedUser )
    SELECT  IssueFirmsID, ContactJobFunctionsID, 1, ModifiedDate, ModifiedUser
      FROM  @changedBondAttorney
     WHERE  ModifiedDate IS NOT NULL
    SELECT  @recordINSERTs = @@ROWCOUNT ;


--  8)  SELECT control counts and validate
    SELECT  @convertedActual = COUNT(*) FROM Conversion.tvf_BondAttorney( 'Converted' ) ; 
    SELECT  @changesCount    = @newCount + @droppedCount ;

    IF  ( @convertedActual <> ( @convertedCount + @newCount - @droppedCount ) )
        OR
        ( @convertedActual <> @legacyCount )
        OR
        ( ( @recordINSERTs + @recordDELETEs ) <> ( @newCount + @droppedCount ) )
    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@convertedCount  = ' + STR( @convertedCount, 8 ) ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordDELETEs   = ' + STR( @recordDELETEs, 8 ) ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@legacyCount     = ' + STR( @legacyCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordDELETEs   = ' + STR( @recordDELETEs, 8 ) ;
        PRINT '@newCount        = ' + STR( @newCount, 8 ) ;
        PRINT '@droppedCount    = ' + STR( @droppedCount, 8 ) ;
        PRINT '' ;
    END


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH


endOfProc:

--  9)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 10)  Print control totals
    SELECT  @processEndTime     = GETDATE()
          , @processElapsedTime = DATEDIFF( ms, @processStartTime, @processEndTime ) ;

    PRINT   'Conversion.processBondAttorney CONTROL TOTALS ' ;
    PRINT   'Bond Attorneys on legacy system         = ' + STR( @legacyCount, 8 ) ;
    PRINT   '' ;
    PRINT   'Existing records on converted system    = ' + STR( @convertedCount, 8 ) ;
    PRINT   '     + new records                      = ' + STR( @newCount, 8 ) ;
    PRINT   '     - dropped records                  = ' + STR( @droppedCount, 8 ) ;
    PRINT   '                                           ======= ' ;
    PRINT   'Total converted Bond Attorneys          = ' + STR( @convertedActual, 8 ) ;
    PRINT   '' ;
    PRINT   '' ;
    PRINT   'Database Change Details ' ;
    PRINT   '' ;
    PRINT   '     INSERTs to dbo.IssueFirmsContacts  = ' + STR( @recordINSERTs, 8 ) ;
    PRINT   '     DELETEs on dbo.IssueFirmsContacts  = ' + STR( @recordDELETEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     TOTAL changes                      = ' + STR( @changesCount, 8 ) ;
    PRINT   '' ;
    PRINT   'processIssues START : ' + CONVERT( VARCHAR (30), @processStartTime, 121 ) ;
    PRINT   'processIssues   END : ' + CONVERT( VARCHAR (30), @processEndTime, 121 ) ;
    PRINT   '' ;
    PRINT   '       Elapsed Time : ' + CAST ( @processElapsedTime AS VARCHAR (20) ) + 'ms' ;


END
GO

