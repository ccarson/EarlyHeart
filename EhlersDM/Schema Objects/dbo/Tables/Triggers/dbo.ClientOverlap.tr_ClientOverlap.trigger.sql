CREATE TRIGGER  dbo.tr_ClientOverlap 
            ON  dbo.ClientOverlap
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ClientOverlap
     Author:    ccarson
    Purpose:    writes Counties data back to legacy dbo.Clients

    revisor         date            description
    ---------       ----------      ----------------------------
    ccarson         2013-01-24      created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processClients procedure
    2)  Stop processing unless County data has actually changed
    3)  Replace data on edata.dbo.Clients with county data from Conversion.tvf_LegacyCounties

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processClientCounties AS VARBINARY(128)    = CAST( 'processClientCounties' AS VARBINARY(128) ) 
          , @systemTime     AS DATETIME                 = GETDATE()
          , @systemUser     AS VARCHAR(20)              = dbo.udf_GetSystemUser() ;   


--  1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
    IF  CONTEXT_INFO() = @processClientCounties
        RETURN ;

    BEGIN TRY
--  2)  Stop processing unless Counties have changed ( Some data on dbo.ClientOverlap does not write back to edata.dbo.Clients )
    IF  NOT EXISTS ( SELECT CHECKSUM_AGG( CHECKSUM(*) ) 
                       FROM Conversion.tvf_LegacyCounties( 'Converted' ) AS c
                      WHERE EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID )
                            EXCEPT
                     SELECT CHECKSUM_AGG( CHECKSUM(*) ) 
                       FROM Conversion.tvf_LegacyCounties( 'Legacy' ) AS c
                      WHERE EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID )  )
        RETURN ;


--  3)  MERGE new County data onto edata.dbo.Clients
      WITH  changedClients AS ( 
            SELECT ClientID FROM inserted
                UNION
            SELECT ClientID FROM deleted ) 

    UPDATE  edata.dbo.Clients
       SET  HomeCounty  = t.HomeCounty
          , County1     = t.County1
          , County2     = t.County2
          , County3     = t.County3
          , County4     = t.County4
          , County5     = NULL
          , ChangeBy    = @systemUser
          , ChangeCode  = 'CVCounty'
          , ChangeDate  = @systemTime
      FROM  edata.dbo.Clients AS c
INNER JOIN  Conversion.tvf_LegacyCounties ( 'Converted' ) AS t ON t.ClientID = c.ClientID
     WHERE  EXISTS ( SELECT 1 FROM changedClients AS x WHERE x.ClientID = c.ClientID ) ;
                        
    END TRY

    BEGIN CATCH
        ROLLBACK ; 
        EXECUTE dbo.processEhlersError ; 
    END CATCH 
END
