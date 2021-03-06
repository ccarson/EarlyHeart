﻿CREATE TRIGGER  tr_ContactJobFunctions
            ON  dbo.ContactJobFunctions
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ContactJobFunctions
     Author:    Chris Carson
    Purpose:    writes JobFunction changes back to legacy Contacts

    Revision History:
    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
    2)  Pull unique list of triggered ContactIDs into temp storage
    3)  Stop processing unless Contacts JobFunction data has actually changed
    4)  update legacy Contacts with new JobFunction field

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processJobFunctions AS VARBINARY(128) = CAST( 'processJobFunctions' AS VARBINARY(128) ) ;

    DECLARE @changes AS TABLE ( ContactID INT ) ;

    CREATE TABLE #jobFunctions ( LegacyContactID INT
                               , LegacyTableName VARCHAR (20)
                               , ContactID       INT
                               , JobFunction     VARCHAR (50)
                               , ModifiedDate    DATETIME
                               , ModifiedUser    VARCHAR (20) ) ;



--  1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
BEGIN TRY
    IF  CONTEXT_INFO() = @processJobFunctions
        RETURN ;


--  2)  INSERT ContactIDs from trigger tables into @changes
    INSERT  @changes
    SELECT  ContactID FROM inserted
        UNION
    SELECT  ContactID FROM deleted ;


--  3)  UPDATE edata.dbo.FirmContacts with new JobFunction field
      WITH  jobFunctions AS (
            SELECT  c.ContactID
                  , j.LegacyContactID
                  , j.JobFunction
              FROM  @changes AS c 
         LEFT JOIN  Conversion.tvf_LegacyJobFunctions( 'Converted' ) AS j ON j.ContactID = c.ContactID 
             WHERE  ISNULL( j.LegacyTableName, 'FirmContacts' ) = 'FirmContacts' ) , 

            contactData AS (
            SELECT  ContactID
                  , ModifiedDate
                  , ModifiedUser
              FROM  dbo.Contact AS a
             WHERE  EXISTS ( SELECT 1 FROM @changes AS b WHERE b.ContactID = a.ContactID ) )

    UPDATE  edata.dbo.FirmContacts
       SET  JobFunction = jf.JobFunction
          , ChangeCode  = 'CVJobFunction'
          , ChangeDate  = cd.ModifiedDate
          , ChangeBy    = cd.ModifiedUser
      FROM  edata.dbo.FirmContacts  AS fc
INNER JOIN  jobFunctions            AS jf ON jf.LegacyContactID = fc.ContactID
INNER JOIN  contactData             AS cd ON cd.ContactID       = jf.ContactID ;


--  4)  UPDATE edata.dbo.FirmContacts with new JobFunction field
      WITH  jobFunctions AS (
            SELECT  c.ContactID
                  , j.LegacyContactID
                  , j.JobFunction
              FROM  @changes AS c 
         LEFT JOIN  Conversion.tvf_LegacyJobFunctions( 'Converted' ) AS j ON j.ContactID = c.ContactID 
             WHERE  ISNULL( j.LegacyTableName, 'ClientContacts' ) = 'ClientContacts' ) , 

            contactData AS (
            SELECT  ContactID
                  , ModifiedDate
                  , ModifiedUser
              FROM  dbo.Contact AS a
             WHERE  EXISTS ( SELECT 1 FROM @changes AS b WHERE b.ContactID = a.ContactID ) )

    UPDATE  edata.dbo.ClientContacts
       SET  JobFunction = jf.JobFunction
          , ChangeCode  = 'CVJobFunction'
          , ChangeDate  = cd.ModifiedDate
          , ChangeBy    = cd.ModifiedUser
      FROM  edata.dbo.ClientContacts AS cc
INNER JOIN  jobFunctions             AS jf ON jf.LegacyContactID = cc.ContactID
INNER JOIN  contactData              AS cd ON cd.ContactID       = jf.ContactID ;


END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH


END
