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
      WITH  fees AS (
            SELECT  IssueID
                , [Rating Agent - Moody]                  = RatingMoody
                , [Rating Agent - S & P]                  = RatingSP
                , [Rating Agent - Fitch]                  = RatingFitch
                , [Trustee - Initial]                     = Trustee
                , [Escrow Agent]                          = EscrowAgent
                , [Paying Agent - Initial]                = PayingAgentSetup
                , [Paying Agent - 1st Year - Prorated]    = PayingAgent
                , [Bond Attorney]                         = BondCounsel
                , [Escrow CPA]                            = EscrowCPA
                , [Base]                                  = Ehlers
                , [Home County]                           = HomeCounty
                , [County 1]                              = County1
                , [County 2]                              = County2
                , [County 3]                              = County3
                , [County 4]                              = County4
                , [County 5]                              = County5
                , [Miscellaneous Expense]                 = MiscExpense
                , [SLGPlacement]                          = SLGPlacement
                , [Other 1]                               = Other1
                , [Other 2]                               = Other2
                , [Other 3]                               = Other3
                , GrantStreet
                , Computer
                , SLGReorder
                , EscrowCPASLGReorder
                , BTSC
                , MiscRevenue
                , TermBondNotice
                , BBECIP
            FROM  edata.Fees ) , 
        
        
            unpivotFees AS ( 
            SELECT  IssueID, FeeType, Fee
            FROM  Fees UNPIVOT ( 
                    Fee FOR FeeType IN ( 
                        [Rating Agent - Moody], [Rating Agent - S & P], [Rating Agent - Fitch], [Trustee - Initial]
                            , [Escrow Agent], [Paying Agent - Initial], [Paying Agent - 1st Year - Prorated], [Bond Attorney]
                            , [Escrow CPA], [Base], [Home County], [County 1], [County 2], [County 3], [County 4], [County 5]
                            , [Miscellaneous Expense], [SLGPlacement], [Other 1], [Other 2], [Other 3], GrantStreet, Computer
                            , SLGReorder, EscrowCPASLGReorder, BTSC, MiscRevenue, TermBondNotice, BBECIP ) ) AS Fees
            WHERE Fee <> 0 ) , 
            
            
            otherFeesText AS ( 
            SELECT  IssueID
                , [Other 1]   = Other1Name
                , [Other 2]   = Other2Name
                , [Other 3]   = Other3Name 
            FROM  edata.Fees
            WHERE  Other1 <> 0 OR Other2<> 0 OR Other3<> 0 ) , 
            
            
            unpivotFeesText AS (
            SELECT IssueID, FeeType, FeeText
            FROM otherFeesText UNPIVOT ( FeeText FOR FeeType IN ( [Other 1], [Other 2], [Other 3] )  ) AS otherFeesText ) 
          
    SELECT  IssueID     = upf.IssueID
          , FeeTypeID   = ISNULL( fet.FeeTypeID, 0 )
          , FeeType     = upf.FeeType
          , Fee         = upf.Fee
          , FeeText     = ISNULL( upt.FeeText, '' )
      FROM  unpivotFees     AS upf
 LEFT JOIN  dbo.FeeType     AS fet ON fet.Value = upf.FeeType
 LEFT JOIN  unpivotFeesText AS upt ON upt.IssueID = upf.IssueID AND upt.FeeType = upf.FeeType ;