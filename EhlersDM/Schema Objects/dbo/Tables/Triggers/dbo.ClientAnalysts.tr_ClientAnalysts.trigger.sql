CREATE TRIGGER  tr_ClientAnalysts
            ON  dbo.ClientAnalysts
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ClientAnalysts
     Author:    ccarson
    Purpose:    writes EhlersFA, DisclosureCoordinator, and OriginatingFA data back to legacy dbo.Clients


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processClientAnalysts procedure
    2)  INSERT ClientIDs from trigger tables into temp storage
    3)  Stop processing if Analyst or DC data has not changed because not all clientAnalysts data writes back to edata.dbo.Clients 
    4)  UPDATE new analyst and DC data onto edata.dbo.Clients

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processClientAnalysts      AS VARBINARY(128)   = CAST( 'processClientAnalysts' AS VARBINARY(128) )
          , @systemTime                 AS DATETIME         = GETDATE()
          , @systemUser                 AS VARCHAR(20)      = dbo.udf_GetSystemUser() ;
    
    DECLARE @changedClients             AS TABLE ( ClientID INT ) ;
    
    DECLARE @legacyAnalystChecksum      AS INT = 0 
          , @convertedAnalystChecksum   AS INT = 0 
          , @legacyDCChecksum           AS INT = 0 
          , @convertedDCChecksum        AS INT = 0 ;
    
    
--  1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @processClientAnalysts
        RETURN ;


--  2)  INSERT ClientIDs from trigger tables into temp storage
    INSERT  @changedClients
    SELECT  ClientID FROM inserted
        UNION
    SELECT  ClientID FROM deleted ;

    
--  3)  Stop processing unless Analsyt or DC data has changed ( Not all clientAnalysts data writes back to edata.dbo.Clients )
    SELECT  @legacyAnalystChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_LegacyAnalysts( 'Legacy' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedClients AS b WHERE b.ClientID = a.ClientID ) ; 
      
    SELECT  @legacyDCChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_LegacyDCs( 'Legacy' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedClients AS b WHERE b.ClientID = a.ClientID ) ; 

    SELECT  @convertedAnalystChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_LegacyAnalysts( 'Converted' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedClients AS b WHERE b.ClientID = a.ClientID ) ; 
      
    SELECT  @convertedDCChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_LegacyDCs( 'Converted' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedClients AS b WHERE b.ClientID = a.ClientID ) ; 

    IF  ( @legacyAnalystChecksum = @convertedAnalystChecksum ) AND
        ( @legacyDCChecksum = @convertedDCChecksum ) 
        RETURN ; 
        

--  4)  UPDATE new analyst and DC data onto edata.dbo.Clients
    UPDATE  edata.dbo.Clients
       SET  EhlersContact1  = a.EhlersContact1
          , EhlersContact2  = a.EhlersContact2
          , EhlersContact3  = a.EhlersContact3
          , OriginatingFA1  = a.OriginatingFA1
          , OriginatingFA2  = a.OriginatingFA2
          , Analyst         = d.Analyst
          , ChangeBy        = @systemUser
          , ChangeCode      = 'CVAnalyst'
          , ChangeDate      = @systemTime
      FROM  edata.dbo.Clients AS c 
 LEFT JOIN  Conversion.tvf_LegacyAnalysts ( 'Converted' )  AS a ON a.ClientID = c.ClientID
 LEFT JOIN  Conversion.tvf_LegacyDCs ( 'Converted' )       AS d ON d.ClientID = c.ClientID 
     WHERE  EXISTS ( SELECT 1 FROM @changedClients AS t WHERE t.ClientID = c.ClientID ) ; 
     
    
 
END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END