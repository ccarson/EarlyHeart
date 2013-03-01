CREATE TRIGGER  tr_ClientServices
            ON  dbo.ClientServices
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ClientServices
     Author:    Chris Carson
    Purpose:    Synchronizes ClientServices data with Legacy edata.ClientServices table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:

    Notes:

************************************************************************************************************************************
*/
BEGIN

    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processClientServices  AS VARBINARY(128) = CAST( 'processClientServices' AS VARBINARY(128) ) ;

BEGIN TRY

--  1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
    IF  CONTEXT_INFO() = @processClientServices RETURN ;


--  2)  MERGE new client service data onto edata.ClientContacts
      WITH  legacy AS (
            SELECT * FROM edata.ClientsServices AS c
             WHERE EXISTS ( SELECT 1 FROM inserted AS i WHERE c.ClientID = i.ClientID ) ) ,

            clientServices AS (
            SELECT * FROM Conversion.vw_ConvertedClientServices AS c
             WHERE EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID ) )

     MERGE  legacy          AS tgt
     USING  clientServices  AS src
        ON  tgt.ClientID = src.ClientID AND tgt.ServiceCode = src.ServiceCode
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ClientID, ServiceCode )
            VALUES ( src.ClientID, src.ServiceCode )

      WHEN  NOT MATCHED BY SOURCE THEN
            DELETE ;
END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
