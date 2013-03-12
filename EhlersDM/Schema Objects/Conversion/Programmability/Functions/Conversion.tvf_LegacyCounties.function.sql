CREATE FUNCTION [Conversion].[tvf_LegacyCounties]( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_LegacyCounties
     Author:    Chris Carson
    Purpose:    returns Counties data in a Client/County format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source         VARCHAR(20)     'Legacy'|'Converted'

    Notes:
    Instead of 'Legacy'|'Converted' for source, use the sourceTable as noted above

************************************************************************************************************************************
*/
RETURN
  WITH  legacy  AS (
        SELECT  ClientID
              , HomeCounty
              , County1
              , County2
              , County3
              , County4
          FROM  edata.Clients
         WHERE  @Source = 'Legacy' ) ,

        overlap AS (
        SELECT  co.ClientID
              , ordinal
              , CountyName = LEFT(c.ClientName, LEN(c.ClientName) - 7 )
          FROM  dbo.ClientOverlap AS co
    INNER JOIN  dbo.client        AS c  ON c.ClientID = co.OverlapClientID AND c.JurisdictionTypeID = 6 ) ,

        converted AS (
        SELECT  ClientID
              , HomeCounty = [1]
              , County1    = [2]
              , County2    = [3]
              , County3    = [4]
              , County4    = [5]
          FROM  overlap
         PIVOT ( MAX(CountyName)
                 FOR ordinal IN ( [1], [2], [3], [4], [5] ) ) AS x ) ,

        inputData AS (
        SELECT  ClientID, HomeCounty, County1, County2, County3, County4 FROM legacy    UNION ALL
        SELECT  ClientID, HomeCounty, County1, County2, County3, County4 FROM converted ) 

SELECT  ClientID
      , HomeCounty
      , County1
      , County2
      , County3
      , County4
  FROM  inputData ;

