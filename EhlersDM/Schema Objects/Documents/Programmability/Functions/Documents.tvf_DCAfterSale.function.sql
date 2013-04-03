CREATE FUNCTION Documents.tvf_DCAfterSale ( @IssueID AS INT )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Documents.tvf_BeforeSale
     Author:    Marty Schultz
    Purpose:    return pre-sale documents data for a given Issue

    revisor         date                description
    ---------       -----------         ----------------------------
    mschultz        2013-04-02          created

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
                  , SaleDate                = i.SaleDate
                  , IssueShortNameOS        = i.IssueShortNameOS
                  , MoodyCreditEnhanced     = ir.MoodyCreditEnhanced
                  , SPCreditEnhanced        = ir.SPCreditEnhanced
                  , IsNotRatedCreditEnhanced= ir.IsNotRatedCreditEnhanced
              FROM  dbo.Issue               AS i
         LEFT JOIN  dbo.IssueRating         AS ir ON ir.IssueID = i.IssueID
             WHERE  i.IssueID = @IssueID ) ,

          clientData AS (
            SELECT  IssueID                 = i.IssueID
                  , SchoolDistrictNumber    = c.SchoolDistrictNumber
                  , ClientName              = c.ClientName
                  , ClientPrefix            = cp.Value
                  , JurisdictionType        = jt.Value
                  , GoverningBoard          = gb.Value
                  , Address1                = a.Address1
                  , Address2                = a.Address2
                  , Address3                = a.Address3
                  , City                    = a.City
                  , State                   = a.State
                  , Zip                     = a.Zip
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.Client              AS c  ON c.ClientID = i.ClientID
        INNER JOIN  dbo.ClientPrefix        AS cp ON cp.ClientPrefixID = c.ClientPrefixID
        INNER JOIN  dbo.JurisdictionType    AS jt ON jt.JurisdictionTypeID = c.JurisdictionTypeID
        INNER JOIN  dbo.GoverningBoard      AS gb ON gb.GoverningBoardID = c.GoverningBoardID
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
             WHERE  i.IssueID = @IssueID ) ,

          bondAttorneyFirm AS (
            SELECT  IssueID          = isf.IssueID
                  , IssueFirmsID     = isf.IssueFirmsID
                  , FirmName         = frm.FirmName
                  , City             = adr.City
                  , State            = adr.State
              FROM  dbo.IssueFirms      AS isf
        INNER JOIN  dbo.FirmCategories  AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm            AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses   AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address         AS adr ON adr.AddressID = fma.AddressID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 3 ) ,

             bondAttorneyPrimary AS (
            SELECT  IssueID          = baf.IssueID
                  , FirstName        = con.FirstName
                  , LastName         = con.LastName
                  , Email            = con.Email
              FROM  dbo.IssueFirmsContacts  AS ifc
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
        INNER JOIN  bondAttorneyFirm        AS baf ON baf.IssueFirmsID = ifc.IssueFirmsID
             WHERE  cjf.JobFunctionID = 30 AND ifc.Ordinal = 1 ) ,

             primaryFA AS (
            SELECT  IssueID          = i.IssueID
                  , FirstName        = e.FirstName
                  , LastName         = e.LastName
                  , Phone            = e.Phone
                  , Email            = e.Email
                  , SaleDayAvailable = ISNULL( i.IsSaleDayAvailable, 0 )
                  , SaleDayAttending = ISNULL( i.IsSaleDayAttending, 0 )
              FROM  dbo.EhlersEmployee          AS e
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS g ON g.EhlersEmployeeID = e.EhlersEmployeeID
        INNER JOIN  dbo.IssueEhlersEmployees    AS i ON i.EhlersEmployeeJobGroupsID = g.EhlersEmployeeJobGroupsID
             WHERE  i.IssueID = @IssueID AND g.EhlersJobGroupID = 3 AND i.Ordinal = 1 ) ,

            secondaryFA AS (
            SELECT  IssueID          = i.IssueID
                  , FirstName        = e.FirstName
                  , LastName         = e.LastName
                  , Phone            = e.Phone
                  , Email            = e.Email
                  , SaleDayAvailable = ISNULL( i.IsSaleDayAvailable, 0 )
                  , SaleDayAttending = ISNULL( i.IsSaleDayAttending, 0 )
              FROM  dbo.EhlersEmployee          AS e
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS g ON g.EhlersEmployeeID = e.EhlersEmployeeID
        INNER JOIN  dbo.IssueEhlersEmployees    AS i ON i.EhlersEmployeeJobGroupsID = g.EhlersEmployeeJobGroupsID
             WHERE  i.IssueID = @IssueID AND g.EhlersJobGroupID = 3 AND i.Ordinal = 2 ) ,

            tertiaryFA AS (
            SELECT  IssueID          = i.IssueID
                  , FirstName        = e.FirstName
                  , LastName         = e.LastName
                  , Phone            = e.Phone
                  , Email            = e.Email
                  , SaleDayAvailable = ISNULL( i.IsSaleDayAvailable, 0 )
                  , SaleDayAttending = ISNULL( i.IsSaleDayAttending, 0 )
              FROM  dbo.EhlersEmployee          AS e
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS g ON g.EhlersEmployeeID = e.EhlersEmployeeID
        INNER JOIN  dbo.IssueEhlersEmployees    AS i ON i.EhlersEmployeeJobGroupsID = g.EhlersEmployeeJobGroupsID
             WHERE  i.IssueID = @IssueID AND g.EhlersJobGroupID = 3 AND i.Ordinal = 3 ) ,

            disclosureCoordinator AS (
            SELECT  IssueID     = i.IssueID
                  , FirstName   = e.FirstName
                  , LastName    = e.LastName
                  , Email       = e.Email
              FROM  dbo.EhlersEmployee          AS e
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS g ON g.EhlersEmployeeID = e.EhlersEmployeeID
        INNER JOIN  dbo.IssueEhlersEmployees    AS i ON i.EhlersEmployeeJobGroupsID = g.EhlersEmployeeJobGroupsID
             WHERE  i.IssueID = @IssueID AND g.EhlersJobGroupID = 7 AND i.Ordinal = 1 ) ,

            financialAnalyst AS (
            SELECT  IssueID     = i.IssueID
                  , FirstName   = e.FirstName
                  , LastName    = e.LastName
                  , Phone       = e.Phone
                  , Email       = e.Email
              FROM  dbo.EhlersEmployee          AS e
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS g ON g.EhlersEmployeeID = e.EhlersEmployeeID
        INNER JOIN  dbo.IssueEhlersEmployees    AS i ON i.EhlersEmployeeJobGroupsID = g.EhlersEmployeeJobGroupsID
             WHERE  i.IssueID = @IssueID AND g.EhlersJobGroupID = 4 AND i.Ordinal= 1 ) ,

             primaryFAContact AS (
            SELECT  IssueID          = i.IssueID
                  , FirstName        = c.FirstName
                  , LastName         = c.LastName
                  , Title            = c.Title
                  , Email            = c.Email
                  , Phone            = c.Phone
              FROM  dbo.IssueClientsContacts    AS i
        INNER JOIN  dbo.ClientContacts          AS cc ON cc.ClientContactsID = i.ClientContactsID
        INNER JOIN  dbo.Contact                 AS c  ON c.ContactID = cc.ContactID
             WHERE  i.IssueID = @IssueID AND i.ContactRole = 'FA' AND i.Ordinal = 1 ) ,

             primaryDCContact AS (
            SELECT  IssueID          = i.IssueID
                  , FirstName        = c.FirstName
                  , LastName         = c.LastName
                  , Email            = c.Email
              FROM  dbo.IssueClientsContacts    AS i
        INNER JOIN  dbo.ClientContacts          AS cc ON cc.ClientContactsID = i.ClientContactsID
        INNER JOIN  dbo.Contact                 AS c  ON c.ContactID = cc.ContactID
             WHERE  i.IssueID = @IssueID AND i.ContactRole = 'OS' AND i.Ordinal = 1 )

    SELECT  ID_IssueID                  = ISNULL( id.IssueID, '' )
          , ID_IssueAmount              = id.IssueAmount
          , ID_IssueName                = ISNULL( id.IssueName, '' )
          , ID_SaleDate                 = ISNULL( id.SaleDate, '' )
          , ID_IssueShortNameOS         = ISNULL( id.IssueShortNameOS, '' )
          , ID_MoodyCreditEnhanced      = ISNULL( id.MoodyCreditEnhanced, 0)
          , ID_SPCreditEnhanced         = ISNULL( id.SPCreditEnhanced, 0)
          , ID_IsNotRatedCreditEnhanced = ISNULL( id.IsNotRatedCreditEnhanced, 0)
          , CD_SchoolDistrictNumber     = ISNULL( cd.SchoolDistrictNumber, '' )
          , CD_ClientName               = ISNULL( cd.ClientName, '' )
          , CD_ClientPrefix             = ISNULL( cd.ClientPrefix, '' )
          , CD_JurisdictionType         = ISNULL( cd.JurisdictionType, '' )
          , CD_GoverningBoard           = ISNULL( cd.GoverningBoard, '' )
          , CD_Address1                 = ISNULL( cd.Address1, '' )
          , CD_Address2                 = ISNULL( cd.Address2, '' )
          , CD_Address3                 = ISNULL( cd.Address3, '' )
          , CD_City                     = ISNULL( cd.City, '' )
          , CD_State                    = ISNULL( cd.State, '' )
          , CD_Zip                      = ISNULL( cd.Zip, '' )          
          , BAF_FirmName                = ISNULL( baf.FirmName, '' )
          , BAF_City                    = ISNULL( baf.City, '' )
          , BAF_State                   = ISNULL( baf.State, '' )
          , BA1_FirstName               = ISNULL( ba1.FirstName, '' )
          , BA1_LastName                = ISNULL( ba1.LastName, '' )
          , BA1_Email                   = ISNULL( ba1.Email, '' )
          , FA1_FirstName               = ISNULL( fa1.FirstName, '' )
          , FA1_LastName                = ISNULL( fa1.LastName, '' )
          , FA1_Phone                   = ISNULL( fa1.Phone, '' )
          , FA1_Email                   = ISNULL( fa1.Email, '' )
          , FA1_SaleDayAvailable        = ISNULL( fa1.SaleDayAvailable, '' )
          , FA1_SaleDayAttending        = ISNULL( fa1.SaleDayAttending, '' )
          , FA2_FirstName               = ISNULL( fa2.FirstName, '' )
          , FA2_LastName                = ISNULL( fa2.LastName, '' )
          , FA2_Phone                   = ISNULL( fa2.Phone, '' )
          , FA2_Email                   = ISNULL( fa2.Email, '' )
          , FA2_SaleDayAvailable        = ISNULL( fa2.SaleDayAvailable, '' )
          , FA2_SaleDayAttending        = ISNULL( fa2.SaleDayAttending, '' )
          , FA3_FirstName               = ISNULL( fa3.FirstName, '' )
          , FA3_LastName                = ISNULL( fa3.LastName, '' )
          , FA3_Phone                   = ISNULL( fa3.Phone, '' )
          , FA3_Email                   = ISNULL( fa3.Email, '' )
          , FA3_SaleDayAvailable        = ISNULL( fa3.SaleDayAvailable, '' )
          , FA3_SaleDayAttending        = ISNULL( fa3.SaleDayAttending, '' )
          , DSC_FirstName               = ISNULL( dsc.FirstName, '' )
          , DSC_LastName                = ISNULL( dsc.LastName, '' )
          , DSC_Email                   = ISNULL( dsc.Email, '' )
          , FNA_FirstName               = ISNULL( fna.FirstName, '' )
          , FNA_LastName                = ISNULL( fna.LastName, '' )
          , FNA_Phone                   = ISNULL( fna.Phone, '' )
          , FNA_Email                   = ISNULL( fna.Email, '' )
          , PFC_FirstName               = ISNULL( pfc.FirstName, '' )
          , PFC_LastName                = ISNULL( pfc.LastName, '' )
          , PFC_Title                   = ISNULL( pfc.Title, '' )
          , PFC_Email                   = ISNULL( pfc.Email, '' )
          , PFC_Phone                   = ISNULL( pfc.Phone, '' )
          , PDC_FirstName               = ISNULL( pdc.FirstName, '' )
          , PDC_LastName                = ISNULL( pdc.LastName, '' )
          , PDC_Email                   = ISNULL( pdc.Email, '' )
      FROM  dbo.Issue AS i
 LEFT JOIN  issueData               AS id  ON id.IssueID  = i.IssueID
 LEFT JOIN  clientData              AS cd  ON id.IssueID  = i.IssueID
 LEFT JOIN  bondAttorneyFirm        AS baf ON baf.IssueID = i.IssueID
 LEFT JOIN  bondAttorneyPrimary     AS ba1 ON ba1.IssueID = i.IssueID
 LEFT JOIN  primaryFA               AS fa1 ON fa1.IssueID = i.IssueID
 LEFT JOIN  secondaryFA             AS fa2 ON fa2.IssueID = fa1.IssueID
 LEFT JOIN  tertiaryFA              AS fa3 ON fa3.IssueID = fa1.IssueID
 LEFT JOIN  disclosureCoordinator   AS dsc ON dsc.IssueID = fa1.IssueID
 LEFT JOIN  financialAnalyst        AS fna ON fna.IssueID = fa1.IssueID
 LEFT JOIN  primaryFAContact        AS pfc ON pfc.IssueID = i.IssueID
 LEFT JOIN  primaryDCContact        AS pdc ON pdc.IssueID = i.IssueID
     WHERE  i.IssueID = @IssueID ;
