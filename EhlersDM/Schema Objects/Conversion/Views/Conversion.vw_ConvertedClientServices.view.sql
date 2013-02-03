CREATE VIEW Conversion.vw_ConvertedClientServices
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyClients
     Author:    ccarson
    Purpose:    shows "scrubbed" version of Clients


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  ClientID        =   c.ClientID
          , ServiceCode     =   v.LegacyValue
          , ClientServiceID =   c.ClientServiceID 
      FROM  dbo.ClientServices AS c 
INNER JOIN  dbo.ClientService  AS v ON v.ClientServiceID = c.ClientServiceID 
     WHERE  c.Active = 1 ; 
