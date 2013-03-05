CREATE FUNCTION Conversion.tvf_LegacyAnalysts( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_LegacyAnalysts
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
              , EhlersContact1
              , EhlersContact2
              , EhlersContact3
              , OriginatingFA1
              , OriginatingFA2
          FROM  edata.Clients
         WHERE  @Source = 'Legacy' ) ,

        clientAnalysts AS (
        SELECT  ca.ClientID
              , ca.Ordinal
              , ee.Initials
          FROM  dbo.ClientAnalysts          AS ca
    INNER JOIN  dbo.EhlersEmployeeJobGroups AS ejg ON ca.EhlersEmployeeJobGroupsID = ejg.EhlersEmployeeJobGroupsID
    INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = ejg.EhlersEmployeeID
    INNER JOIN  dbo.EhlersJobGroup          AS jg
            ON  jg.EhlersJobGroupID = ejg.EhlersJobGroupID AND jg.Value IN ( 'FA', 'FS' )
         WHERE  @Source = 'Converted' ) ,

        converted AS (
        SELECT  ClientID
              , EhlersContact1 = [1]
              , EhlersContact2 = [2]
              , EhlersContact3 = [3]
              , OriginatingFA1 = [4]
              , OriginatingFA2 = [5]
          FROM  clientAnalysts
         PIVOT ( MAX( Initials )
                 FOR Ordinal IN ( [1], [2], [3], [4], [5] ) ) AS x
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  ClientID, EhlersContact1, EhlersContact2, EhlersContact3, OriginatingFA1, OriginatingFA2 FROM legacy
            UNION ALL
        SELECT  ClientID, EhlersContact1, EhlersContact2, EhlersContact3, OriginatingFA1, OriginatingFA2 FROM converted )

SELECT  ClientID
      , EhlersContact1
      , EhlersContact2
      , EhlersContact3
      , OriginatingFA1
      , OriginatingFA2
  FROM  inputData ;

