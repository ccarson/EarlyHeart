CREATE FUNCTION Documents.tvf_DistributionList ( @IssueID AS INT )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Documents.tvf_DistributionList
     Author:    Marty Schultz
    Purpose:    return distribution list data for a given issue

    revisor         date                description
    ---------       -----------         ----------------------------
    mschultz        2013-06-26          created

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
              FROM  dbo.Issue               AS i
             WHERE  i.IssueID = @IssueID ) ,

            clientData AS (
            SELECT  IssueID                 = i.IssueID
                  , SchoolDistrictNumber    = c.SchoolDistrictNumber
                  , ClientName              = c.ClientName
                  , ClientPrefix            = cp.Value
                  , Address1                = a.Address1
                  , Address2                = a.Address2
                  , Address3                = a.Address3
                  , City                    = a.City
                  , StateFull               = s.FullName
                  , Zip                     = a.Zip
                  , JurisdictionTypeID      = c.JurisdictionTypeID
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.Client              AS c  ON c.ClientID = i.ClientID
        INNER JOIN  dbo.ClientPrefix        AS cp ON cp.ClientPrefixID = c.ClientPrefixID
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = a.State
             WHERE  i.IssueID = @IssueID ) ,
             
            clientContactFA1Data AS (
            SELECT  IssueID                 = i.IssueID
                  , FirstName               = con.FirstName
                  , LastName                = con.LastName
                  , Title                   = con.Title
                  , Phone                   = con.Phone
                  , Email                   = con.Email
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueClientsContacts    AS icc ON icc.IssueID = i.IssueID
        INNER JOIN  dbo.ClientContacts          AS cc  ON cc.ClientContactsID = icc.ClientContactsID
        INNER JOIN  dbo.Contact                 AS con ON con.ContactID = cc.ContactID
             WHERE  i.IssueID = @IssueID AND icc.ContactRole = 'FA' AND icc.Ordinal = 1 ) ,
             
            clientContactFA2Data AS (
            SELECT  IssueID                 = i.IssueID
                  , FirstName               = con.FirstName
                  , LastName                = con.LastName
                  , Title                   = con.Title
                  , Phone                   = con.Phone
                  , Email                   = con.Email
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueClientsContacts    AS icc ON icc.IssueID = i.IssueID
        INNER JOIN  dbo.ClientContacts          AS cc  ON cc.ClientContactsID = icc.ClientContactsID
        INNER JOIN  dbo.Contact                 AS con ON con.ContactID = cc.ContactID
             WHERE  i.IssueID = @IssueID AND icc.ContactRole = 'FA' AND icc.Ordinal = 2 ) ,
             
            clientContactOS1Data AS (
            SELECT  IssueID                 = i.IssueID
                  , FirstName               = con.FirstName
                  , LastName                = con.LastName
                  , Title                   = con.Title
                  , Phone                   = con.Phone
                  , Email                   = con.Email
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueClientsContacts    AS icc ON icc.IssueID = i.IssueID
        INNER JOIN  dbo.ClientContacts          AS cc  ON cc.ClientContactsID = icc.ClientContactsID
        INNER JOIN  dbo.Contact                 AS con ON con.ContactID = cc.ContactID
             WHERE  i.IssueID = @IssueID AND icc.ContactRole = 'OS' AND icc.Ordinal = 1 ) ,
             
            clientContactOS2Data AS (
            SELECT  IssueID                 = i.IssueID
                  , FirstName               = con.FirstName
                  , LastName                = con.LastName
                  , Title                   = con.Title
                  , Phone                   = con.Phone
                  , Email                   = con.Email
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueClientsContacts    AS icc ON icc.IssueID = i.IssueID
        INNER JOIN  dbo.ClientContacts          AS cc  ON cc.ClientContactsID = icc.ClientContactsID
        INNER JOIN  dbo.Contact                 AS con ON con.ContactID = cc.ContactID
             WHERE  i.IssueID = @IssueID AND icc.ContactRole = 'OS' AND icc.Ordinal = 2 ) ,

            bondAttorneyData AS (
            SELECT  IssueID          = isf.IssueID
                  , FirmName         = frm.FirmName
                  , Address1         = adr.Address1
                  , Address2         = adr.Address2
                  , Address3         = adr.Address3
                  , City             = adr.City
                  , State            = adr.State
                  , StateFull        = s.FullName
                  , Zip              = adr.Zip
                  , FirmPhone        = frm.FirmPhone
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
        INNER JOIN  dbo.States              AS s   ON s.Abbreviation = adr.State
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 3 ) ,
             
            bondAttorney1 AS (
            SELECT  IssueID          = isf.IssueID
                 ,  FirstName        = con.FirstName
                 ,  LastName         = con.LastName
                 ,  Title            = con.Title
                 ,  Phone            = con.Phone
                 ,  Email            = con.Email        
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.IssueFirmsContacts  AS ifc ON ifc.IssueFirmsID = isf.IssueFirmsID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 3 AND cjf.JobFunctionID = 30 AND ifc.Ordinal = 1 ) ,
             
            bondAttorney2 AS (
            SELECT  IssueID          = isf.IssueID
                 ,  FirstName        = con.FirstName
                 ,  LastName         = con.LastName
                 ,  Title            = con.Title
                 ,  Phone            = con.Phone
                 ,  Email            = con.Email        
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.IssueFirmsContacts  AS ifc ON ifc.IssueFirmsID = isf.IssueFirmsID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 3 AND cjf.JobFunctionID = 30 AND ifc.Ordinal = 2 ) ,
             
            paralegalData AS (
            SELECT  IssueID          = isf.IssueID
                 ,  FirstName        = con.FirstName
                 ,  LastName         = con.LastName
                 ,  Title            = con.Title
                 ,  Phone            = con.Phone
                 ,  Email            = con.Email        
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.IssueFirmsContacts  AS ifc ON ifc.IssueFirmsID = isf.IssueFirmsID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 3 AND cjf.JobFunctionID = 44 AND ifc.Ordinal = 1 ) ,
             
            payingAgentData AS (
            SELECT  IssueID          = isf.IssueID
                  , FirmName         = frm.FirmName
                  , Address1         = adr.Address1
                  , Address2         = adr.Address2
                  , Address3         = adr.Address3
                  , City             = adr.City
                  , State            = adr.State
                  , StateFull        = s.FullName
                  , Zip              = adr.Zip
                  , FirmPhone        = frm.FirmPhone
                  , FirstName        = con.FirstName
                  , LastName         = con.LastName
                  , Title            = con.Title
                  , Phone            = con.Phone
                  , Email            = con.Email
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
        INNER JOIN  dbo.States              AS s   ON s.Abbreviation = adr.State
         LEFT JOIN  dbo.IssueFirmsContacts  AS ifc ON ifc.IssueFirmsID = isf.IssueFirmsID
         LEFT JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
         LEFT JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 14 AND cjf.JobFunctionID = 26 AND ifc.Ordinal = 1 ) ,

            escrowAgentData AS (
            SELECT  IssueID          = isf.IssueID
                  , IssueFirmsID     = isf.IssueFirmsID
                  , FirmName         = frm.FirmName
                  , Address1         = adr.Address1
                  , Address2         = adr.Address2
                  , Address3         = adr.Address3
                  , City             = adr.City
                  , State            = adr.State
                  , StateFull        = s.FullName
                  , Zip              = adr.Zip
                  , FirmPhone        = frm.FirmPhone
                  , FirstName        = con.FirstName
                  , LastName         = con.LastName
                  , Title            = con.Title
                  , Phone            = con.Phone
                  , Email            = con.Email
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = adr.State
         LEFT JOIN  dbo.IssueFirmsContacts  AS ifc ON ifc.IssueFirmsID = isf.IssueFirmsID
         LEFT JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
         LEFT JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 8 AND cjf.JobFunctionID = 27 AND ifc.Ordinal = 1 ) ,
             
            escrowCPAData AS (
            SELECT  IssueID          = isf.IssueID
                  , IssueFirmsID     = isf.IssueFirmsID
                  , FirmName         = frm.FirmName
                  , Address1         = adr.Address1
                  , Address2         = adr.Address2
                  , Address3         = adr.Address3
                  , City             = adr.City
                  , State            = adr.State
                  , StateFull        = s.FullName
                  , Zip              = adr.Zip
                  , FirmPhone        = frm.FirmPhone
                  , FirstName        = con.FirstName
                  , LastName         = con.LastName
                  , Title            = con.Title
                  , Phone            = con.Phone
                  , Email            = con.Email
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = adr.State
         LEFT JOIN  dbo.IssueFirmsContacts  AS ifc ON ifc.IssueFirmsID = isf.IssueFirmsID
         LEFT JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
         LEFT JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 9 AND cjf.JobFunctionID = 28 AND ifc.Ordinal = 1 ) ,
             
            trusteeData AS (
            SELECT  IssueID          = isf.IssueID
                  , IssueFirmsID     = isf.IssueFirmsID
                  , FirmName         = frm.FirmName
                  , Address1         = adr.Address1
                  , Address2         = adr.Address2
                  , Address3         = adr.Address3
                  , City             = adr.City
                  , State            = adr.State
                  , StateFull        = s.FullName
                  , Zip              = adr.Zip
                  , FirmPhone        = frm.FirmPhone
                  , FirstName        = con.FirstName
                  , LastName         = con.LastName
                  , Title            = con.Title
                  , Phone            = con.Phone
                  , Email            = con.Email
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = adr.State
         LEFT JOIN  dbo.IssueFirmsContacts  AS ifc ON ifc.IssueFirmsID = isf.IssueFirmsID
         LEFT JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
         LEFT JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 17 AND cjf.JobFunctionID = 29 AND ifc.Ordinal = 1 ) ,
             
            firstFA AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Phone               = ee.Phone
                  , Email               = ee.Email
                  , Title               = ee.JobTitle
                  , Address1            = a.Address1
                  , Address2            = a.Address2
                  , Address3            = a.Address3
                  , City                = a.City
                  , State               = a.State
                  , StateFull           = s.FullName
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
        INNER JOIN  dbo.EhlersJobGroup          AS ejg ON ejg.EhlersJobGroupID = eej.EhlersJobGroupID
        INNER JOIN  dbo.EhlersOffice            AS eo  ON eo.EhlersOfficeID = ee.EhlersOfficeID
        INNER JOIN  dbo.Address                 AS a   ON a.AddressID = eo.AddressID
        INNER JOIN  dbo.States                  AS s   ON s.Abbreviation = a.State
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 3 AND iee.Ordinal = 1) ,
             
            secondFA AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Phone               = ee.Phone
                  , Email               = ee.Email
                  , Title               = ee.JobTitle
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
        INNER JOIN  dbo.EhlersJobGroup          AS ejg ON ejg.EhlersJobGroupID = eej.EhlersJobGroupID
        INNER JOIN  dbo.EhlersOffice            AS eo  ON eo.EhlersOfficeID = ee.EhlersOfficeID
        INNER JOIN  dbo.Address                 AS a   ON a.AddressID = eo.AddressID
        INNER JOIN  dbo.States                  AS s   ON s.Abbreviation = a.State
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 3 AND iee.Ordinal = 2) ,
             
            thirdFA AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Phone               = ee.Phone
                  , Email               = ee.Email
                  , Title               = ee.JobTitle
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 3 AND iee.Ordinal = 3) ,
             
            financialAnalyst AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Phone               = ee.Phone
                  , Email               = ee.Email
                  , Title               = ee.JobTitle
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 4 AND iee.Ordinal = 1) ,
             
            disclosureCoordinator AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Phone               = ee.Phone
                  , Email               = ee.Email
                  , Title               = ee.JobTitle
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 7 AND iee.Ordinal = 1) ,
             
            bondSaleCoordinator AS (
            SELECT  IssueID             = i.IssueID
                  , FirstName           = ee.FirstName
                  , LastName            = ee.LastName
                  , Phone               = ee.Phone
                  , Email               = ee.Email
                  , Title               = ee.JobTitle
              FROM  dbo.Issue                   AS i
        INNER JOIN  dbo.IssueEhlersEmployees    AS iee ON iee.IssueID = i.IssueID
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS eej ON eej.EhlersEmployeeJobGroupsID = iee.EhlersEmployeeJobGroupsID
        INNER JOIN  dbo.EhlersEmployee          AS ee  ON ee.EhlersEmployeeID = eej.EhlersEmployeeID
             WHERE  i.IssueID = @IssueID AND eej.EhlersJobGroupID = 1 AND iee.Ordinal = 1) ,

            jointClient1 AS (
            SELECT  IssueID                 = @IssueID
                  , ClientName              = c.ClientName
                  , JurisdictionTypeID      = c.JurisdictionTypeID
                  , SchoolDistrictNumber    = c.SchoolDistrictNumber    
                  , Prefix                  = cp.Value
                  , Address1                = a.Address1
                  , Address2                = a.Address2
                  , Address3                = a.Address3
                  , City                    = a.City
                  , State                   = a.State
                  , StateFull               = s.FullName
                  , Zip                     = a.Zip
              FROM  dbo.Client              AS c
        INNER JOIN  dbo.JurisdictionType    AS jt ON jt.JurisdictionTypeID = c.JurisdictionTypeID
        INNER JOIN  dbo.ClientPrefix        AS cp ON cp.ClientPrefixID = c.ClientPrefixID
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = a.State
             WHERE  c.ClientID =
                    (
                        SELECT  jc.ClientID
                          FROM  dbo.Issue               AS i
                    INNER JOIN  dbo.IssueJointClient    AS jc ON jc.IssueID = i.IssueID
                         WHERE  i.IssueID = @IssueID    AND jc.Ordinal = 1
                    )) ,
                    
            jointClient2 AS (
            SELECT  IssueID                 = @IssueID
                  , ClientName              = c.ClientName
                  , JurisdictionTypeID      = c.JurisdictionTypeID
                  , SchoolDistrictNumber    = c.SchoolDistrictNumber    
                  , Prefix                  = cp.Value
                  , Address1                = a.Address1
                  , Address2                = a.Address2
                  , Address3                = a.Address3
                  , City                    = a.City
                  , State                   = a.State
                  , StateFull               = s.FullName
                  , Zip                     = a.Zip
              FROM  dbo.Client              AS c
        INNER JOIN  dbo.JurisdictionType    AS jt ON jt.JurisdictionTypeID = c.JurisdictionTypeID
        INNER JOIN  dbo.ClientPrefix        AS cp ON cp.ClientPrefixID = c.ClientPrefixID
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = a.State
             WHERE  c.ClientID =
                    (
                        SELECT  jc.ClientID
                          FROM  dbo.Issue               AS i
                    INNER JOIN  dbo.IssueJointClient    AS jc ON jc.IssueID = i.IssueID
                         WHERE  i.IssueID = @IssueID    AND jc.Ordinal = 2
                    )) 

    SELECT  IssueID                     = ISNULL( id.IssueID, '' )
          , IssueAmount                 = ISNULL( id.IssueAmount, 0 )
          , IssueName                   = ISNULL( id.IssueName, '' )
          , Client_SchoolDistrictNumber = ISNULL( cd.SchoolDistrictNumber, '' )
          , Client_Name                 = ISNULL( cd.ClientName, '' )
          , Client_Prefix               = ISNULL( cd.ClientPrefix, '' )
          , Client_Address1             = ISNULL( cd.Address1, '' )
          , Client_Address2             = ISNULL( cd.Address2, '' )
          , Client_Address3             = ISNULL( cd.Address3, '' )
          , Client_City                 = ISNULL( cd.City, '' )
          , Client_StateFull            = ISNULL( cd.StateFull, '' )
          , Client_Zip                  = ISNULL( cd.Zip, '' )
          , Client_JurisdictionTypeID   = ISNULL( cd.JurisdictionTypeID, 0 )
          , CCFA1_FirstName             = ISNULL( cf1.FirstName, '' )
          , CCFA1_LastName              = ISNULL( cf1.LastName, '' )
          , CCFA1_Title                 = ISNULL( cf1.Title, '' )
          , CCFA1_Phone                 = ISNULL( cf1.Phone, '' )
          , CCFA1_Email                 = ISNULL( cf1.Email, '' )
          , CCFA2_FirstName             = ISNULL( cf2.FirstName, '' )
          , CCFA2_LastName              = ISNULL( cf2.LastName, '' )
          , CCFA2_Title                 = ISNULL( cf2.Title, '' )
          , CCFA2_Phone                 = ISNULL( cf2.Phone, '' )
          , CCFA2_Email                 = ISNULL( cf2.Email, '' )
          , CCOS1_FirstName             = ISNULL( co1.FirstName, '' )
          , CCOS1_LastName              = ISNULL( co1.LastName, '' )
          , CCOS1_Title                 = ISNULL( co1.Title, '' )
          , CCOS1_Phone                 = ISNULL( co1.Phone, '' )
          , CCOS1_Email                 = ISNULL( co1.Email, '' )
          , CCOS2_FirstName             = ISNULL( co2.FirstName, '' )
          , CCOS2_LastName              = ISNULL( co2.LastName, '' )
          , CCOS2_Title                 = ISNULL( co2.Title, '' )
          , CCOS2_Phone                 = ISNULL( co2.Phone, '' )
          , CCOS2_Email                 = ISNULL( co2.Email, '' )
          , BA_FirmName                 = ISNULL( bad.FirmName, '' )
          , BA_Address1                 = ISNULL( bad.Address1, '' )
          , BA_Address2                 = ISNULL( bad.Address2, '' )
          , BA_Address3                 = ISNULL( bad.Address3, '' )
          , BA_City                     = ISNULL( bad.City, '' )
          , BA_State                    = ISNULL( bad.State, '' )
          , BA_StateFull                = ISNULL( bad.StateFull, '' )
          , BA_Zip                      = ISNULL( bad.Zip, '' )
          , BA_FirmPhone                = ISNULL( bad.FirmPhone, '' )
          , BA1_FirstName               = ISNULL( ba1.FirstName, '' )
          , BA1_LastName                = ISNULL( ba1.LastName, '' )
          , BA1_Title                   = ISNULL( ba1.Title, '' )
          , BA1_Phone                   = ISNULL( ba1.Phone, '' )
          , BA1_Email                   = ISNULL( ba1.Email, '' )
          , BA2_FirstName               = ISNULL( ba2.FirstName, '' )
          , BA2_LastName                = ISNULL( ba2.LastName, '' )
          , BA2_Title                   = ISNULL( ba2.Title, '' )
          , BA2_Phone                   = ISNULL( ba2.Phone, '' )
          , BA2_Email                   = ISNULL( ba2.Email, '' )
          , PARA_FirstName              = ISNULL( par.FirstName, '' )
          , PARA_LastName               = ISNULL( par.LastName, '' )
          , PARA_Title                  = ISNULL( par.Title, '' )
          , PARA_Phone                  = ISNULL( par.Phone, '' )
          , PARA_Email                  = ISNULL( par.Email, '' )
          , PA_FirmName                 = ISNULL( pad.FirmName, '' )
          , PA_Address1                 = ISNULL( pad.Address1, '' )
          , PA_Address2                 = ISNULL( pad.Address2, '' )
          , PA_Address3                 = ISNULL( pad.Address3, '' )
          , PA_City                     = ISNULL( pad.City, '' )
          , PA_State                    = ISNULL( pad.State, '' )
          , PA_StateFull                = ISNULL( pad.StateFull, '' )
          , PA_Zip                      = ISNULL( pad.Zip, '' )
          , PA_FirmPhone                = ISNULL( pad.FirmPhone, '' )
          , PA_FirstName                = ISNULL( pad.FirstName, '' )
          , PA_LastName                 = ISNULL( pad.LastName, '' )
          , PA_Title                    = ISNULL( pad.Title, '' )
          , PA_Phone                    = ISNULL( pad.Phone, '' )
          , PA_Email                    = ISNULL( pad.Email, '' )
          , EA_FirmName                 = ISNULL( ead.FirmName, '' )
          , EA_Address1                 = ISNULL( ead.Address1, '' )
          , EA_Address2                 = ISNULL( ead.Address2, '' )
          , EA_Address3                 = ISNULL( ead.Address3, '' )
          , EA_City                     = ISNULL( ead.City, '' )
          , EA_State                    = ISNULL( ead.State, '' )
          , EA_StateFull                = ISNULL( ead.StateFull, '' )
          , EA_Zip                      = ISNULL( ead.Zip, '' )
          , EA_FirmPhone                = ISNULL( ead.FirmPhone, '' )
          , EA_FirstName                = ISNULL( ead.FirstName, '' )
          , EA_LastName                 = ISNULL( ead.LastName, '' )
          , EA_Title                    = ISNULL( ead.Title, '' )
          , EA_Phone                    = ISNULL( ead.Phone, '' )
          , EA_Email                    = ISNULL( ead.Email, '' )
          , EC_FirmName                 = ISNULL( ecd.FirmName, '' )
          , EC_Address1                 = ISNULL( ecd.Address1, '' )
          , EC_Address2                 = ISNULL( ecd.Address2, '' )
          , EC_Address3                 = ISNULL( ecd.Address3, '' )
          , EC_City                     = ISNULL( ecd.City, '' )
          , EC_State                    = ISNULL( ecd.State, '' )
          , EC_StateFull                = ISNULL( ecd.StateFull, '' )
          , EC_Zip                      = ISNULL( ecd.Zip, '' ) 
          , EC_FirmPhone                = ISNULL( ecd.FirmPhone, '' )
          , EC_FirstName                = ISNULL( ecd.FirstName, '' )
          , EC_LastName                 = ISNULL( ecd.LastName, '' ) 
          , EC_Title                    = ISNULL( ecd.Title, '' )
          , EC_Phone                    = ISNULL( ecd.Phone, '' )
          , EC_Email                    = ISNULL( ecd.Email, '' ) 
          , TR_FirmName                 = ISNULL( td.FirmName, '' )
          , TR_Address1                 = ISNULL( td.Address1, '' )
          , TR_Address2                 = ISNULL( td.Address2, '' )
          , TR_Address3                 = ISNULL( td.Address3, '' )
          , TR_City                     = ISNULL( td.City, '' )
          , TR_State                    = ISNULL( td.State, '' )
          , TR_StateFull                = ISNULL( td.StateFull, '' )
          , TR_Zip                      = ISNULL( td.Zip, '' )
          , TR_FirmPhone                = ISNULL( td.FirmPhone, '' ) 
          , TR_FirstName                = ISNULL( td.FirstName, '' )
          , TR_LastName                 = ISNULL( td.LastName, '' ) 
          , TR_Title                    = ISNULL( td.Title, '' )
          , TR_Phone                    = ISNULL( td.Phone, '' )
          , TR_Email                    = ISNULL( td.Email, '' )       
          , FA1_FirstName               = ISNULL( fa1.FirstName, '' )
          , FA1_LastName                = ISNULL( fa1.LastName, '' )
          , FA1_Phone                   = ISNULL( fa1.Phone, '' )
          , FA1_Email                   = ISNULL( fa1.Email, '' )
          , FA1_Title                   = ISNULL( fa1.Title, '' )
          , FA1_Address1                = ISNULL( fa1.Address1, '' )
          , FA1_Address2                = ISNULL( fa1.Address2, '' )
          , FA1_Address3                = ISNULL( fa1.Address3, '' )
          , FA1_City                    = ISNULL( fa1.City, '' )
          , FA1_State                   = ISNULL( fa1.State, '' )
          , FA1_StateFull               = ISNULL( fa1.StateFull, '' )
          , FA2_FirstName               = ISNULL( fa2.FirstName, '' )
          , FA2_LastName                = ISNULL( fa2.LastName, '' )
          , FA2_Phone                   = ISNULL( fa2.Phone, '' )
          , FA2_Email                   = ISNULL( fa2.Email, '' )
          , FA2_Title                   = ISNULL( fa2.Title, '' )
          , FA3_FirstName               = ISNULL( fa3.FirstName, '' )
          , FA3_LastName                = ISNULL( fa3.LastName, '' )
          , FA3_Phone                   = ISNULL( fa3.Phone, '' )
          , FA3_Email                   = ISNULL( fa3.Email, '' )
          , FA3_Title                   = ISNULL( fa3.Title, '' )
          , FAN_FirstName               = ISNULL( fan.FirstName, '' )
          , FAN_LastName                = ISNULL( fan.LastName, '' )
          , FAN_Phone                   = ISNULL( fan.Phone, '' )
          , FAN_Email                   = ISNULL( fan.Email, '' )
          , FAN_Title                   = ISNULL( fan.Title, '' )
          , DC_FirstName                = ISNULL( dc.FirstName, '' )
          , DC_LastName                 = ISNULL( dc.LastName, '' )
          , DC_Phone                    = ISNULL( dc.Phone, '' )
          , DC_Email                    = ISNULL( dc.Email, '' )
          , DC_Title                    = ISNULL( dc.Title, '' )
          , BSC_FirstName               = ISNULL( bsc.FirstName, '' )
          , BSC_LastName                = ISNULL( bsc.LastName, '' )
          , BSC_Phone                   = ISNULL( bsc.Phone, '' )
          , BSC_Email                   = ISNULL( bsc.Email, '' )
          , BSC_Title                   = ISNULL( bsc.Title, '' )
          , JC1_ClientName              = ISNULL( jc1.ClientName, '' )
          , JC1_JurisdictionTypeID      = ISNULL( jc1.JurisdictionTypeID, 0 )
          , JC1_SchoolDistrictNumber    = ISNULL( jc1.SchoolDistrictNumber, '' )
          , JC1_Prefix                  = ISNULL( jc1.Prefix, '' )
          , JC1_Address1                = ISNULL( jc1.Address1, '' )
          , JC1_Address2                = ISNULL( jc1.Address2, '' )
          , JC1_Address3                = ISNULL( jc1.Address3, '' )
          , JC1_City                    = ISNULL( jc1.City, '' )
          , JC1_State                   = ISNULL( jc1.State, '' )
          , JC1_StateFull               = ISNULL( jc1.StateFull, '' )
          , JC1_Zip                     = ISNULL( jc1.Zip, '' )
          , JC2_ClientName              = ISNULL( jc2.ClientName, '' )
          , JC2_JurisdictionTypeID      = ISNULL( jc2.JurisdictionTypeID, 0 )
          , JC2_SchoolDistrictNumber    = ISNULL( jc2.SchoolDistrictNumber, '' )
          , JC2_Prefix                  = ISNULL( jc2.Prefix, '' )
          , JC2_Address1                = ISNULL( jc2.Address1, '' )
          , JC2_Address2                = ISNULL( jc2.Address2, '' )
          , JC2_Address3                = ISNULL( jc2.Address3, '' )
          , JC2_City                    = ISNULL( jc2.City, '' )
          , JC2_State                   = ISNULL( jc2.State, '' )
          , JC2_StateFull               = ISNULL( jc2.StateFull, '' )
          , JC2_Zip                     = ISNULL( jc2.Zip, '' )
      FROM  dbo.Issue AS i
 LEFT JOIN  issueData               AS id  ON id.IssueID  = i.IssueID
 LEFT JOIN  clientData              AS cd  ON cd.IssueID  = i.IssueID
 LEFT JOIN  clientContactFA1Data    AS cf1 ON cf1.IssueID  = i.IssueID
 LEFT JOIN  clientContactFA2Data    AS cf2 ON cf2.IssueID  = i.IssueID
 LEFT JOIN  clientContactOS1Data    AS co1 ON co1.IssueID  = i.IssueID
 LEFT JOIN  clientContactOS2Data    AS co2 ON co2.IssueID  = i.IssueID
 LEFT JOIN  bondAttorneyData        AS bad ON bad.IssueID = i.IssueID
 LEFT JOIN  bondAttorney1           AS ba1 ON bad.IssueID = i.IssueID
 LEFT JOIN  bondAttorney2           AS ba2 ON bad.IssueID = i.IssueID
 LEFT JOIN  paralegalData           AS par ON bad.IssueID = i.IssueID
 LEFT JOIN  payingAgentData         AS pad ON pad.IssueID = i.IssueID
 LEFT JOIN  escrowAgentData         AS ead ON ead.IssueID = i.IssueID
 LEFT JOIN  escrowCPAData           AS ecd ON ecd.IssueID = i.IssueID
 LEFT JOIN  trusteeData             AS td  ON td.IssueID = i.IssueID
 LEFT JOIN  firstFA                 AS fa1 ON fa1.IssueID = i.IssueID
 LEFT JOIN  secondFA                AS fa2 ON fa2.IssueID = i.IssueID
 LEFT JOIN  thirdFA                 AS fa3 ON fa3.IssueID = i.IssueID
 LEFT JOIN  financialAnalyst        AS fan ON fan.IssueID = i.IssueID
 LEFT JOIN  disclosureCoordinator   AS dc  ON dc.IssueID = i.IssueID
 LEFT JOIN  bondSaleCoordinator     AS bsc ON bsc.IssueID = i.IssueID
 LEFT JOIN  jointClient1            AS jc1 ON jc1.IssueID = i.IssueID
 LEFT JOIN  jointClient2            AS jc2 ON jc2.IssueID = i.IssueID
     WHERE  i.IssueID = @IssueID ;
     
