CREATE TRIGGER  tr_FirmCategories
            ON  dbo.FirmCategories
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_FirmCategories
     Author:    Chris Carson
    Purpose:    writes FirmCategories changes back to legacy dbo.Firms


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processFirmCategories
    2)  Write back FirmCategory values to edata.dbo.Firms.FirmCategory

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processFirmCategories AS VARBINARY(128) = CAST( 'processFirmCategories' AS VARBINARY(128) )
          , @changeCode            AS VARCHAR(20)    = 'cvFirmCat' ;

    DECLARE @changedData           AS TABLE ( FirmID        INT
                                            , FirmCategory  VARCHAR (50)
                                            , ModifiedUser  VARCHAR (20)
                                            , ModifiedDate  DATETIME ) ;

BEGIN TRY
--  1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
    IF  CONTEXT_INFO() = @processFirmCategories
        RETURN ;

--  2)  INSERT FirmID and ModifiedUser into @changedData
    INSERT  @changedData ( FirmID, ModifiedUser, ModifiedDate )
    SELECT  DISTINCT FirmID, ModifiedUser, ModifiedDate
      FROM  inserted ;

    INSERT  @changedData ( FirmID, ModifiedUser, ModifiedDate )
    SELECT  DISTINCT FirmID, ModifiedUser, ModifiedDate
      FROM  deleted
     WHERE  FirmID NOT IN ( SELECT FirmID FROM inserted ) ;


--  2)  UPDATE @changedData with legacy FirmCategory data
    UPDATE  @changedData
       SET  FirmCategory = b.FirmCategory
      FROM  @changedData AS a
INNER JOIN  Conversion.tvf_LegacyFirmCategories ( 'Converted' ) AS b ON b.FirmID = a.FirmID


--  3)  Write back FirmCategory values to edata.dbo.Firms.FirmCategory
    UPDATE  edata.dbo.Firms
       SET  FirmCategory = c.FirmCategory
          , ChangeBy     = c.ModifiedUser
          , ChangeDate   = c.ModifiedDate
          , ChangeCode   = @changeCode
      FROM  edata.dbo.Firms AS f
INNER JOIN  @changedData    AS c ON c.FirmID = f.FirmID ;


END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH


END
