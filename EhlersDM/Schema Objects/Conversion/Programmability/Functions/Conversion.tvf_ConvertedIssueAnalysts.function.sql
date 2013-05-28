CREATE FUNCTION Conversion.tvf_ConvertedIssueAnalysts( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ConvertedIssueAnalysts
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
  WITH  employeeJobGroups AS (
        SELECT  EhlersJobGroupID FROM dbo.EhlersJobGroup
         WHERE  Value IN ( 'FA', 'FS', 'BSC', 'DC' ) ) ,

        employees AS (
        SELECT  eg.EhlersEmployeeJobGroupsID
              , ee.Initials
          FROM  dbo.EhlersEmployeeJobGroups AS eg
    INNER JOIN  dbo.EhlersEmployee          AS ee ON ee.EhlersEmployeeID = eg.EhlersEmployeeID
         WHERE  eg.EhlersJobGroupID IN ( SELECT EhlersJobGroupID FROM employeeJobGroups ) ) ,

        analysts AS (
        SELECT  IssueID     = IssueId
              , [1]         = CAST( FA1 AS VARCHAR )
              , [2]         = CAST( FA2 AS VARCHAR )
              , [3]         = CAST( FA3 AS VARCHAR )
              , [4]         = CAST( Analyst AS VARCHAR )
              , [5]         = CAST( BSC AS VARCHAR )
          FROM  edata.Issues
         WHERE  @Source = 'Legacy' ) ,

        legacy AS (
        SELECT  IssueID                     = a.IssueID
              , EhlersEmployeeJobGroupsID   = e.EhlersEmployeeJobGroupsID
              , Ordinal                     = CASE
                                                WHEN a.Ordinal IN ( 4,5 ) THEN 1
                                                ELSE a.Ordinal
                                              END
          FROM  analysts
       UNPIVOT  ( Initials FOR Ordinal
                    IN ( [1], [2], [3], [4], [5] ) ) AS a
    INNER JOIN  employees AS e ON e.Initials = a.Initials 
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  IssueID
              , EhlersEmployeeJobGroupsID
              , Ordinal
          FROM  dbo.IssueEhlersEmployees AS iee
         WHERE  @Source = 'Converted'
           AND  EhlersEmployeeJobGroupsID IN ( SELECT EhlersEmployeeJobGroupsID FROM employees ) ) , 
                                                 
        inputData AS (
        SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal FROM legacy
            UNION ALL
        SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal FROM converted )

SELECT  IssueID
      , EhlersEmployeeJobGroupsID
      , Ordinal
  FROM  inputData ;
GO

