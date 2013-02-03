CREATE TRIGGER dbo.tr_ArbitrageService_Update ON dbo.ArbitrageService
AFTER UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ArbitrageService_Update
     Author:    Chris Carson
    Purpose:    applies Address change data back to legacy tables


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create dbo.AddressAudit records reflecting UPDATE
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Update Address Data back to dbo.Firms
    4)  Update Address Data back to dbo.Clients
    5)  Update Address Data back to dbo.FirmContacts
    6)  Update Address Data back to dbo.ClientContacts

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processArbitrageService AS VARBINARY(128) = CAST( 'processArbitrageService' AS VARBINARY(128) ) ;


--  1)  Stop processing when trigger is invoked by Conversion.processArbitrageService procedure
    IF  CONTEXT_INFO() = @processArbitrageService
        RETURN ;


--  2)  UPDATE records on edata.dbo.IssueArbitrageServices
    UPDATE  edata.dbo.IssueArbitrageServices
       SET  IssueID         = c.IssueID
          , DtService       = c.DtService
          , ComputationType = c.ComputationType
          , ynDataReq       = c.ynDataReq
          , ynDataIn        = c.ynDataIn
          , ynReport        = c.ynReport
          , Fee             = c.Fee
      FROM  edata.dbo.IssueArbitrageServices AS ias
INNER JOIN  Conversion.vw_ConvertedArbitrageService AS c
        ON  ias.ID = c.ID
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i
                      WHERE i.ArbitrageServiceID = c.ID ) ;
END
