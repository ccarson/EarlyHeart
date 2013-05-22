CREATE FUNCTION Conversion.tvf_LegacyIssueAnalysts( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_LegacyIssueAnalysts
     Author:    Chris Carson
    Purpose:    returns Ehlers Analyst data in a Issue/ Employee format


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
        SELECT  IssueID = IssueId
              , FA1
              , FA2
              , FA3
              , analyst
              , BSC
          FROM  edata.Issues
         WHERE  @Source = 'Legacy' ) ,

        issueAnalysts AS (
        SELECT  IssueID    = iee.IssueID
              , Ordinal    = CASE ejg.Value 
                                WHEN 'DC'   THEN 4 
                                WHEN 'BSC'  THEN 5
                                ELSE iee.Ordinal
                              END
              , Initials   = emp.Initials
          FROM  dbo.IssueEhlersEmployees    AS iee
    INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
    INNER JOIN  dbo.EhlersEmployee          AS emp ON emp.EhlersEmployeeID = eej.EhlersEmployeeID
    INNER JOIN  dbo.EhlersJobGroup          AS ejg
            ON  ejg.EhlersJobGroupID = emp.EhlersJobGroupID AND ejg.Value IN ( 'FA', 'FS', 'DC', 'BSC' )
         WHERE  @Source = 'Converted' ) ,

        converted AS (
        SELECT  IssueID
              , FA1     = [1]
              , FA2     = [2]
              , FA3     = [3]
              , analyst = [4]
              , BSC     = [5]
          FROM  issueAnalysts
         PIVOT ( MAX( Initials )
                 FOR Ordinal IN ( [1], [2], [3], [4], [5] ) ) AS x
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  IssueID, FA1, FA2, FA3, analyst, BSC FROM legacy
            UNION ALL
        SELECT  IssueID, FA1, FA2, FA3, analyst, BSC FROM converted )

SELECT  IssueID, FA1, FA2, FA3, analyst, BSC
  FROM  inputData ;
