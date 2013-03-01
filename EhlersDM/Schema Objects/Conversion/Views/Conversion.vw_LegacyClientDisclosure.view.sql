CREATE VIEW Conversion.vw_LegacyClientDisclosure
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyDisclosure
     Author:    ccarson
    Purpose:    shows "scrubbed" version of client Disclosure


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  ClientID                =   c.ClientID
          , DisclosureType          =   CAST( CASE  d.DisclosureType
                                                    WHEN 0  THEN 'Full'
                                                    WHEN 1  THEN 'Limited'
                                              END  AS VARCHAR(100) )
          , ContractType            =   CAST( CASE  d.ContractType
                                                    WHEN 0  THEN 'Fee'
                                                    WHEN 1  THEN 'Hourly'
                                                    WHEN 2  THEN 'Client'
                                                    ELSE ''
                                              END  AS VARCHAR(100) )
          , ContractDate            =   ISNULL( d.ContractDate, '1900-01-01' )
          , ChangeDate              =   ISNULL( c.ChangeDate, GETDATE() )
          , ChangeBy                =   ISNULL( c.ChangeBy, 'processDisclosure' )
      FROM  edata.Clients    AS c
INNER JOIN  edata.Disclosure AS d ON d.ClientID = c.ClientID
     WHERE  d.DisclosureType IN ( 0, 1 ) ;

