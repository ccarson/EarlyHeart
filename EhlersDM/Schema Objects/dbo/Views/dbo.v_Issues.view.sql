/*
CREATE VIEW dbo.v_Issues
AS
SELECT DISTINCT
                      '***Raw Issue Rec Follows***' AS Note0, iss.IssueID, iss.ClientID, iss.ProjectID, iss.IssueName, iss.IssueAmount, iss.IssueShortName,
                      iss.IssueShortNameOS AS DatedDate, iss.DatedDate AS IssueStatus, iss.IssueStatus AS ServiceID, iss.IssueType AS BondForm, iss.MethodOfSale AS TaxStatus,
                      iss.SecurityType AS AltMinimumTaxInd, iss.BondForm AS PrivateActBondInd, iss.InitialOfferingDocument AS Bond501C3Ind, iss.TaxStatus AS Cusip6,
                      iss.AltMinimumTaxInd AS BankQualifiedInd, iss.PrivateActBondInd AS SaleDate, iss.Bond501C3Ind AS SaleTime, iss.Cusip6 AS SettlementDate,
                      iss.BankQualifiedInd AS OSPrintDate, iss.CallableInd AS BondRatingInd, iss.SaleDate AS BondRatingSP, iss.SaleTime AS BondRatingMoodys,
                      iss.SettlementDate AS BondRatingFitch, iss.OSPrintDate AS RatingType, iss.BondRatingInd AS CreditEnhanceInd, iss.CreditEnhanceInd AS InterestPmtFreq,
                      iss.RatingType AS InterestCalcMethod, iss.BondRatingSPInd AS FirstInterestDate, iss.BondRatingMoodysInd AS DebtSvcYear,
                      iss.BondRatingFitchInd AS PurchasePrice, iss.OverrideRating AS TIC, iss.AnticipationCertificate AS BABTIC, iss.InterestPmtFreq AS AIC, iss.InterestCalcMethod AS NIC,
                       iss.InterestType AS BABNIC, iss.FirstInterestDate AS NICAmount, iss.DebtSvcYear AS ArbitrageYield, iss.PurchasePrice AS ElectionID, iss.TIC AS LastUpdateDate,
                      iss.BABTIC AS LastUpdateID, iss.AIC AS Note1, iss.NIC AS IssueStatus_Expand, iss.BABNIC AS PrimaryFAID, iss.NICAmount AS PrimaryFA_Expand,
                      iss.AccruedInterest AS SecondaryFAID, iss.ArbitrageYield AS SecondaryFA_Expand, iss.ElectionID AS ServiceName,
                      iss.IssueDebtSvcEqualInd AS ServiceCategory_Expand, iss.GoodFaithAmt AS Note2, iss.LastUpdateDate AS ClientName, iss.LastUpdateID AS ClientStatus_Expand,
                      '***Issue expanded***' AS Note3, sl1.DisplayValue AS ProjectName, ic.ContactID AS ProjectStatus_Expand, ee.FirstName + ' ' + ee.LastName AS ProjectPrimaryFAID,
                      ic1.ContactID AS ProjectPrimaryFA_Expand, ee1.FirstName + ' ' + ee1.LastName AS ProjectSecondaryFAID, Srvc.ServiceName AS ProjectSecondaryFA_Expand,
                      slsrvc.DisplayValue AS Note4, '***Issue Client***' AS EhlersFee, cl.ClientName AS FeeBasis, sl.DisplayValue AS Note5,
                      '***Issue Project if Sale Note***' AS VerbiageID, prj.ProjectName AS ShortDescription, sl2.DisplayValue AS LongDescription, prj.PrimaryFA AS Note6,
                      ee2.FirstName + ' ' + ee2.LastName AS SaleMtgID, prj.SecondaryFA AS SaleMtgPurpose, ee3.FirstName + ' ' + ee3.LastName AS SaleMtgType,
                      '***Ehlers Fee***' AS SaleMtgDate, ifee.IssueFeeAmt AS SaleMtgTime, slfee.DisplayValue AS SaleMtgAwardTime, '***Verbiage***' AS PreSaleMtgID,
                      issVrbg.IssueVerbiageID AS PreSaleMtgPurpose, issVrbg.IssueShortDescription AS PreSaleMtgType, issVrbg.IssueLongDescription AS PreSaleMtgDate,
                      '***Meeting stuff***' AS PreSaleMtgTime, imSale.IssueMeetingID AS PreSaleMtgAwardTime, imSale.MeetingPurpose AS ParamMtgID,
                      imSale.MeetingType AS ParamMtgPurpose, imSale.MeetingDate AS ParamMtgType, imSale.MeetingTime AS ParamMtgDate, imSale.AwardTime AS ParamMtgTime,
                      imPre.IssueMeetingID AS ParamMtgAwardTime, imPre.MeetingPurpose AS RatifyMtgID, imPre.MeetingType AS RatifyMtgPurpose,
                      imPre.MeetingDate AS RatifyMtgType, imPre.MeetingTime AS RatifyMtgDate, imPre.AwardTime AS RatifyMtgTime, imParam.IssueMeetingID AS RatifyMtgAwardTime,
                      imParam.MeetingPurpose AS CreditMtgID, imParam.MeetingType AS CreditMtgPurpose, imParam.MeetingDate AS CreditMtgType,
                      imParam.MeetingTime AS CreditMtgDate, imParam.AwardTime AS CreditMtgTime, imRtfy.IssueMeetingID AS CreditMtgAwardTime,
                      imRtfy.MeetingPurpose AS c501MtgID, imRtfy.MeetingType AS c501MtgPurpose, imRtfy.MeetingDate AS c501MtgType, imRtfy.MeetingTime AS c501MtgDate,
                      imRtfy.AwardTime AS c501MtgTime, imCrdt.IssueMeetingID AS c501MtgAwardTime, imCrdt.MeetingPurpose, imCrdt.MeetingType, imCrdt.MeetingDate,
                      imCrdt.MeetingTime, imCrdt.AwardTime, im501.IssueMeetingID, im501.MeetingPurpose AS Expr1, im501.MeetingType AS Expr2, im501.MeetingDate AS Expr3,
                      im501.MeetingTime AS Expr4, im501.AwardTime AS Expr5
FROM         dbo.Issues AS iss LEFT OUTER JOIN
                      dbo.StaticLists AS sl1 ON sl1.ListID = iss.IssueStatus LEFT OUTER JOIN
                      dbo.Clients AS cl ON cl.ClientID = iss.ClientID LEFT OUTER JOIN
                      dbo.StaticLists AS sl ON sl.ListID = cl.ClientStatus LEFT OUTER JOIN
                      dbo.IssueVerbiage AS issVrbg ON issVrbg.IssueID = iss.IssueID LEFT OUTER JOIN
                      dbo.IssueContacts AS ic ON ic.IssueID = iss.IssueID AND ic.EntityType = '024-001' AND ic.IssueContactRole = '032-003' LEFT OUTER JOIN
                      dbo.EhlersEmployees AS ee ON ee.ContactID = ic.ContactID LEFT OUTER JOIN
                      dbo.IssueContacts AS ic1 ON ic1.IssueID = iss.IssueID AND ic1.EntityType = '024-001' AND ic1.IssueContactRole = '032-004' LEFT OUTER JOIN
                      dbo.EhlersEmployees AS ee1 ON ee1.ContactID = ic1.ContactID LEFT OUTER JOIN
                      dbo.Projects AS prj ON prj.ProjectID = iss.ProjectID LEFT OUTER JOIN
                      dbo.StaticLists AS sl2 ON sl2.ListID = prj.ProjectStatus LEFT OUTER JOIN
                      dbo.EhlersEmployees AS ee2 ON ee2.ContactID = prj.PrimaryFA LEFT OUTER JOIN
                      dbo.EhlersEmployees AS ee3 ON ee3.ContactID = prj.SecondaryFA LEFT OUTER JOIN
                      dbo.Services AS Srvc ON Srvc.ServiceID = prj.ServiceID LEFT OUTER JOIN
                      dbo.StaticLists AS slsrvc ON slsrvc.ListID = Srvc.ServiceCategoryID LEFT OUTER JOIN
                      dbo.IssueFees AS ifee ON ifee.IssueID = iss.IssueID AND ifee.IssueFeeType = '027-001' LEFT OUTER JOIN
                      dbo.StaticLists AS slfee ON slfee.ListID = ifee.FeeBasis LEFT OUTER JOIN
                      dbo.IssueMeetings AS imSale ON imSale.IssueID = iss.IssueID AND imSale.MeetingPurpose = '016-006' LEFT OUTER JOIN
                      dbo.IssueMeetings AS imPre ON imPre.IssueID = iss.IssueID AND imPre.MeetingPurpose = '016-001' LEFT OUTER JOIN
                      dbo.IssueMeetings AS imParam ON imParam.IssueID = iss.IssueID AND imParam.MeetingPurpose = '016-004' LEFT OUTER JOIN
                      dbo.IssueMeetings AS imRtfy ON imRtfy.IssueID = iss.IssueID AND imRtfy.MeetingPurpose = '016-005' LEFT OUTER JOIN
                      dbo.IssueMeetings AS imCrdt ON imCrdt.IssueID = iss.IssueID AND imCrdt.MeetingPurpose = '016-002' LEFT OUTER JOIN
                      dbo.IssueMeetings AS im501 ON im501.IssueID = iss.IssueID AND im501.MeetingPurpose = '016-003'
*/
