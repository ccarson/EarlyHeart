CREATE FUNCTION Conversion.tvf_ConvertedAnalysts( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ConvertedAnalysts
     Author:    Chris Carson
    Purpose:    returns Analysts data in a table format

    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source         VARCHAR(20)     'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  analysts AS (
        SELECT  ClientID    = ClientID
              , [1]         = CAST( EhlersContact1 AS VARCHAR )
              , [2]         = CAST( EhlersContact2 AS VARCHAR )
              , [3]         = CAST( EhlersContact3 AS VARCHAR )
              , [4]         = CAST( OriginatingFA1 AS VARCHAR )
              , [5]         = CAST( OriginatingFA2 AS VARCHAR )
          FROM  edata.dbo.Clients
         WHERE  @Source = 'Legacy' ) ,

        employees AS (
        SELECT  eg.EhlersEmployeeJobGroupsID
              , ee.Initials
          FROM  dbo.EhlersEmployeeJobGroups AS eg
    INNER JOIN  dbo.EhlersEmployee          AS ee ON ee.EhlersEmployeeID = eg.EhlersEmployeeID
         WHERE  @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 
                           FROM dbo.EhlersJobGroup AS jg
                          WHERE jg.Value IN ( 'FA', 'FS' ) AND jg.EhlersJobGroupID = eg.EhlersJobGroupID ) ) , 

        legacy AS (
        SELECT  a.ClientID
              , e.EhlersEmployeeJobGroupsID
              , a.Ordinal
          FROM  analysts
       UNPIVOT  ( Initials FOR Ordinal
                    IN ( [1], [2], [3], [4], [5] ) ) AS a
     LEFT JOIN  employees AS e ON e.Initials = a.Initials
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ca.ClientID
              , ca.EhlersEmployeeJobGroupsID
              , ca.Ordinal
          FROM  dbo.ClientAnalysts  AS ca
         WHERE  @Source = 'Converted'          
           AND  EXISTS ( SELECT 1 
                           FROM dbo.EhlersEmployeeJobGroups AS ejg 
                     INNER JOIN dbo.EhlersJobGroup          AS jg 
                             ON jg.EhlersJobGroupID = ejg.EhlersJobGroupID
                          WHERE jg.Value IN ( 'FA', 'FS' )
                                AND ejg.EhlersEmployeeJobGroupsID = ca.EhlersEmployeeJobGroupsID ) ) , 
        inputData AS (
        SELECT  ClientID, EhlersEmployeeJobGroupsID, Ordinal FROM legacy    UNION ALL
        SELECT  ClientID, EhlersEmployeeJobGroupsID, Ordinal FROM converted )

SELECT  ClientID
      , EhlersEmployeeJobGroupsID
      , Ordinal
  FROM  inputData ;
GO

