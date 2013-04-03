CREATE PROCEDURE dbo.deleteIssue ( @IssueID     AS VARCHAR (30) )

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
    2)  delete dbo.PurposeSource
    3)  delete dbo.PurposeUse
    4)  delete dbo.PaymentTypeAssessment
    4)  delete dbo.PaymentTypeEqualSingle
    4)  delete dbo.PaymentTypeVaryingAmount
    4)  delete dbo.PaymentTypeVarying
    5)  delete dbo.PurposeMaturityRefunding
    6)  delete dbo.Refunding
    7)  delete dbo.PurposeMaturityInterest
    8)  delete dbo.PurposeMaturity
    9)  delete dbo.Purpose


    Notes:

************************************************************************************************************************************
*/
BEGIN

BEGIN TRY

    SET NOCOUNT ON ;


    DECLARE @codeBlockDesc01    AS SYSNAME          = 'transaction processing'
          , @codeBlockDesc02    AS SYSNAME          = 'DELETE dbo.ClientReportIssues'
          , @codeBlockDesc03    AS SYSNAME          = 'DELETE dbo.IssueCall'
          , @codeBlockDesc04    AS SYSNAME          = 'DELETE dbo.IssueClientsContacts'
          , @codeBlockDesc05    AS SYSNAME          = 'DELETE dbo.IssueEhlersEmployees'
          , @codeBlockDesc06    AS SYSNAME          = 'DELETE dbo.Arbitrage'
          , @codeBlockDesc07    AS SYSNAME          = 'DELETE dbo.IssueElections'
          , @codeBlockDesc08    AS SYSNAME          = 'DELETE dbo.IssueFee'
          , @codeBlockDesc09    AS SYSNAME          = 'DELETE dbo.IssueFeeCounty'
          , @codeBlockDesc10    AS SYSNAME          = 'DELETE dbo.IssueFirms'
          , @codeBlockDesc11    AS SYSNAME          = 'DELETE dbo.IssueJointClient'
          , @codeBlockDesc12    AS SYSNAME          = 'DELETE dbo.IssueMaturity'
          , @codeBlockDesc13    AS SYSNAME          = 'DELETE dbo.ArbitrageService'
          , @codeBlockDesc14    AS SYSNAME          = 'DELETE dbo.IssueMeeting'
          , @codeBlockDesc15    AS SYSNAME          = 'DELETE dbo.IssuePostBond'
          , @codeBlockDesc16    AS SYSNAME          = 'DELETE dbo.ARRABond'
          , @codeBlockDesc17    AS SYSNAME          = 'DELETE dbo.IssueRating'
          , @codeBlockDesc18    AS SYSNAME          = 'DELETE dbo.IssueStatutoryAuthority'
          , @codeBlockDesc19    AS SYSNAME          = 'DELETE dbo.BidMaturity for related dbo.Bidder records'
          , @codeBlockDesc20    AS SYSNAME          = 'DELETE dbo.Bidder'
          , @codeBlockDesc21    AS SYSNAME          = 'DELETE dbo.BiddingParameter'
          , @codeBlockDesc22    AS SYSNAME          = 'DELETE dbo.ClientAuditCafrIssues'
          , @codeBlockDesc23    AS SYSNAME          = 'DELETE dbo.PotentialRefunding'
          , @codeBlockDesc24    AS SYSNAME          = 'DELETE dbo.Project'
          , @codeBlockDesc25    AS SYSNAME          = 'DELETE dbo.ClientMaterialEventIssues'
          , @codeBlockDesc26    AS SYSNAME          = 'INSERT purposes into temp storage'
          , @codeBlockDesc27    AS SYSNAME          = 'for each Purpose, EXECUTE dbo.deletePurpose'
          , @codeBlockDesc28    AS SYSNAME          = 'DELETE dbo.Issue'
          , @codeBlockDesc29    AS SYSNAME          = 'Commit transaction if required' ;

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

    DECLARE @purposes           AS TABLE ( PurposeID INT ) ;

    DECLARE @purposeID          AS INT ;



/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- transaction processing

    IF  ( @outerTransaction = 1 )
        SAVE TRANSACTION    @rollbackPoint ;
    ELSE
        BEGIN TRANSACTION   @rollbackPoint ;



/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- DELETE dbo.ClientReportIssues

    DELETE dbo.ClientReportIssues WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.ClientReportIssues', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- DELETE dbo.IssueCall

    DELETE dbo.IssueCall WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueCall', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- DELETE dbo.IssueClientsContacts

    DELETE dbo.IssueClientsContacts WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueClientsContacts', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- DELETE dbo.IssueEhlersEmployees

    DELETE dbo.IssueEhlersEmployees WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueEhlersEmployees', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; -- DELETE dbo.Arbitrage

    DELETE dbo.Arbitrage WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.Arbitrage', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ; -- DELETE dbo.IssueElections

    DELETE dbo.IssueElections WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueElections', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; -- DELETE dbo.IssueFee

    DELETE dbo.IssueFee WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueFee', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; -- DELETE dbo.IssueFeeCounty

    DELETE dbo.IssueFeeCounty WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueFeeCounty', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; -- DELETE dbo.IssueFirms

    DELETE dbo.IssueFirms WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueFirms', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 11
