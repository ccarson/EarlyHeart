CREATE PROCEDURE dbo.deletePurpose ( @purposeID     AS VARCHAR (30)
                                   , @keepOrPurge   AS VARCHAR (30) )
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.deleteIssue
     Author:    Chris Carson
    Purpose:    drops a purpose from the Ehlers System


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created ( Issues Conversion )

    Logic Summary:



    Notes:

************************************************************************************************************************************
*/
BEGIN

BEGIN TRY

    SET NOCOUNT ON ;

    DECLARE @codeBlockDesc01    AS SYSNAME          = 'transaction processing'
          , @codeBlockDesc02    AS SYSNAME          = 'DELETE dbo.PurposeSource'
          , @codeBlockDesc03    AS SYSNAME          = 'DELETE dbo.PurposeUse'
          , @codeBlockDesc04    AS SYSNAME          = 'DELETE dbo.PaymentTypeAssessment'
          , @codeBlockDesc05    AS SYSNAME          = 'DELETE dbo.PaymentTypeEqualSingle'
          , @codeBlockDesc06    AS SYSNAME          = 'DELETE dbo.PaymentTypeVaryingAmount'
          , @codeBlockDesc07    AS SYSNAME          = 'DELETE dbo.PaymentTypeVarying'
          , @codeBlockDesc08    AS SYSNAME          = 'DELETE dbo.PurposeMaturityRefunding'
          , @codeBlockDesc09    AS SYSNAME          = 'DELETE dbo.Refunding'
          , @codeBlockDesc10    AS SYSNAME          = 'UPDATE dbo.Refunding to set RefundingPurposeID to NULL'
          , @codeBlockDesc11    AS SYSNAME          = 'DELETE dbo.PurposeMaturityInterest'
          , @codeBlockDesc12    AS SYSNAME          = 'DELETE dbo.PurposeMaturity'
          , @codeBlockDesc13    AS SYSNAME          = 'DELETE dbo.Purpose'

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

    DECLARE @outerTransaction   AS BIT              = CASE WHEN @@TRANCOUNT > 0 THEN 1 ELSE 0 END
          , @rollbackPoint      AS NCHAR(32)        = REPLACE( CAST( NEWID() AS NCHAR(36) ), N'-', N'') ;


    DECLARE @purposeIDValue     AS INT              = CAST( @purposeID      AS INT ) ;


/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- transaction processing

    IF  ( @outerTransaction = 1 )
        SAVE TRANSACTION    @rollbackPoint ;
    ELSE
        BEGIN TRANSACTION   @rollbackPoint ;


/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- DELETE dbo.PurposeSource

    DELETE  dbo.PurposeSource
     WHERE  PurposeID = @purposeIDValue ;


/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- DELETE dbo.PurposeUse

    DELETE  dbo.PurposeUse
     WHERE  PurposeID = @purposeIDValue ;


/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- DELETE dbo.PaymentTypeAssessment

    DELETE  dbo.PaymentTypeAssessment
     WHERE  PurposeID = @purposeIDValue
       AND  @KeepOrPurge = 'PurgeData' ;

/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- DELETE dbo.PaymentTypeEqualSingle

    DELETE  dbo.PaymentTypeEqualSingle
     WHERE  PurposeID = @purposeIDValue
       AND  @KeepOrPurge = 'PurgeData' ;


/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; -- DELETE dbo.PaymentTypeVaryingAmount

    DELETE  dbo.PaymentTypeVaryingAmount
      FROM  dbo.PaymentTypeVaryingAmount AS pva
     WHERE  EXISTS ( SELECT 1 FROM dbo.PaymentTypeVarying AS ptv
                      WHERE ptv.PaymentTypeVaryingID = pva.PaymentTypeVaryingID
                        AND ptv.PurposeID = @purposeIDValue )
       AND  @KeepOrPurge = 'PurgeData' ;


/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ; -- DELETE dbo.PaymentTypeVarying

    DELETE  dbo.PaymentTypeVarying
     WHERE  PurposeID = @purposeIDValue
       AND  @KeepOrPurge = 'PurgeData' ;


/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; -- DELETE dbo.PurposeMaturityRefunding

      WITH  refundPurposes AS ( 
            SELECT PurposeID = RefundedPurposeID
              FROM dbo.Refunding
             WHERE RefundingPurposeID = @PurposeIDValue
                    union
            SELECT @PurposeIDValue ) 

    DELETE  dbo.PurposeMaturityRefunding
      FROM  dbo.PurposeMaturityRefunding AS pmr
     WHERE  EXISTS ( SELECT 1 
                       FROM dbo.PurposeMaturity AS pm
                 INNER JOIN refundPurposes      AS ref ON ref.PurposeID = pm.PurposeID  
                      WHERE pm.PurposeMaturityID = pmr.PurposeMaturityID ) 


/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; -- DELETE dbo.Refunding

    DELETE  dbo.Refunding
     WHERE  RefundedPurposeID = @purposeIDValue 
                OR
            RefundingPurposeID = @purposeIDValue 



/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; -- DELETE dbo.PurposeMaturityInterest

    DELETE  dbo.PurposeMaturityInterest
      FROM  dbo.PurposeMaturityInterest AS pmi
     WHERE  EXISTS ( SELECT 1 FROM dbo.PurposeMaturity AS pma
                      WHERE pma.PurposeMaturityID = pmi.PurposeMaturityID
                        AND pma.PurposeID = @purposeIDValue ) ;


/**/SELECT  @codeBlockNum   = 12
/**/      , @codeBlockDesc  = @codeBlockDesc12 ; -- DELETE dbo.PurposeMaturity

    DELETE  dbo.PurposeMaturity
     WHERE  PurposeID = @purposeIDValue ;


/**/SELECT  @codeBlockNum   = 13
/**/      , @codeBlockDesc  = @codeBlockDesc13 ; -- DELETE dbo.Purpose

    DELETE  dbo.Purpose
     WHERE  PurposeID = @purposeIDValue
       AND  @KeepOrPurge = 'PurgeData' ;

    IF  ( @outerTransaction = 0 )
        COMMIT TRANSACTION ;

END TRY
BEGIN CATCH

    IF  ( XACT_STATE() = 1 )
        ROLLBACK TRANSACTION @rollbackPoint ;

    EXECUTE dbo.processEhlersError ;


--    SELECT  @errorTypeID    = 1
--          , @errorSeverity  = ERROR_SEVERITY()
--          , @errorState     = ERROR_STATE()
--          , @errorNumber    = ERROR_NUMBER()
--          , @errorLine      = ERROR_LINE()
--          , @errorProcedure = ISNULL( ERROR_PROCEDURE(), '-' )
--
--    IF  @errorMessage IS NULL
--    BEGIN
--        SELECT  @errorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
--                              + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + ERROR_MESSAGE() ;
--
--        RAISERROR( @errorMessage, @errorSeverity, 1
--                 , @codeBlockNum
--                 , @codeBlockDesc
--                 , @errorNumber
--                 , @errorSeverity
--                 , @errorState
--                 , @errorProcedure
--                 , @errorLine ) ;
--
--        SELECT  @errorMessage = ERROR_MESSAGE() ;
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
--    END
--        ELSE
--    BEGIN
--        SELECT  @errorSeverity  = ERROR_SEVERITY()
--              , @errorState     = ERROR_STATE()
--
--        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
--    END

END CATCH
END