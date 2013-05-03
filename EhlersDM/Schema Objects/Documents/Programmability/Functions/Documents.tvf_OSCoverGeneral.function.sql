CREATE FUNCTION Documents.tvf_OSCoverGeneral ( @IssueID AS INT )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Documents.tvf_OSCoverGeneral
     Author:    Marty Schultz
    Purpose:    return OS Cover data for a given Issue

    revisor         date                description
    ---------       -----------         ----------------------------
    mschultz        2013-04-17          created

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
                  , SaleTime                = i.SaleTime
                  , MeetingDate             = im.MeetingDate
                  , MeetingTime             = im.MeetingTime
                  , OSPrintDate             = DATENAME(MONTH, i.OSPrintDate)+ ' ' + RIGHT(DATENAME(DAY, i.OSPrintDate), 2) + ', ' + DATENAME(YEAR, i.OSPrintDate)
                  , DatedDate               = i.DatedDate
                  , SettlementDate          = i.SettlementDate
                  , FirstInterestDate       = i.FirstInterestDate
                  , FirstInterestDatePlus6  = DATEADD(MONTH, 6, i.FirstInterestDate)
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
                  , GoodFaithAmount         = i.IssueAmount * i.GoodFaithPercent
                  , AllowTerm               = bp.AllowTerm
                  , AllowMaturityAdjustment = bp.AllowMaturityAdjustment
                  , AllowParAdjustment      = bp.AllowParAdjustment
                  , MaximumAdjustmentAmount = bp.MaximumAdjustmentAmount
                  , MinimumProposalPct      = bp.MinimumBidPercent
                  , MinimumProposal         = (bp.MinimumBidPercent / 100) * i.IssueAmount
                  , MaximumProposal         = (bp.MaximumBidPercent / 100) * i.IssueAmount
                  , CallDate                = ic.CallDate
                  , FirstCallableMaturity   = ic.FirstCallableMatDate
                  , TypeOfRedemption        = ic.CallTypeID
                  , NumberOfMaturities      = (SELECT COUNT(*) FROM Documents.vw_IssueMaturityAmounts WHERE IssueID = @IssueID)
                  , FirstMaturityDate       = (SELECT TOP 1 PaymentDate FROM Documents.vw_IssueMaturityAmounts WHERE IssueID = @IssueID ORDER BY PaymentDate ASC)
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.IssueRating         AS ir ON ir.IssueID = i.IssueID
         LEFT JOIN  dbo.IssueFee            AS f  ON f.IssueID  = i.IssueID AND f.FeeTypeID = 28 AND f.PaymentMethodID = 4
         LEFT JOIN  dbo.ARRABond            AS ab ON ab.IssueID = i.IssueID
        INNER JOIN  dbo.IssuePostBond       AS pb ON pb.IssueID = i.IssueID
         LEFT JOIN  dbo.IssueMeeting        AS im ON im.IssueID = i.IssueID AND im.MeetingPurposeID = 3
        INNER JOIN  dbo.BiddingParameter    AS bp ON bp.IssueID = i.IssueID
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
                  , Address1                = a.Address1
                  , Address2                = a.Address2
                  , Address3                = a.Address3
                  , City                    = a.City
                  , StateAbv                = a.State
                  , StateFull               = s.FullName
                  , Zip                     = a.Zip
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.Client              AS c  ON c.ClientID = i.ClientID
        INNER JOIN  dbo.ClientPrefix        AS cp ON cp.ClientPrefixID = c.ClientPrefixID
        INNER JOIN  dbo.JurisdictionType    AS jt ON jt.JurisdictionTypeID = c.JurisdictionTypeID
        INNER JOIN  dbo.GoverningBoard      AS gb ON gb.GoverningBoardID = c.GoverningBoardID
        INNER JOIN  dbo.ClientAddresses     AS ca ON ca.ClientID = c.ClientID
        INNER JOIN  dbo.Address             AS a  ON a.AddressID = ca.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = a.State
             WHERE  i.IssueID = @IssueID ) ,

            headElectedOfficial AS (
            SELECT  IssueID                 = i.IssueID
                  , FirstName               = con.FirstName
                  , LastName                = con.LastName
                  , Title                   = con.Title
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.Client              AS c   ON c.ClientID = i.ClientID
        INNER JOIN  dbo.ClientContacts      AS cc  ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactID = con.ContactID
        INNER JOIN  dbo.JobFunction         AS jf  ON jf.JobFunctionID = cjf.JobFunctionID
             WHERE  i.IssueID = @IssueID AND cjf.JobFunctionID = 16) ,

             Clerk AS (
            SELECT  IssueID                 = i.IssueID
                  , FirstName               = con.FirstName
                  , LastName                = con.LastName
                  , Title                   = con.Title
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.Client              AS c   ON c.ClientID = i.ClientID
        INNER JOIN  dbo.ClientContacts      AS cc  ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactID = con.ContactID
        INNER JOIN  dbo.JobFunction         AS jf  ON jf.JobFunctionID = cjf.JobFunctionID
             WHERE  i.IssueID = @IssueID AND cjf.JobFunctionID = 1) ,

             financePerson AS (
            SELECT  IssueID                 = i.IssueID
                  , FirstName               = con.FirstName
                  , LastName                = con.LastName
                  , Title                   = con.Title
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.Client              AS c   ON c.ClientID = i.ClientID
        INNER JOIN  dbo.ClientContacts      AS cc  ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactID = con.ContactID
        INNER JOIN  dbo.JobFunction         AS jf  ON jf.JobFunctionID = cjf.JobFunctionID
             WHERE  i.IssueID = @IssueID AND cjf.JobFunctionID = 3) ,

             headAdministrator AS (
            SELECT  IssueID                 = i.IssueID
                  , FirstName               = con.FirstName
                  , LastName                = con.LastName
                  , Title                   = con.Title
              FROM  dbo.Issue               AS i
        INNER JOIN  dbo.Client              AS c   ON c.ClientID = i.ClientID
        INNER JOIN  dbo.ClientContacts      AS cc  ON cc.ClientID = c.ClientID
        INNER JOIN  dbo.Contact             AS con ON con.ContactID = cc.ContactID
        INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactID = con.ContactID
        INNER JOIN  dbo.JobFunction         AS jf  ON jf.JobFunctionID = cjf.JobFunctionID
             WHERE  i.IssueID = @IssueID AND cjf.JobFunctionID = 2) ,

            bondAttorneyData AS (
            SELECT  IssueID          = isf.IssueID
                  , FirmID           = frm.FirmID
                  , FirmName         = frm.FirmName
                  , Address1         = adr.Address1
                  , Address2         = adr.Address2
                  , Address3         = adr.Address3
                  , City             = adr.City
                  , State            = adr.State
                  , StateFull        = s.FullName
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
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = adr.State
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 3 AND cjf.JobFunctionID = 30 AND ifc.Ordinal = 1 ) ,

            payingAgentData AS (
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
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = adr.State
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 14 ) ,

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
              FROM  dbo.IssueFirms          AS isf
        INNER JOIN  dbo.FirmCategories      AS fcs ON fcs.FirmCategoriesID = isf.FirmCategoriesID
        INNER JOIN  dbo.Firm                AS frm ON frm.FirmID = fcs.FirmID
        INNER JOIN  dbo.FirmAddresses       AS fma ON fma.FirmID = frm.FirmID
        INNER JOIN  dbo.Address             AS adr ON adr.AddressID = fma.AddressID
        INNER JOIN  dbo.States              AS s  ON s.Abbreviation = adr.State
             WHERE  isf.IssueID = @IssueID AND fcs.FirmCategoryID = 8 ) ,

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

    SELECT  IssueID                     = ISNULL( id.IssueID, '' )
          , IssueAmount                 = id.IssueAmount
          , IssueName                   = ISNULL( id.IssueName, '' )
          , SaleDate                    = ISNULL( id.SaleDate, '' )
          , SaleTime                    = ISNULL( CAST(id.SaleTime AS datetime), '' )
          , MeetingDate                 = ISNULL( id.MeetingDate, '' )
          , MeetingTime                 = ISNULL( CAST(id.MeetingTime AS datetime), '' )
          , OSPrintDate                 = ISNULL( id.OSPrintDate, '')
          , DatedDate                   = ISNULL( id.DatedDate, '')
          , SettlementDate              = ISNULL( id.SettlementDate, '')
          , FirstInterestDate           = ISNULL( id.FirstInterestDate, '')
          , FirstInterestDatePlus6      = ISNULL( id.FirstInterestDatePlus6, '')
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
          , GoodFaithAmount             = id.GoodFaithAmount
          , AllowTerm                   = ISNULL( id.AllowTerm, '')
          , AllowMaturityAdjustment     = ISNULL( id.AllowMaturityAdjustment, '')
          , AllowParAdjustment          = ISNULL( id.AllowParAdjustment, '')
          , MaximumAdjustmentAmount     = ISNULL( id.MaximumAdjustmentAmount, 0)
          , MinimumProposalPct          = id.MinimumProposalPct
          , MinimumProposal             = id.MinimumProposal
          , MaximumProposal             = id.MaximumProposal
          , CallDate                    = ISNULL( id.CallDate, '')
          , FirstCallableMaturity       = ISNULL( id.FirstCallableMaturity, '')
          , TypeOfRedemption            = ISNULL( id.TypeOfRedemption, 0)
          , NumberOfMaturities          = ISNULL( id.NumberOfMaturities, 0)
          , FirstMaturityDate           = ISNULL( id.FirstMaturityDate, '')
          , SchoolDistrictNumber        = ISNULL( cd.SchoolDistrictNumber, '' )
          , ClientName                  = ISNULL( cd.ClientName, '' )
          , ClientPrefix                = ISNULL( cd.ClientPrefix, '' )
          , JurisdictionType            = ISNULL( cd.JurisdictionType, '' )
          , JurisdictionTypeID          = ISNULL( cd.JurisdictionTypeID, '' )
          , GoverningBoard              = ISNULL( cd.GoverningBoard, '' )
          , Client_Address1             = ISNULL( cd.Address1, '' )
          , Client_Address2             = ISNULL( cd.Address2, '' )
          , Client_Address3             = ISNULL( cd.Address3, '' )
          , Client_City                 = ISNULL( cd.City, '' )
          , Client_StateAbv             = ISNULL( cd.StateAbv, '' )
          , Client_StateFull            = ISNULL( cd.StateFull, '' )
          , Client_Zip                  = ISNULL( cd.Zip, '' )
          , HEO_FirstName               = ISNULL( heo.FirstName, '' )
          , HEO_LastName                = ISNULL( heo.LastName, '' )
          , HEO_Title                   = ISNULL( heo.Title, '' )
          , CLK_FirstName               = ISNULL( clk.FirstName, '' )
          , CLK_LastName                = ISNULL( clk.LastName, '' )
          , CLK_Title                   = ISNULL( clk.Title, '' )
          , FP_FirstName                = ISNULL( fp.FirstName, '' )
          , FP_LastName                 = ISNULL( fp.LastName, '' )
          , FP_Title                    = ISNULL( fp.Title, '' )
          , HA_FirstName                = ISNULL( ha.FirstName, '' )
          , HA_LastName                 = ISNULL( ha.LastName, '' )
          , HA_Title                    = ISNULL( ha.Title, '' )
          , BA_FirmID                   = ISNULL( bad.FirmID, '' )
          , BA_FirmName                 = ISNULL( bad.FirmName, '' )
          , BA_Address1                 = ISNULL( bad.Address1, '' )
          , BA_Address2                 = ISNULL( bad.Address2, '' )
          , BA_Address3                 = ISNULL( bad.Address3, '' )
          , BA_City                     = ISNULL( bad.City, '' )
          , BA_State                    = ISNULL( bad.State, '' )
          , BA_StateFull                = ISNULL( bad.StateFull, '' )
          , BA_Zip                      = ISNULL( bad.Zip, '' )
          , BA_FirstName                = ISNULL( bad.FirstName, '' )
          , BA_LastName                 = ISNULL( bad.LastName, '' )
          , PA_FirmName                 = ISNULL( pad.FirmName, '' )
          , PA_Address1                 = ISNULL( pad.Address1, '' )
          , PA_Address2                 = ISNULL( pad.Address2, '' )
          , PA_Address3                 = ISNULL( pad.Address3, '' )
          , PA_City                     = ISNULL( pad.City, '' )
          , PA_State                    = ISNULL( pad.State, '' )
          , PA_StateFull                = ISNULL( pad.StateFull, '' )
          , PA_Zip                      = ISNULL( pad.Zip, '' )
          , EA_FirmName                 = ISNULL( ead.FirmName, '' )
          , EA_Address1                 = ISNULL( ead.Address1, '' )
          , EA_Address2                 = ISNULL( ead.Address2, '' )
          , EA_Address3                 = ISNULL( ead.Address3, '' )
          , EA_City                     = ISNULL( ead.City, '' )
          , EA_State                    = ISNULL( ead.State, '' )
          , EA_StateFull                = ISNULL( ead.StateFull, '' )
          , EA_Zip                      = ISNULL( ead.Zip, '' )
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
 LEFT JOIN  clientData              AS cd  ON cd.IssueID  = i.IssueID
 LEFT JOIN  headElectedOfficial     AS heo ON heo.IssueID = i.IssueID
 LEFT JOIN  Clerk                   AS clk ON clk.IssueID = i.IssueID
 LEFT JOIN  financePerson           AS fp  ON fp.IssueID  = i.IssueID
 LEFT JOIN  headAdministrator       AS ha  ON ha.IssueID  = i.IssueID
 LEFT JOIN  bondAttorneyData        AS bad ON bad.IssueID = i.IssueID
 LEFT JOIN  payingAgentData         AS pad ON pad.IssueID = i.IssueID
 LEFT JOIN  escrowAgentData         AS ead ON pad.IssueID = i.IssueID
 LEFT JOIN  county1                 AS c1  ON c1.IssueID  = i.IssueID
 LEFT JOIN  county2                 AS c2  ON c1.IssueID  = i.IssueID
 LEFT JOIN  county3                 AS c3  ON c1.IssueID  = i.IssueID
 LEFT JOIN  county4                 AS c4  ON c1.IssueID  = i.IssueID
 LEFT JOIN  county5                 AS c5  ON c1.IssueID  = i.IssueID
     WHERE  i.IssueID = @IssueID ;