/**/      , @codeBlockDesc  = @codeBlockDesc11 ; -- DELETE dbo.IssueJointClient

    DELETE dbo.IssueJointClient WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueJointClient', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 12
/**/      , @codeBlockDesc  = @codeBlockDesc12 ; -- DELETE dbo.IssueMaturity

    DELETE dbo.IssueMaturity WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueMaturity', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 13
/**/      , @codeBlockDesc  = @codeBlockDesc13 ; -- DELETE dbo.ArbitrageService

    DELETE dbo.ArbitrageService WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.ArbitrageService', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 14
/**/      , @codeBlockDesc  = @codeBlockDesc14 ; -- DELETE dbo.IssueMeeting

    DELETE dbo.IssueMeeting WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueMeeting', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 15
/**/      , @codeBlockDesc  = @codeBlockDesc15 ; -- DELETE dbo.IssuePostBond

    DELETE dbo.IssuePostBond WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssuePostBond', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 16
/**/      , @codeBlockDesc  = @codeBlockDesc16 ; -- DELETE dbo.ARRABond

    DELETE dbo.ARRABond WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.ARRABond', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 17
/**/      , @codeBlockDesc  = @codeBlockDesc17 ; -- DELETE dbo.IssueRating

    DELETE dbo.IssueRating WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueRating', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 18
/**/      , @codeBlockDesc  = @codeBlockDesc18 ; -- DELETE dbo.IssueStatutoryAuthority

    DELETE dbo.IssueStatutoryAuthority WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.IssueStatutoryAuthority', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 19
/**/      , @codeBlockDesc  = @codeBlockDesc19 ; -- DELETE dbo.BidMaturity for related dbo.Bidder records

    DELETE dbo.BidMaturity
      FROM dbo.BidMaturity AS bdm
     WHERE EXISTS ( SELECT 1 FROM dbo.Bidder AS bid
                     WHERE bid.BidderID = bdm.BidderID AND bid.IssueID = @IssueID ) ;
    RAISERROR ('%d records deleted from dbo.BidMaturity', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 20
/**/      , @codeBlockDesc  = @codeBlockDesc20 ; -- DELETE dbo.Bidder

    DELETE dbo.Bidder WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.Bidder', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 21
/**/      , @codeBlockDesc  = @codeBlockDesc21 ; -- DELETE dbo.BiddingParameter

    DELETE dbo.BiddingParameter WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.BiddingParameter', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 22
/**/      , @codeBlockDesc  = @codeBlockDesc22 ; -- DELETE dbo.ClientAuditCafrIssues

    DELETE dbo.ClientAuditCafrIssues WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.ClientAuditCafrIssues', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 23
/**/      , @codeBlockDesc  = @codeBlockDesc23 ; -- DELETE dbo.PotentialRefunding

    DELETE dbo.PotentialRefunding WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.PotentialRefunding', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 24
/**/      , @codeBlockDesc  = @codeBlockDesc24 ; -- DELETE dbo.Project

    DELETE dbo.Project WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.Project', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 25
/**/      , @codeBlockDesc  = @codeBlockDesc25 ; -- DELETE dbo.ClientMaterialEventIssues

    DELETE dbo.ClientMaterialEventIssues WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.ClientMaterialEventIssues', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 26
/**/      , @codeBlockDesc  = @codeBlockDesc26 ; -- INSERT purposes into temp storage

    INSERT @purposes
    SELECT PurposeID FROM dbo.Purpose WHERE IssueID = @IssueID ; 
    RAISERROR ('%d Purposes to be deleted for IssueID %d', 0, 0, @@ROWCOUNT, @IssueID) ;


/**/SELECT  @codeBlockNum   = 27
/**/      , @codeBlockDesc  = @codeBlockDesc27 ; -- for each Purpose, EXECUTE dbo.deletePurpose

    WHILE EXISTS ( SELECT 1 FROM @purposes )
    BEGIN

        SELECT TOP 1 @purposeID = PurposeID FROM @purposes ;

        RAISERROR('deleting PurposeID %d', 0,0,@purposeID) ;
        EXECUTE dbo.deletePurpose @purposeID = @purposeID, @KeepOrPurge = 'PurgeData' ;

        DELETE @purposes WHERE PurposeID = @PurposeID ;

    END


/**/SELECT  @codeBlockNum   = 28
/**/      , @codeBlockDesc  = @codeBlockDesc28 ; -- DELETE dbo.Issue

    DELETE dbo.Issue WHERE IssueID = @IssueID ;
    RAISERROR ('%d records deleted from dbo.Issue', 0, 0, @@ROWCOUNT) ;


/**/SELECT  @codeBlockNum   = 29
/**/      , @codeBlockDesc  = @codeBlockDesc29 ; -- Commit transaction if required

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