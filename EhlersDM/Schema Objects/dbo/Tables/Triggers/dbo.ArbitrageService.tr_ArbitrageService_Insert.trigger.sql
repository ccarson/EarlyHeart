CREATE TRIGGER dbo.tr_ArbitrageService_Insert ON dbo.ArbitrageService
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ArbitrageService_Insert
     Author:    Chris Carson
    Purpose:    insert Trigger for dbo.ArbitrageService


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processArbitrageService procedure
    2)  INSERT records onto edata.IssueArbitrageServices
    3)  ROLLBACK and RAISERROR if the ID already exists on edata.IssueArbitrageServices

    Notes:
    The ROLLBACK and RAISERROR should not happen. It's in place to prevent primary key errors on the INSERT
    Since the systems are in sync the only time this would occur is if two users tried to enter ArbitrageService data
        on both systems at the same time.  In the unlikely event this happens, the entries on the new system are
        removed by the ROLLBACK, and the data will need to be re-entered.

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processArbitrageService AS VARBINARY(128) = CAST( 'processArbitrageService' AS VARBINARY(128) ) ;


--  1)  Stop processing when trigger is invoked by Conversion.processArbitrageService procedure
    IF  CONTEXT_INFO() = @processArbitrageService
        RETURN ;


--  2)  INSERT records onto edata.IssueArbitrageServices
    SET IDENTITY_INSERT edata.IssueArbitrageServices ON ;

    BEGIN TRY
    INSERT  edata.IssueArbitrageServices (
            ID
          , IssueId
          , DtService
          , ComputationType
          , ynDataReq
          , ynDataIn
          , ynReport
          , Fee )
    SELECT  ID
          , IssueID
          , DtService
          , ComputationType
          , ynDataReq
          , ynDataIn
          , ynReport
          , Fee
      FROM  Conversion.vw_ConvertedArbitrageService AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ArbitrageServiceID = a.id ) ;
    END TRY


--  3)  ROLLBACK and RAISERROR if the ID already exists on edata.IssueArbitrageServices
    BEGIN CATCH
        ROLLBACK ;
        RAISERROR ( 'Error on INSERT to edata.IssueArbitrageServices', 16, 1 ) ;
    END CATCH

    SET IDENTITY_INSERT edata.IssueArbitrageServices OFF ;
END
