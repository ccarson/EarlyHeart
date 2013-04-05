CREATE TRIGGER dbo.tr_ArbitrageService_Delete ON dbo.ArbitrageService
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ArbitrageService_Delete
     Author:    Chris Carson
    Purpose:    delete Trigger for ArbitrageService


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processArbitrageService procedure
    2)  DELETE edata.IssueArbitrageServices records where deleted from dbo.ArbitrageService


    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;
    DECLARE @SystemUser                 AS VARCHAR(20)    = dbo.udf_GetSystemUser() ;


--  1)  Stop processing when trigger is invoked by Conversion.processArbitrageService procedure
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;

--  2)  DELETE edata.IssueArbitrageServices records where deleted from dbo.ArbitrageService
    DELETE  edata.IssueArbitrageServices
      FROM  edata.IssueArbitrageServices AS i
     WHERE  EXISTS ( SELECT 1 FROM deleted AS d WHERE d.ArbitrageServiceID = i.ID ) ;
END
