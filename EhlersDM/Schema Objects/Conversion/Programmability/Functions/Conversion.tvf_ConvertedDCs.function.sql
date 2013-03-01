CREATE FUNCTION Conversion.tvf_ConvertedDCs( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ConvertedDC
     Author:    Chris Carson
    Purpose:    returns DisclosureCoordinator data in a table format

    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source         VARCHAR(20)     'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  dc AS (
        SELECT  ClientID    = ClientID
              , Initials    = Analyst 
          FROM  edata.Clients
         WHERE  @Source = 'Legacy' AND Analyst <> '' ) ,

        employees AS (
        SELECT  eg.EhlersEmployeeJobGroupsID
              , ee.Initials
          FROM  dbo.EhlersEmployeeJobGroups AS eg
    INNER JOIN  dbo.EhlersEmployee          AS ee ON ee.EhlersEmployeeID = eg.EhlersEmployeeID
         WHERE  @Source = 'Legacy'
           AND  EXISTS ( SELECT  1 
                           FROM  dbo.EhlersJobGroup AS jg
                          WHERE  jg.Value IN ( 'DC' ) 
                            AND  jg.EhlersJobGroupID = eg.EhlersJobGroupID ) ) , 

        legacy AS (
        SELECT  ClientID                    = dc.ClientID
              , EhlersEmployeeJobGroupsID   = e.EhlersEmployeeJobGroupsID
              , Ordinal                     = 1
          FROM  dc
    INNER JOIN  employees AS e ON e.Initials = dc.Initials
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ClientID
              , EhlersEmployeeJobGroupsID
              , Ordinal
          FROM  dbo.ClientAnalysts  AS ca
         WHERE  EXISTS ( SELECT  1 
                           FROM  dbo.EhlersEmployeeJobGroups AS ejg 
                     INNER JOIN  dbo.EhlersJobGroup          AS jg 
                             ON  jg.EhlersJobGroupID = ejg.EhlersJobGroupID
                          WHERE  jg.Value IN ( 'DC' )
                                 AND ejg.EhlersEmployeeJobGroupsID = ca.EhlersEmployeeJobGroupsID ) ) , 
        inputData AS (
        SELECT  ClientID, EhlersEmployeeJobGroupsID, Ordinal FROM legacy    UNION ALL
        SELECT  ClientID, EhlersEmployeeJobGroupsID, Ordinal FROM converted )

SELECT  ClientID
      , EhlersEmployeeJobGroupsID
      , Ordinal
  FROM  inputData ;
GO

