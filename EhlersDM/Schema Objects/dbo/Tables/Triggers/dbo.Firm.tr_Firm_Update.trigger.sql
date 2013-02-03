CREATE TRIGGER  tr_Firm_Update
            ON  dbo.Firm
AFTER UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_Firm_Update
     Author:    Chris Carson
    Purpose:    writes FirmNameHistory records to reflect Firm name changes


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Process only if FirmName has changed
    2)  Insert dbo.FirmNameHistory to reflect firm name change
    3)  Stop processing when trigger is invoked by Conversion.processFirms procedure
    4)  Write firm name change back to legacy edata.dbo.FirmHistory

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processFirms AS VARBINARY(128) = CAST( 'processFirms' AS VARBINARY(128) ) ;

    BEGIN TRY
--  1)  Process only if FirmName has changed
    IF  NOT EXISTS ( SELECT FirmID, FirmName FROM deleted
                        EXCEPT
                     SELECT FirmID, FirmName FROM inserted )
        RETURN ;


--  2)  Insert dbo.FirmNameHistory on firm name change
    INSERT  dbo.FirmNameHistory ( FirmID, FirmName, ModifiedDate, ModifiedUser )
    SELECT  d.FirmID, d.FirmName, i.ModifiedDate, i.ModifiedUser
      FROM  deleted  AS d
INNER JOIN  inserted AS i ON i.FirmID = d.FirmID AND i.FirmName <> d.FirmName ;


--  3)  Stop processing when trigger is invoked by Conversion.processFirms procedure
    IF  CONTEXT_INFO() = @processFirms
        RETURN ;


--  4)  Write firm name change back to legacy edata.dbo.FirmHistory
    INSERT  edata.dbo.FirmHistory ( FirmID, FirmName, EffectiveDate, sequence )
    SELECT  d.FirmID, d.FirmName, i.ModifiedDate, 0
      FROM  deleted  AS d
INNER JOIN  inserted AS i ON i.FirmID = d.FirmID AND i.FirmName <> d.FirmName ;


END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
