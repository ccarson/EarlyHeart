CREATE TRIGGER  tr_ClientDocument
            ON  dbo.ClientDocument
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ClientDocument
     Author:    ccarson
    Purpose:    writes Client disclosure data back to legacy dbo.Disclosure


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processClients procedure
    2)  Stop processing unless Client data has actually changed
    3)  Merge data from dbo.Client back to edata.dbo.Clients
    4)  Merge Disclosure and ContractType data back to edata.dbo.Disclosure

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processClientDisclosure AS VARBINARY(128) = CAST( 'processClientDisclosure' AS VARBINARY(128) ) ;
    
    DECLARE @legacyChecksum     AS INT = 0
          , @convertedChecksum  AS INT = 0 ; 
          

--  1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @processClientDisclosure
        RETURN ;

--  2)  Stop processing unless legacy Disclosure is changed ( Most ClientDocument records do not write back to edata.dbo.Clients )
    SELECT  @legacyChecksum    = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ClientDisclosureChecksum( 'Legacy' ) AS  l
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = l.ClientID ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ClientDisclosureChecksum( 'Converted' ) AS c
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID ) ;
     
    IF  ( @legacyChecksum = @convertedChecksum ) 
        RETURN ;
        
      WITH  changedDisclosure AS ( 
            SELECT * FROM Conversion.vw_ConvertedClientDisclosure AS c 
             WHERE EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID ) ) , 
             
            legacy AS ( 
            SELECT * FROM edata.dbo.Disclosure AS d 
             WHERE EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = d.ClientID ) )
             
     MERGE  legacy            AS tgt
     USING  changedDisclosure AS src ON src.ClientID = tgt.ClientID
      WHEN  MATCHED THEN
            UPDATE 
               SET DisclosureType = src.DisclosureType
                 , ContractType   = src.ContractType
                 , ContractDate   = src.ContractDate
                 
      WHEN  NOT MATCHED BY TARGET THEN 
            INSERT ( ClientID, DisclosureType, ContractType, ContractDate )
            VALUES ( src.ClientID, src.DisclosureType, src.ContractType, src.ContractDate ) 
            
      WHEN  NOT MATCHED BY SOURCE THEN 
            DELETE ; 
    
END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
