CREATE FUNCTION Conversion.tvf_FirmChecksum ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_FirmChecksum
     Author:    Chris Carson
    Purpose:    returns checksum values for given FirmIDs


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)    'Legacy'|'Converted'

    Notes:
    Use QUOTENAME() to prevent "wrong field" errors.  QUOTENAME() encloses fields with [] and prevents that error from occurring.
    USE CAST for the GoodFaith and Notes from edata.dbo.Firms, HASHBYTES does not compute checksums over text fields.

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  FirmID      = FirmID
              , Firm        = Firm
              , ShortName   = ShortName
              , FirmStatus  = FirmStatus
              , Phone       = QUOTENAME( Phone )
              , Fax         = QUOTENAME( Fax )
              , TollFree    = QUOTENAME( TollFree )
              , WebSite     = WebSite
              , GoodFaith   = GoodFaith
              , Notes       = Notes
          FROM  Conversion.vw_LegacyFirms
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  FirmID      = FirmID
              , Firm        = FirmName
              , ShortName   = ShortName
              , FirmStatus  = Active
              , Phone       = QUOTENAME( FirmPhone )
              , Fax         = QUOTENAME( FirmFax )
              , TollFree    = QUOTENAME( FirmTollFree )
              , WebSite     = FirmWebSite
              , GoodFaith   = GoodFaith
              , Notes       = FirmNotes
          FROM  dbo.Firm
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT FirmID, Firm, ShortName, FirmStatus, Phone, Fax, TollFree, WebSite, GoodFaith, Notes FROM legacy UNION ALL
        SELECT FirmID, Firm, ShortName, FirmStatus, Phone, Fax, TollFree, WebSite, GoodFaith, Notes FROM converted )

SELECT  FirmID       = FirmID
     ,  FirmChecksum = CAST( HASHBYTES( 'md5', CAST( FirmID AS VARCHAR(20) )
                                                  +  Firm
                                                  +  ShortName
                                                  +  CAST( FirmStatus AS VARCHAR(20) )
                                                  +  Phone
                                                  +  Fax
                                                  +  TollFree
                                                  +  WebSite
                                                  +  GoodFaith
                                                  +  Notes ) AS VARBINARY(128) )
  FROM  inputData ;
