CREATE TRIGGER  tr_Firm 
            ON  dbo.Firm
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_Firm
     Author:    Chris Carson
    Purpose:    writes Firm data back to legacy edata.Firms

    revisor         date            description
    ---------       ----------      ----------------------------
    ccarson         2013-01-24      created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
    2)  Stop processing unless Firm data has actually changed
    3)  Merge data from dbo.Firm back to edata.Firms

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processFirms AS VARBINARY(128) = CAST( 'processFirms' AS VARBINARY(128) )
          , @legacyChecksum AS INT = 0
          , @convertedChecksum AS INT = 0 ;


--  1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @processFirms
        RETURN ;


--  2)  Stop processing unless Firm data has actually changed ( Some data on dbo.Firm does not write back to edata.Firms )
    SELECT  @legacyChecksum = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_FirmChecksum( 'Legacy' ) AS f
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.FirmID = f.FirmID ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_FirmChecksum( 'Converted' ) AS f
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.FirmID = f.FirmID ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        RETURN ;


--  3)  MERGE new Firm data onto edata.Firms
      WITH  changedFirms AS (
            SELECT  *
              FROM  Conversion.vw_ConvertedFirms
             WHERE  FirmID IN ( SELECT FirmID FROM inserted ) )
     MERGE  edata.Firms AS tgt
     USING  changedFirms    AS src ON tgt.FirmID = src.FirmID
      WHEN  MATCHED THEN
            UPDATE SET  Firm       = src.Firm
                      , FirmStatus = src.FirmStatus
                      , ShortName  = src.ShortName
                      , Phone      = src.Phone
                      , Fax        = src.Fax
                      , TollFree   = src.TollFree
                      , WebSite    = src.WebSite
                      , GoodFaith  = src.GoodFaith
                      , Notes      = src.Notes
                      , ChangeDate = src.ChangeDate
                      , ChangeCode = 'cvFirmUPD'
                      , ChangeBy   = src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( FirmID, Firm, FirmStatus, ShortName, Phone, Fax, TollFree
                        , WebSite, GoodFaith, Notes, ChangeDate, ChangeCode, ChangeBy )
            VALUES ( src.FirmID, src.Firm, src.FirmStatus, src.ShortName, src.Phone, src.Fax, src.TollFree
                        , src.WebSite, src.GoodFaith, src.Notes, src.ChangeDate, 'cvFirmINS', src.ChangeBy ) ;


END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
