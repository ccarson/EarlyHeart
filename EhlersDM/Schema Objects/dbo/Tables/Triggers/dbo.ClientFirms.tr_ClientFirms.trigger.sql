CREATE TRIGGER  tr_ClientFirms
            ON  dbo.ClientFirms
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ClientFirms
     Author:    Chris Carson
    Purpose:    Synchronizes ClientFirms data with Legacy edata.Clients table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processClientFirms procedure
    2)  INSERT ClientID from trigger tables into @ClientChanges

    Notes:

************************************************************************************************************************************
*/
BEGIN

    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;

    DECLARE @ClientChanges AS TABLE ( ClientID INT ) 

--  1)  Stop processing when trigger is invoked by Conversion.processClientFirms procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @fromConversion
    
--  2)  INSERT ClientID from trigger tables into @ClientChanges
    INSERT  @ClientChanges 
    SELECT  ClientID FROM inserted UNION SELECT ClientID FROM deleted ; 

--  3)  UPDATE legacy Clients data with new ClientFirms data, drawn from CPA and LocalAttorney functions 
      WITH  clientData AS (
            SELECT  ClientID        = chg.ClientID
                  , ClientCPA       = ISNULL ( cpa.ClientCPA, '' )
                  , ClientCPAFirmID = ISNULL ( cpa.ClientCPAFirmID, 0 ) 
                  , LocalAttorney   = ISNULL ( lat.LocalAttorney, '' ) 
                  , LACity          = ISNULL ( a.City, '' )
                  , LAState         = ISNULL ( a.State, '' )                   
              FROM  @ClientChanges                              AS chg 
         LEFT JOIN  Conversion.tvf_ClientCPAs( 'Converted' )    AS cpa ON cpa.ClientID = chg.ClientID
         LEFT JOIN  Conversion.tvf_LocalAttorney( 'Converted' ) AS lat ON lat.ClientID = chg.ClientID 
         LEFT JOIN  dbo.FirmCategories                          AS fc  ON lat.FirmCategoriesID = fc.FirmCategoriesID
         LEFT JOIN  dbo.FirmAddresses                           AS fa  ON fa.FirmID = fc.FirmID
         LEFT JOIN  dbo.Address                                 AS a   ON a.AddressID = fa.AddressID )
       
    UPDATE  edata.Clients 
       SET  ClientCPA       = cd.ClientCPA
          , ClientCPAFirmID = cd.ClientCPAFirmID
          , LocalAttorney   = cd.LocalAttorney
          , LACity          = cd.LACity
          , LAState         = cd.LAState
          , ChangeDate      = GETDATE()
          , ChangeCode      = 'CVClientFirms'
      FROM  edata.Clients AS c
INNER JOIN  clientData        AS cd ON cd.ClientID = c.ClientID ; 

END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END

BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

    INSERT  dbo.ClientFirmsAudit (
            ClientFirmsID
          , ClientID
          , FirmCategoriesID
          , ChangeType
          , ModifiedDate
          , ModifiedUser )
    SELECT  ClientFirmsID
          , ClientID
          , FirmCategoriesID
          , 'I'
          , GETDATE()
          , @SystemUser
      FROM  inserted ;
END

