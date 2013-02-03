CREATE VIEW Conversion.vw_ConvertedFirms
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedFirms
     Author:    Chris Carson
    Purpose:    Provides legacy view of converted dbo.Firm table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
SELECT  FirmID      = f.FirmID
      , Firm        = f.FirmName
      , ShortName   = f.ShortName
      , FirmStatus  = CASE f.Active WHEN 1 THEN 'Active' ELSE 'Inactive' END
      , Phone       = f.FirmPhone
      , Fax         = f.FirmFax
      , TollFree    = f.FirmTollFree
      , WebSite     = f.FirmWebSite
      , GoodFaith   = f.GoodFaith
      , Notes       = f.FirmNotes
      , ChangeDate  = f.ModifiedDate
      , ChangeBy    = f.ModifiedUser
  FROM  dbo.Firm AS f ;
