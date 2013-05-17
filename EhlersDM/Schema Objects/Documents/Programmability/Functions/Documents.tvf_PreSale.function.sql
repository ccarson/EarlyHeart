﻿CREATE FUNCTION Documents.tvf_PreSale ( @IssueID AS INT )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Documents.tvf_PreSale
     Author:    Marty Schultz
    Purpose:    return Pre Sale data for a given Issue

    revisor         date                description
    ---------       -----------         ----------------------------
    mschultz        2013-05-16          created

    Function Arguments:
    @IssueID         int        IssueID for which function will extract data

    Notes:

************************************************************************************************************************************
*/
RETURN
      WITH  issueData AS (
            SELECT  IssueID                 = i.IssueID
                  , IssueAmount             = i.IssueAmount
                  , IssueName               = i.IssueName
                  , MeetingDate             = im.MeetingDate
                  , MeetingTime             = im.MeetingTime
                  , OSPrintDate             = i.OSPrintDate
                  , DatedDate               = i.DatedDate
                  , FirstInterestDate       = i.FirstInterestDate
                  , InterestPaymentFreq     = pf.Value
                  , IssueShortName          = i.IssueShortNameOS
                  , IsMoodyRated            = ir.IsMoodyRated
                  , IsSPRated               = ir.IsSPRated
                  , IsFitchRated            = ir.IsFitchRated
                  , IsNotRated              = ir.IsNotRated
                  , IsMoodyCreditEnhanced   = ir.MoodyCreditEnhanced
                  , IsSPCreditEnhanced      = ir.SPCreditEnhanced
                  , IsNotRatedCreditEnhanced= ir.IsNotRatedCreditEnhanced
                  , IsAAC                   = i.IsAAC
                  , IsTAC                   = i.IsTAC
                  , BankQualified           = i.BankQualified
                  , Callable                = i.Callable
                  , TaxStatus               = i.TaxStatus
                  , FirstCallableMaturity   = ic.FirstCallableMatDate
                  , TypeOfRedemption        = ic.CallTypeID
                  , NumberOfMaturities      = (SELECT COUNT(*) FROM Documents.vw_IssueMaturityAmounts WHERE IssueID = @IssueID)
                  , MethodOfSale            = i.MethodOfSaleID
                  , SecurityType            = i.SecurityTypeID
                  , CallDate                = ic.CallDate
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.IssueRating         AS ir ON ir.IssueID = i.IssueID
         LEFT JOIN  dbo.IssueMeeting        AS im ON im.IssueID = i.IssueID AND im.MeetingPurposeID = 3
        INNER JOIN  dbo.InterestPaymentFreq AS pf ON pf.InterestPaymentFreqID = i.InterestPaymentFreqID
         LEFT JOIN  dbo.IssueCall           AS ic ON ic.IssueID = i.IssueID
             WHERE  i.IssueID = @IssueID ) ,

            clientData AS (
            SELECT  IssueID                 = i.IssueID
                  , SchoolDistrictNumber    = c.SchoolDistrictNumber
                  , ClientName              = c.ClientName
                  , ClientPrefix            = cp.Value
                  , JurisdictionType        = jt.Value
                  , JurisdictionTypeID      = c.JurisdictionTypeID
                  , GoverningBoard          = gb.Value
                  , StateFull               = s.FullName
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.Client              AS c  ON c.ClientID = i.ClientID
        INNER JOIN  dbo.ClientPrefix        AS cp ON cp.ClientPrefixID = c.ClientPrefixID
        INNER JOIN  dbo.JurisdictionType    AS jt ON jt.JurisdictionTypeID = c.JurisdictionTypeID
        INNER JOIN  dbo.GoverningBoard      AS gb ON gb.GoverningBoardID = c.GoverningBoardID
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = a.State
             WHERE  i.IssueID = @IssueID ) ,

            bondAttorneyData AS (
            SELECT  IssueID          = isf.IssueID
                  , FirmID           = frm.FirmID
                  , FirmName         = frm.FirmName
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 3 ) ,

            FA1 AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Title               = ee.JobTitle
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 3 AND iee.Ordinal = 1) ,

            FA2 AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Title               = ee.JobTitle
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 3 AND iee.Ordinal = 2) ,

            FA3 AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Title               = ee.JobTitle
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 3 AND iee.Ordinal = 3)

    SELECT  IssueID                     = ISNULL( id.IssueID, '' )
          , IssueAmount                 = id.IssueAmount
          , IssueName                   = ISNULL( id.IssueName, '' )
          , MeetingDate                 = ISNULL( id.MeetingDate, '' )
          , MeetingTime                 = ISNULL( CAST(id.MeetingTime AS datetime), '' )
          , OSPrintDate                 = ISNULL( id.OSPrintDate, '')
          , DatedDate                   = ISNULL( id.DatedDate, '')
          , FirstInterestDate           = ISNULL( id.FirstInterestDate, '')
          , InterestPaymentFreq         = ISNULL( id.InterestPaymentFreq, '')
          , IssueShortName              = ISNULL( id.IssueShortName, '')
          , IsMoodyRated                = ISNULL( id.IsMoodyRated, '')
          , IsSPRated                   = ISNULL( id.IsSPRated, '')
          , IsFitchRated                = ISNULL( id.IsFitchRated, '')
          , IsNotRated                  = ISNULL( id.IsNotRated, 0)
          , IsMoodyCreditEnhanced       = ISNULL( id.IsMoodyCreditEnhanced, '')
          , IsSPCreditEnhanced          = ISNULL( id.IsSPCreditEnhanced, '')
          , IsNotRatedCreditEnhanced    = ISNULL( id.IsNotRatedCreditEnhanced, 0)
          , IsAAC                       = ISNULL( id.IsAAC, 0 )
          , IsTAC                       = ISNULL( id.IsTAC, 0 )
          , BankQualified               = ISNULL( id.BankQualified, '')
          , Callable                    = ISNULL( id.Callable, '')
          , TaxStatus                   = ISNULL( id.TaxStatus, '')
          , FirstCallableMaturity       = ISNULL( id.FirstCallableMaturity, '')
          , TypeOfRedemption            = ISNULL( id.TypeOfRedemption, 0)
          , NumberOfMaturities          = ISNULL( id.NumberOfMaturities, 0)
          , MethodofSale                = ISNULL( id.MethodOfSale, '')
          , SecurityType                = ISNULL( id.SecurityType, '')
          , CallDate                    = ISNULL( id.CallDate, '')
          , SchoolDistrictNumber        = ISNULL( cd.SchoolDistrictNumber, '' )
          , ClientName                  = ISNULL( cd.ClientName, '' )
          , ClientPrefix                = ISNULL( cd.ClientPrefix, '' )
          , JurisdictionType            = ISNULL( cd.JurisdictionType, '' )
          , JurisdictionTypeID          = ISNULL( cd.JurisdictionTypeID, '' )
          , GoverningBoard              = ISNULL( cd.GoverningBoard, '' )
          , Client_StateFull            = ISNULL( cd.StateFull, '' )
          , BA_FirmID                   = ISNULL( bad.FirmID, '' )
          , BA_FirmName                 = ISNULL( bad.FirmName, '' )
          , FA1_FirstName               = ISNULL( fa1.FirstName, '' )
          , FA1_LastName                = ISNULL( fa1.LastName, '' )
          , FA1_Title                   = ISNULL( fa1.Title, '' )
          , FA2_FirstName               = ISNULL( fa2.FirstName, '' )
          , FA2_LastName                = ISNULL( fa2.LastName, '' )
          , FA2_Title                   = ISNULL( fa2.Title, '' )
          , FA3_FirstName               = ISNULL( fa3.FirstName, '' )
          , FA3_LastName                = ISNULL( fa3.LastName, '' )
          , FA3_Title                   = ISNULL( fa3.Title, '' )
      FROM  dbo.Issue AS i
 LEFT JOIN  issueData               AS id  ON id.IssueID  = i.IssueID
 LEFT JOIN  clientData              AS cd  ON cd.IssueID  = i.IssueID
 LEFT JOIN  bondAttorneyData        AS bad ON bad.IssueID = i.IssueID
 LEFT JOIN  FA1                     AS fa1 ON fa1.IssueID = i.IssueID
 LEFT JOIN  FA2                     AS fa2 ON fa2.IssueID = i.IssueID
 LEFT JOIN  FA3                     AS fa3 ON fa3.IssueID = i.IssueID
     WHERE  i.IssueID = @IssueID ;
