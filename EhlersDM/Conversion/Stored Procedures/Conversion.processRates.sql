
CREATE PROCEDURE [Conversion].[processRates]
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processRates
     Author:    Mike Kiemen
    Purpose:    converts legacy data from dbo.Rates


    revisor         date                description
    ---------       -----------         ----------------------------
    mkiemen         2013-06-03          created

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  Insert information from edata into ehlers, based on date
    3)  Reset CONTEXT_INFO to re-enable converted table triggers

    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;
    
    DECLARE @processRates        AS VARBINARY(128) = CAST( 'processRates' AS VARBINARY(128) ) ;
BEGIN TRY
--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processRates ;
    
--  2)  Insert information from edata into ehlers, based on date
	INSERT INTO Rate (EffectiveDate, BBIRate, RBIRate, TreasuryRate, ModifiedDate, ModifiedUser)
	SELECT date AS effectiveDate, BBI AS BBIRate, RBI AS RBIRate, Treasury AS TreasuryRate, GETDATE() AS ModifiedDate, 'One-Run' AS ModifiedUser 
	FROM edata.rates
	WHERE date NOT IN (SELECT DISTINCT effectivedate FROM rate)
	ORDER BY date
	
--  3)  Reset CONTEXT_INFO to re-enable converted table triggers
     SET CONTEXT_INFO 0x0 ;
     
 END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH
  
END