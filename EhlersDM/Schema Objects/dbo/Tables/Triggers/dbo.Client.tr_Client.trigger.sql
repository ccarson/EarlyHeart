CREATE TRIGGER  tr_Client
            ON  dbo.Client
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_Client
     Author:    ccarson
    Purpose:    writes Client data back to legacy dbo.Clients

    revisor         date            description
    ---------       ----------      ----------------------------
    ccarson         2013-01-24      created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processClients or Conversion.processClientDisclosure procedures
    2)  Stop processing unless Client data has actually changed
    3)  Merge data from dbo.Client back to edata.Clients

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;
    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;
    
    DECLARE @legacyChecksum     AS INT = 0
          , @convertedChecksum  AS INT = 0 ; 
          

--  1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @fromConversion
        OR
        CONTEXT_INFO() = @processClientDisclosure
        RETURN ;

--  2)  Stop processing unless legacy Clients is changed ( Some data on dbo.Client does not write back to edata.Clients )
    SELECT  @legacyChecksum     = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ClientChecksum( 'Legacy' ) AS l
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = l.ClientID ) ;

    SELECT  @convertedChecksum  = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ClientChecksum( 'Converted' ) AS c
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID ) ;
     

--  3)  MERGE new Client data onto edata.Clients
      WITH  changedClients AS (
            SELECT  *
              FROM  Conversion.vw_ConvertedClients  AS c
             WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID ) )
     MERGE  edata.Clients AS tgt
     USING  changedClients    AS src
        ON  tgt.ClientID = src.ClientID
      WHEN  MATCHED THEN
            UPDATE
               SET  ClientDescriptiveName =  src.ClientDescriptiveName
                  , ClientName            =  src.ClientName
                  , InformalName          =  src.InformalName
                  , Prefix                =  src.Prefix
                  , SchoolDistrictNumber  =  src.SchoolDistrictNumber
                  , Status                =  src.Status
                  , StatusDate            =  src.StatusDate
                  , TaxID                 =  src.TaxID
                  , FiscalYearEnd         =  src.FiscalYearEnd
                  , Phone                 =  src.Phone
                  , Fax                   =  src.Fax
                  , TollFree              =  src.TollFree
                  , TypeJurisdiction      =  src.TypeJurisdiction
                  , GovernBoard           =  src.GovernBoard
                  , Population            =  src.Population
                  , NewspaperName         =  src.NewspaperName
                  , WebSite               =  src.WebSite
                  , Notes                 =  src.Notes
                  , QBClient              =  src.QBClient
                  , AcctClass             =  src.AcctClass
                  , ChangeDate            =  src.ChangeDate
                  , ChangeCode            =  'CVClient'
                  , ChangeBy              =  src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT  ( ClientID, ClientDescriptiveName, ClientName
                        , InformalName, Prefix, SchoolDistrictNumber
                        , Status, StatusDate, TaxID, FiscalYearEnd
                        , Phone, Fax, TollFree, TypeJurisdiction
                        , GovernBoard, Population, NewspaperName
                        , WebSite, Notes, QBClient, AcctClass
                        , ChangeDate, ChangeCode, ChangeBy )
            VALUES  ( src.ClientID, src.ClientDescriptiveName, src.ClientName
                        , src.InformalName, src.Prefix, src.SchoolDistrictNumber
                        , src.Status, src.StatusDate, src.TaxID, src.FiscalYearEnd
                        , src.Phone, src.Fax, src.TollFree, src.TypeJurisdiction
                        , src.GovernBoard, src.Population, src.NewspaperName
                        , src.WebSite, src.Notes, src.QBClient, src.AcctClass
                        , src.ChangeDate, 'CVClient', src.ChangeBy ) ;

END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
