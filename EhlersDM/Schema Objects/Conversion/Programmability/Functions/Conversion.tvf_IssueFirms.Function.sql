﻿CREATE FUNCTION Conversion.tvf_IssueFirms ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

       View:    Conversion.tvf_IssueFirms
     Author:    Chris Carson
    Purpose:    returns professional services data in a format that can be used by legacy and converted systems


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)    'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacyIssues AS (
        SELECT  IssueID FROM Conversion.vw_LegacyIssues
         WHERE  @Source = 'Legacy' ) ,

        firmCategories AS (
        SELECT  FirmCategoriesID = fcs.FirmCategoriesID
              , FirmID           = tvf.FirmID
              , FirmCategoryID   = tvf.FirmCategoryID
              , Category         = fc.LegacyValue
          FROM  dbo.FirmCategories AS fcs
    INNER JOIN  Conversion.tvf_ConvertedFirmCategories( @Source ) AS tvf
            ON  tvf.FirmID = fcs.FirmID AND tvf.FirmCategoryID = fcs.FirmCategoryID
    INNER JOIN  dbo.FirmCategory AS fc ON fc.FirmCategoryID = fcs.FirmCategoryID ) , 

        legacy AS (
        SELECT  IssueID          = ips.IssueID
              , FirmCategoriesID = fcs.FirmCategoriesID
              , FirmID           = fcs.FirmID
              , FirmCategoryID   = fcs.FirmCategoryID
              , Category         = ips.Category
              , FirmName         = NULL
          FROM  edata.dbo.IssueProfSvcs AS ips
    INNER JOIN  legacyIssues            AS iss ON iss.IssueID = ips.IssueID
    INNER JOIN  firmCategories          AS fcs ON fcs.FirmID = ips.FirmID AND fcs.Category = ips.Category
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  IssueID          = isf.IssueID
              , FirmCategoriesID = fcs.FirmCategoriesID 
              , FirmID           = fcs.FirmID
              , FirmCategoryID   = fcs.FirmCategoryID
              , Category         = fcs.Category
              , FirmName         = frm.FirmName + ' ' + QUOTENAME ( adr.City + ', ' + adr.State )
          FROM  dbo.IssueFirms      AS isf
    INNER JOIN  firmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
    INNER JOIN  dbo.Firm            AS frm ON frm.FirmID = fcs.FirmID
    INNER JOIN  dbo.FirmAddresses   AS fra ON fra.FirmID = frm.FirmID AND fra.AddressTypeID = 3
    INNER JOIN  dbo.Address         AS adr ON adr.AddressID = fra.AddressID
         WHERE  @Source = 'Converted' ) ,

      byIssuer  AS (
        SELECT  IssueID          = isf.IssueID
              , FirmCategoriesID = fcs.FirmCategoriesID
              , FirmID           = fcs.FirmID
              , FirmCategoryID   = fcs.FirmCategoryID
              , Category         = fcs.Category
              , FirmName         = frm.FirmName
          FROM  dbo.IssueFirms AS isf
    INNER JOIN  firmCategories AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
    INNER JOIN  dbo.Firm       AS frm ON frm.FirmID = fcs.FirmID
         WHERE  frm.FirmName = 'Issuer' AND @Source = 'Converted' )

SELECT IssueID, FirmCategoriesID, FirmID, FirmCategoryID, Category, FirmName FROM legacy    UNION ALL
SELECT IssueID, FirmCategoriesID, FirmID, FirmCategoryID, Category, FirmName FROM converted UNION ALL
SELECT IssueID, FirmCategoriesID, FirmID, FirmCategoryID, Category, FirmName FROM byIssuer ;
GO

