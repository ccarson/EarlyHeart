CREATE VIEW Conversion.vw_ConvertedBiddingParameter
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedBiddingParameter
     Author:    Chris Carson
    Purpose:    Provides legacy view of Issue -> BiddingParameter data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
      WITH  IssueAmount AS (
            SELECT  IssueID
                  , IssueAmount
              FROM  dbo.Issue )

    SELECT  BiddingParameterID  = bp.BiddingParameterID
          , IssueID             = bp.IssueID
          , MinimumBid          = CAST( ISNULL( bp.MinimumBidPercent * ( a.IssueAmount / 100 ), 0 ) AS MONEY )
          , MaximumBid          = CAST( ISNULL( bp.MaximumBidPercent * ( a.IssueAmount / 100 ), 0 ) AS MONEY )
          , AllowDecrease       = bp.AllowDescendingRate
          , TermBonds           = bp.AllowTerm
          , AdjustIssue         = bp.AllowParAdjustment
          , PctInterest         = bp.AllowPercentIncrement
          , MaximumDecrease     = bp.DescMaxPct
          , DateDecrease        = bp.DescRateDate
          , AwardBasis          = CASE bp.AwardBasis WHEN 'TIC' THEN 1 ELSE 0 END
          , InternetSale        = ISNULL( NULLIF( i.LegacyValue, '' ), 'N' )
          , ChangeDate          = bp.ModifiedDate
          , ChangeBy            = bp.ModifiedUser
      FROM  dbo.BiddingParameter    AS bp
 LEFT JOIN  IssueAmount AS a
        ON  a.IssueID = bp.IssueID
 LEFT JOIN  dbo.InternetBiddingType AS i
        ON  i.InternetBiddingTypeID = bp.InternetBiddingTypeID ;
