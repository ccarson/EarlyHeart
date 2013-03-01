CREATE VIEW Conversion.vw_LegacyIssueFees
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyIssues
     Author:    Chris Carson
    Purpose:    shows IssueFees tables built from Legacy data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
  WITH  Fees AS ( 
        SELECT  IssueId
              , RatingMoody, RatingSP, RatingFitch
--              , Insurance, InsUW
              , Trustee, EscrowAgent
              , PayingAgent, PayingAgentSetup, BondCounsel, EscrowCPA, Ehlers
              , HomeCounty, County1, County2, County3, County4, County5
--              , Other1, Other2, Other3, Other1Name, Other2Name, Other3Name
--              , EhlersCDDiscount, ReimbursedBy
              , GrantStreet, Computer, SLGReorder
              , EscrowCPASLGReorder, BTSC, MiscRevenue, MiscExpense, SLGPlacement
--              , InvoiceYN
              , TermBondNotice, BBECIP 
          FROM  edata.Fees ) 
SELECT  IssueID, FeeType, Fee
  FROM  Fees AS f 
    UNPIVOT ( Fee FOR FeeType 
                   IN ( RatingMoody, RatingSP, RatingFitch
--                    , Insurance, InsUW
                      , Trustee, EscrowAgent
                      , PayingAgent, PayingAgentSetup, BondCounsel, EscrowCPA, Ehlers
                      , HomeCounty, County1, County2, County3, County4, County5
--                      , Other1, Other2, Other3, Other1Name, Other2Name, Other3Name
--                      , EhlersCDDiscount, ReimbursedBy
                      , GrantStreet, Computer, SLGReorder
                      , EscrowCPASLGReorder, BTSC, MiscRevenue, MiscExpense, SLGPlacement
--                    , InvoiceYN
                      , TermBondNotice, BBECIP ) ) AS x
 WHERE Fee <> 0 ;
