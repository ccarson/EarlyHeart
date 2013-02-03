CREATE FUNCTION Conversion.tvf_ConvertedCounties( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ConvertedCounties
     Author:    Chris Carson
    Purpose:    returns Counties data in a table format

    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source         VARCHAR(20)     'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  clientCounties AS (
        SELECT  ClientID    = ClientID
              , State       = State
              , [1]         = HomeCounty
              , [2]         = County1
              , [3]         = County2
              , [4]         = County3
              , [5]         = County4
          FROM  edata.dbo.Clients
         WHERE  HomeCounty IS NOT NULL AND @Source = 'Legacy' ) ,

        counties AS (
        SELECT  CountyID    = ClientID
              , State       = State
              , CountyName  = HomeCounty
          FROM  edata.dbo.Clients
         WHERE  TypeJurisdiction = 'County' AND @Source = 'Legacy' ) ,

        legacy AS (
        SELECT  ClientID        = cc.ClientID
              , OverlapClientID = co.CountyID
              , Ordinal         = cc.Ordinal
          FROM  clientCounties
       UNPIVOT  ( CountyName FOR Ordinal
                    IN ( [1], [2], [3], [4], [5] ) ) AS cc
    INNER JOIN  counties AS co ON co.CountyName = cc.CountyName AND co.State = cc.State
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ClientID
              , OverlapClientID
              , Ordinal
          FROM  dbo.ClientOverlap
         WHERE  @Source = 'Converted' AND OverlapTypeID = 1 ) ,

        inputData AS (
        SELECT  ClientID, OverlapClientID, Ordinal FROM legacy    UNION ALL
        SELECT  ClientID, OverlapClientID, Ordinal FROM converted )

SELECT  ClientID
      , OverlapClientID
      , Ordinal
  FROM  inputData ;

