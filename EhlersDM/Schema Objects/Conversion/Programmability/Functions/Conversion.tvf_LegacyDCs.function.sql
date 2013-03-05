CREATE FUNCTION Conversion.tvf_LegacyDCs( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_LegacyDC
     Author:    Chris Carson
    Purpose:    returns Ehlers Analyst data in a Client/ Employee format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source         VARCHAR(20)     'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  ClientID
              , Analyst
          FROM  edata.Clients
         WHERE  @Source = 'Legacy' AND Analyst <> '' ) ,

        converted AS (
        SELECT   ClientID   = ca.ClientID
              ,  Analyst    = ee.Initials
          FROM  dbo.ClientAnalysts          AS ca
    INNER JOIN  dbo.EhlersEmployeeJobGroups AS ejg ON ca.EhlersEmployeeJobGroupsID = ejg.EhlersEmployeeJobGroupsID
    INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = ejg.EhlersEmployeeID
    INNER JOIN  dbo.EhlersJobGroup          AS jg
            ON  jg.EhlersJobGroupID = ejg.EhlersJobGroupID AND jg.Value = 'DC'
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  ClientID, Analyst FROM legacy
            UNION ALL
        SELECT  ClientID, Analyst FROM converted )

SELECT  ClientID
      , Analyst
  FROM  inputData ;

