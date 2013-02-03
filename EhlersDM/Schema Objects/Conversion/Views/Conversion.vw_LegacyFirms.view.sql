CREATE VIEW Conversion.vw_LegacyFirms
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyFirms
     Author:    Chris Carson
    Purpose:    shows "scrubbed" version of legacy data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
SELECT  FirmID     = f.FirmID
      , Firm       = ISNULL( f.Firm, '' )
      , ShortName  = ISNULL( f.ShortName, '' )
      , FirmStatus = CASE FirmStatus WHEN 'Active' THEN 1 ELSE 0 END 
      , Phone      = ISNULL( f.Phone, '' )
      , Fax        = ISNULL( f.Fax, '' )
      , TollFree   = ISNULL( f.TollFree, '' )
      , WebSite    = ISNULL( f.WebSite, '' )
      , GoodFaith  = ISNULL( CAST( f.GoodFaith AS VARCHAR(MAX) ), '' )
      , Notes      = ISNULL( CAST( f.Notes     AS VARCHAR(MAX) ), '' )
      , ChangeDate = ISNULL( f.ChangeDate, GETDATE() )
      , ChangeBy   = ISNULL( NULLIF( f.ChangeBy, '' ), 'processFirms' )
  FROM  edata.dbo.Firms AS f ;