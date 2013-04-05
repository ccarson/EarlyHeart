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
                  , IsAAC                   = i.IsAAC
                  , IsTAC                   = i.IsTAC
                  , SecurityType            = i.SecurityTypeID
                  , IfInsPurchaserPaid      = f.PaymentMethodID
                  , IssueType               = i.IssueTypeID
                  , ARRAType                = ab.ARRATypeID
                  , BondYear$               = pb.BondYear
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.IssueRating         AS ir ON ir.IssueID = i.IssueID
        INNER JOIN  dbo.IssueFee            AS f  ON f.IssueID  = i.IssueID 
         LEFT JOIN  dbo.ARRABond            AS ab ON ab.IssueID = i.IssueID 
        INNER JOIN  dbo.IssuePostBond       AS pb ON pb.IssueID = i.IssueID       
             WHERE  i.IssueID = @IssueID  AND f.FeeTypeID = 28 AND f.PaymentMethodID = 4) ,
             
            refundingData AS (
            SELECT  IssueID = @IssueID, isRefunding = CASE COUNT(*) WHEN 0 THEN 0 ELSE 1 END
              FROM  dbo.Issue AS i
             WHERE  i.IssueID = @IssueID AND
                    EXISTS ( SELECT 1 FROM dbo.Purpose p WHERE p.IssueID = i.IssueID AND p.FinanceTypeID IN (1,4,5,6,7,8,9,10,11,12,13,14)) ) ,
                    
            moodyRating AS (
            SELECT  TOP 1 IssueID           = i.IssueID
                  , Rating                  = r.Value
              FROM  dbo.Issue               AS i
        INNER JOIN  Client                  AS c    ON  c.ClientID = i.ClientID
        INNER JOIN  ClientRating            AS cr   ON  cr.ClientID = c.ClientID
        INNER JOIN  Rating                  AS r    ON  r.RatingID = cr.RatingID
             WHERE  i.IssueID = @IssueID AND r.RatingAgency = 'Moody' AND cr.RatingTypeID = 5
          ORDER BY  cr.RatedDate DESC ) ,
          
            spRating AS (
            SELECT  TOP 1 IssueID           = i.IssueID
                  , Rating                  = r.Value
              FROM  dbo.Issue               AS i
        INNER JOIN  Client                  AS c    ON  c.ClientID = i.ClientID
        INNER JOIN  ClientRating            AS cr   ON  cr.ClientID = c.ClientID
        INNER JOIN  Rating                  AS r    ON  r.RatingID = cr.RatingID
             WHERE  i.IssueID = @IssueID AND r.RatingAgency = 'StandardPoor' AND cr.RatingTypeID = 5
          ORDER BY  cr.RatedDate DESC ) ,
          
       fitchRating AS (
            SELECT  TOP 1 IssueID           = i.IssueID
                  , Rating                  = r.Value
              FROM  dbo.Issue               AS i
        INNER JOIN  Client                  AS c    ON  c.ClientID = i.ClientID
        INNER JOIN  ClientRating            AS cr   ON  cr.ClientID = c.ClientID
        INNER JOIN  Rating                  AS r    ON  r.RatingID = cr.RatingID
             WHERE  i.IssueID = @IssueID AND r.RatingAgency = 'Fitch' AND cr.RatingTypeID = 5
          ORDER BY  cr.RatedDate DESC ) ,           
            
            clientData AS (
            SELECT  IssueID                 = i.IssueID
                  , SchoolDistrictNumber    = c.SchoolDistrictNumber
                  , ClientName              = c.ClientName
                  , ClientPrefix            = cp.Value
                  , JurisdictionType        = jt.Value
                  , GoverningBoard          = gb.Value
                  , CapitalLoanDistrict     = c.CapitalLoanDistrict
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
          
            bondAttorneyData AS (
            SELECT  IssueID          = isf.IssueID
                  , IssueFirmsID     = isf.IssueFirmsID
                  , FirmName         = frm.FirmName
                  , Address1         = adr.Address1
                  , Address2         = adr.Address2
                  , Address3         = adr.Address3          
                  , City             = adr.City
                  , State            = adr.State
                  , Zip              = adr.Zip
                  , FirstName        = con.FirstName
                  , LastName         = con.LastName
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
        INNER JOIN  dbo.IssueFirmsContacts  AS ifc ON ifc.IssueFirmsID = isf.IssueFirmsID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactJobFunctionsID = ifc.ContactJobFunctionsID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cjf.ContactID
             WHERE  isf.IssueID = 38129 AND fcs.FirmCategoryID = 3 AND cjf.JobFunctionID = 30 AND ifc.Ordinal = 1 ) ,

            primaryFA AS (
            SELECT  IssueID          = i.IssueID
                  , FirstName        = e.FirstName
                  , LastName         = e.LastName
                  , Phone            = e.Phone
              FROM  dbo.EhlersEmployee          AS e
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS g ON g.EhlersEmployeeID = e.EhlersEmployeeID
        INNER JOIN  dbo.IssueEhlersEmployees    AS i ON i.EhlersEmployeeJobGroupsID = g.EhlersEmployeeJobGroupsID
             WHERE  i.IssueID = @IssueID AND g.EhlersJobGroupID = 3 AND i.Ordinal = 1 ) ,

            disclosureCoordinator AS (
            SELECT  IssueID     = i.IssueID
                  , FirstName   = e.FirstName
                  , LastName    = e.LastName
                  , Email       = e.Email
                  , Title       = e.JobTitle
              FROM  dbo.EhlersEmployee          AS e
        INNER JOIN  dbo.EhlersEmployeeJobGroups AS g ON g.EhlersEmployeeID = e.EhlersEmployeeID
        INNER JOIN  dbo.IssueEhlersEmployees    AS i ON i.EhlersEmployeeJobGroupsID = g.EhlersEmployeeJobGroupsID
             WHERE  i.IssueID = @IssueID AND g.EhlersJobGroupID = 7 AND i.Ordinal = 1 ) ,

            primaryDCContact AS (
            SELECT  IssueID          = i.IssueID
                  , FirstName        = c.FirstName
                  , LastName         = c.LastName
                  , Email            = c.Email
              FROM  dbo.IssueClientsContacts    AS i
        INNER JOIN  dbo.ClientContacts          AS cc ON cc.ClientContactsID = i.ClientContactsID
        INNER JOIN  dbo.Contact                 AS c  ON c.ContactID = cc.ContactID
             WHERE  i.IssueID = @IssueID AND i.ContactRole = 'OS' AND i.Ordinal = 1 ) ,
             
            underwriterData AS (
            SELECT  IssueID          = isf.IssueID
                  , IssueFirmsID     = isf.IssueFirmsID
                  , FirmName         = frm.FirmName
                  , Address1         = adr.Address1
                  , Address2         = adr.Address2
                  , Address3         = adr.Address3          
                  , City             = adr.City
                  , State            = adr.State
                  , Zip              = adr.Zip
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 19 ) ,
             
            county1 AS (
            SELECT  IssueID          = @IssueID            
                  , ClientName       = c.ClientName
                  , Address1         = a.Address1
                  , Address2         = a.Address2
                  , Address3         = a.Address3          
                  , City             = a.City
                  , State            = a.State
                  , Zip              = a.Zip 
                  , FirstName        = cn.FirstName
                  , LastName         = cn.LastName
              FROM  dbo.Client              AS c  
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.ClientContacts      AS cc ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS cn ON cn.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS jf ON jf.ContactID = cn.ContactID
             WHERE  jf.JobFunctionID = 68 AND c.ClientID =
                    (           
                        SELECT  co.OverlapClientID
                          FROM  dbo.Issue           AS i
                    INNER JOIN  dbo.Client          AS c  ON c.ClientID = i.ClientID
                    INNER JOIN  dbo.ClientOverlap   AS co ON co.ClientID = c.ClientID
                         WHERE  i.IssueID = @IssueID    AND co.Ordinal = 1
                    )) ,
                    
            county2 AS (
            SELECT  IssueID          = @IssueID            
                  , ClientName       = c.ClientName
                  , Address1         = a.Address1
                  , Address2         = a.Address2
                  , Address3         = a.Address3          
                  , City             = a.City
                  , State            = a.State
                  , Zip              = a.Zip 
                  , FirstName        = cn.FirstName
                  , LastName         = cn.LastName
              FROM  dbo.Client              AS c  
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.ClientContacts      AS cc ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS cn ON cn.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS jf ON jf.ContactID = cn.ContactID
             WHERE  jf.JobFunctionID = 68 AND c.ClientID =
                    (           
                        SELECT  co.OverlapClientID
                          FROM  dbo.Issue           AS i
                    INNER JOIN  dbo.Client          AS c  ON c.ClientID = i.ClientID
                    INNER JOIN  dbo.ClientOverlap   AS co ON co.ClientID = c.ClientID
                         WHERE  i.IssueID = @IssueID    AND co.Ordinal = 2
                    )) ,
            
            county3 AS (
            SELECT  IssueID          = @IssueID            
                  , ClientName       = c.ClientName
                  , Address1         = a.Address1
                  , Address2         = a.Address2
                  , Address3         = a.Address3          
                  , City             = a.City
                  , State            = a.State
                  , Zip              = a.Zip 
                  , FirstName        = cn.FirstName
                  , LastName         = cn.LastName
              FROM  dbo.Client              AS c  
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.ClientContacts      AS cc ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS cn ON cn.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS jf ON jf.ContactID = cn.ContactID
             WHERE  jf.JobFunctionID = 68 AND c.ClientID =
                    (           
                        SELECT  co.OverlapClientID
                          FROM  dbo.Issue           AS i
                    INNER JOIN  dbo.Client          AS c  ON c.ClientID = i.ClientID
                    INNER JOIN  dbo.ClientOverlap   AS co ON co.ClientID = c.ClientID
                         WHERE  i.IssueID = @IssueID    AND co.Ordinal = 3
                    )) ,
                    
            county4 AS (
            SELECT  IssueID          = @IssueID            
                  , ClientName       = c.ClientName
                  , Address1         = a.Address1
                  , Address2         = a.Address2
                  , Address3         = a.Address3          
                  , City             = a.City
                  , State            = a.State
                  , Zip              = a.Zip 
                  , FirstName        = cn.FirstName
                  , LastName         = cn.LastName
              FROM  dbo.Client              AS c  
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.ClientContacts      AS cc ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS cn ON cn.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS jf ON jf.ContactID = cn.ContactID
             WHERE  jf.JobFunctionID = 68 AND c.ClientID =
                    (           
                        SELECT  co.OverlapClientID
                          FROM  dbo.Issue           AS i
                    INNER JOIN  dbo.Client          AS c  ON c.ClientID = i.ClientID
                    INNER JOIN  dbo.ClientOverlap   AS co ON co.ClientID = c.ClientID
                         WHERE  i.IssueID = @IssueID    AND co.Ordinal = 4
                    )) ,
                    
            county5 AS (
            SELECT  IssueID          = @IssueID            
                  , ClientName       = c.ClientName
                  , Address1         = a.Address1
                  , Address2         = a.Address2
                  , Address3         = a.Address3          
                  , City             = a.City
                  , State            = a.State
                  , Zip              = a.Zip 
                  , FirstName        = cn.FirstName
                  , LastName         = cn.LastName
              FROM  dbo.Client              AS c  
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.ClientContacts      AS cc ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS cn ON cn.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS jf ON jf.ContactID = cn.ContactID
             WHERE  jf.JobFunctionID = 68 AND c.ClientID =
                    (           
                        SELECT  co.OverlapClientID
                          FROM  dbo.Issue           AS i
                    INNER JOIN  dbo.Client          AS c  ON c.ClientID = i.ClientID
                    INNER JOIN  dbo.ClientOverlap   AS co ON co.ClientID = c.ClientID
                         WHERE  i.IssueID = @IssueID    AND co.Ordinal = 5
                    )) 

    SELECT  ID_IssueID                  = ISNULL( id.IssueID, '' )
          , ID_IssueAmount              = id.IssueAmount
          , ID_IssueName                = ISNULL( id.IssueName, '' )
          , ID_SaleDate                 = ISNULL( id.SaleDate, '' )
          , ID_IssueShortNameOS         = ISNULL( id.IssueShortNameOS, '' )
          , ID_MoodyCreditEnhanced      = ISNULL( id.MoodyCreditEnhanced, '')
          , ID_SPCreditEnhanced         = ISNULL( id.SPCreditEnhanced, '')
          , ID_IsNotRatedCreditEnhanced = ISNULL( id.IsNotRatedCreditEnhanced, 0)
          , ID_IfInsPurchaserPaid       = ISNULL( id.IfInsPurchaserPaid, '')
          , ID_IssueType                = ISNULL( id.IssueType, '')
          , ID_ARRAType                 = ISNULL( id.ARRAType, '')
          , ID_BondYear$                = ISNULL( id.BondYear$, 0)
          , MR_MoodyRating              = ISNULL( mr.Rating, '')
          , SPR_SPRating                = ISNULL( spr.Rating, '')
          , FR_FitchRating              = ISNULL( fr.Rating, '')
          , IR_IfRefunding              = ir.isRefunding
          , CD_SchoolDistrictNumber     = ISNULL( cd.SchoolDistrictNumber, '' )
          , CD_ClientName               = ISNULL( cd.ClientName, '' )
          , CD_ClientPrefix             = ISNULL( cd.ClientPrefix, '' )
          , CD_JurisdictionType         = ISNULL( cd.JurisdictionType, '' )
          , CD_GoverningBoard           = ISNULL( cd.GoverningBoard, '' )
          , CD_CapitalLoanDistrict      = ISNULL( cd.CapitalLoanDistrict, '' )
          , CD_Address1                 = ISNULL( cd.Address1, '' )
          , CD_Address2                 = ISNULL( cd.Address2, '' )
          , CD_Address3                 = ISNULL( cd.Address3, '' )
          , CD_City                     = ISNULL( cd.City, '' )
          , CD_State                    = ISNULL( cd.State, '' )
          , CD_Zip                      = ISNULL( cd.Zip, '' )          
          , BAD_FirmName                = ISNULL( bad.FirmName, '' )
          , BAD_Address1                = ISNULL( bad.Address1, '' )
          , BAD_Address2                = ISNULL( bad.Address2, '' )
          , BAD_Address3                = ISNULL( bad.Address3, '' )
          , BAD_City                    = ISNULL( bad.City, '' )
          , BAD_State                   = ISNULL( bad.State, '' )
          , BAD_Zip                     = ISNULL( bad.Zip, '' )
          , BAD_FirstName               = ISNULL( bad.FirstName, '' )
          , BAD_LastName                = ISNULL( bad.LastName, '' )
          , FA1_FirstName               = ISNULL( fa1.FirstName, '' )
          , FA1_LastName                = ISNULL( fa1.LastName, '' )
          , FA1_Phone                   = ISNULL( fa1.Phone, '' )
          , DSC_FirstName               = ISNULL( dsc.FirstName, '' )
          , DSC_LastName                = ISNULL( dsc.LastName, '' )
          , DSC_Email                   = ISNULL( dsc.Email, '' )
          , DSC_Title                   = ISNULL( dsc.Title, '' )
          , PDC_FirstName               = ISNULL( pdc.FirstName, '' )
          , PDC_LastName                = ISNULL( pdc.LastName, '' )
          , PDC_Email                   = ISNULL( pdc.Email, '' )
          , UWD_FirmName                = ISNULL( uwd.FirmName, '' )
          , UWD_Address1                = ISNULL( uwd.Address1, '' )
          , UWD_Address2                = ISNULL( uwd.Address2, '' )
          , UWD_Address3                = ISNULL( uwd.Address3, '' )
          , UWD_City                    = ISNULL( uwd.City, '' )
          , UWD_State                   = ISNULL( uwd.State, '' )
          , UWD_Zip                     = ISNULL( uwd.Zip, '' )
          , C1_ClientName               = ISNULL( c1.ClientName, '' )
          , C1_Address1                 = ISNULL( c1.Address1, '' )
          , C1_Address2                 = ISNULL( c1.Address2, '' )
          , C1_Address3                 = ISNULL( c1.Address3, '' )
          , C1_City                     = ISNULL( c1.City, '' )
          , C1_State                    = ISNULL( c1.State, '' )
          , C1_Zip                      = ISNULL( c1.Zip, '' )
          , C1_FirstName                = ISNULL( c1.FirstName, '' )
          , C1_LastName                 = ISNULL( c1.LastName, '' )
          , C2_ClientName               = ISNULL( c2.ClientName, '' )
          , C2_Address1                 = ISNULL( c2.Address1, '' )
          , C2_Address2                 = ISNULL( c2.Address2, '' )
          , C2_Address3                 = ISNULL( c2.Address3, '' )
          , C2_City                     = ISNULL( c2.City, '' )
          , C2_State                    = ISNULL( c2.State, '' )
          , C2_Zip                      = ISNULL( c2.Zip, '' )
          , C2_FirstName                = ISNULL( c2.FirstName, '' )
          , C2_LastName                 = ISNULL( c2.LastName, '' )
          , C3_ClientName               = ISNULL( c3.ClientName, '' )
          , C3_Address1                 = ISNULL( c3.Address1, '' )
          , C3_Address2                 = ISNULL( c3.Address2, '' )
          , C3_Address3                 = ISNULL( c3.Address3, '' )
          , C3_City                     = ISNULL( c3.City, '' )
          , C3_State                    = ISNULL( c3.State, '' )
          , C3_Zip                      = ISNULL( c3.Zip, '' )
          , C3_FirstName                = ISNULL( c3.FirstName, '' )
          , C3_LastName                 = ISNULL( c3.LastName, '' )
          , C4_ClientName               = ISNULL( c4.ClientName, '' )
          , C4_Address1                 = ISNULL( c4.Address1, '' )
          , C4_Address2                 = ISNULL( c4.Address2, '' )
          , C4_Address3                 = ISNULL( c4.Address3, '' )
          , C4_City                     = ISNULL( c4.City, '' )
          , C4_State                    = ISNULL( c4.State, '' )
          , C4_Zip                      = ISNULL( c4.Zip, '' )
          , C4_FirstName                = ISNULL( c4.FirstName, '' )
          , C4_LastName                 = ISNULL( c4.LastName, '' )
          , C5_ClientName               = ISNULL( c5.ClientName, '' )
          , C5_Address1                 = ISNULL( c5.Address1, '' )
          , C5_Address2                 = ISNULL( c5.Address2, '' )
          , C5_Address3                 = ISNULL( c5.Address3, '' )
          , C5_City                     = ISNULL( c5.City, '' )
          , C5_State                    = ISNULL( c5.State, '' )
          , C5_Zip                      = ISNULL( c5.Zip, '' )
          , C5_FirstName                = ISNULL( c5.FirstName, '' )
          , C5_LastName                 = ISNULL( c5.LastName, '' )
      FROM  dbo.Issue AS i
 LEFT JOIN  issueData               AS id  ON id.IssueID  = i.IssueID
 LEFT JOIN  refundingData           AS ir  ON ir.IssueID  = i.IssueID
 LEFT JOIN  moodyRating             AS mr  ON mr.IssueID  = i.IssueID
 LEFT JOIN  spRating                AS spr ON spr.IssueID = i.IssueID
 LEFT JOIN  fitchRating             AS fr  ON fr.IssueID  = i.IssueID
 LEFT JOIN  clientData              AS cd  ON cd.IssueID  = i.IssueID
 LEFT JOIN  bondAttorneyData        AS bad ON bad.IssueID = i.IssueID
 LEFT JOIN  primaryFA               AS fa1 ON fa1.IssueID = i.IssueID
 LEFT JOIN  disclosureCoordinator   AS dsc ON dsc.IssueID = i.IssueID
 LEFT JOIN  primaryDCContact        AS pdc ON pdc.IssueID = i.IssueID
 LEFT JOIN  underwriterData         AS uwd ON uwd.IssueID = i.IssueID
 LEFT JOIN  county1                 AS c1  ON c1.IssueID  = i.IssueID
 LEFT JOIN  county2                 AS c2  ON c1.IssueID  = i.IssueID
 LEFT JOIN  county3                 AS c3  ON c1.IssueID  = i.IssueID
 LEFT JOIN  county4                 AS c4  ON c1.IssueID  = i.IssueID
 LEFT JOIN  county5                 AS c5  ON c1.IssueID  = i.IssueID
     WHERE  i.IssueID = @IssueID ;
