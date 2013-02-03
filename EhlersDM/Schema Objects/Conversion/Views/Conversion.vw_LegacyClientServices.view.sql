CREATE VIEW Conversion.vw_LegacyClientServices
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyClientServices
     Author:    ccarson
    Purpose:    shows "scrubbed" version of edata.dbo.ClientServices


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  ClientID        =   l.ClientID
          , ServiceCode     =   l.ServiceCode
          , ClientServiceID =   c.ClientServiceID
      FROM  edata.dbo.ClientsServices AS l 
INNER JOIN  dbo.ClientService         AS c ON c.LegacyValue = l.ServiceCode 
     WHERE  EXISTS ( SELECT 1 FROM edata.dbo.Clients AS c WHERE c.ClientID = l.ClientID ) ;
