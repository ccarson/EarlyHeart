CREATE FUNCTION Conversion.tvf_BiddingParameterChecksum ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************
            
   Function:    Conversion.tvf_BiddingParameterChecksum
     Author:    Chris Carson
    Purpose:    Computes checksums for BiddingParameter table views


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created


    Function Arguments:
    @Source     VARCHAR(20)     'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  BiddingParameterID    = ISNULL( bdp.BiddingParameterID, 0 )
              , IssueID               = iss.IssueID
              , MinimumBidPercent     = CASE ISNULL( iss.Amount, 0 )
                                            WHEN 0 THEN 0
                                            ELSE CAST( ISNULL( ( iss.MinimumBid / iss.Amount * 100 ), 0 ) AS DECIMAL(6, 2) )
                                        END
              , MaximumBidPercent     = CASE ISNULL( iss.Amount, 0 )
                                            WHEN 0 THEN 0
                                            ELSE CAST( ISNULL( ( iss.MaximumBid / iss.Amount * 100 ), 0 ) AS DECIMAL(6, 2) )
                                        END
              , AllowDecrease         = iss.AllowDecrease
              , TermBonds             = iss.TermBonds
              , AdjustIssue           = iss.AdjustIssue
              , PctInterest           = iss.PctInterest
              , MaximumDecrease       = iss.MaximumDecrease
              , DateDecrease          = CONVERT( VARCHAR(10) , ISNULL( iss.DateDecrease , '1900-01-01' ) , 120 )
              , AwardBasis            = CASE iss.AwardBasis WHEN 1 THEN 'TIC' ELSE 'NIC' END
              , InternetSale          = ISNULL( ibt.InternetBiddingTypeID, 2 )
          FROM  edata.Issues            AS iss
     LEFT JOIN  dbo.BiddingParameter    AS bdp ON bdp.IssueID = iss.IssueID
     LEFT JOIN  dbo.InternetBiddingType AS ibt ON ibt.LegacyValue = iss.InternetSale
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  BiddingParameterID    = bdp.BiddingParameterID
              , IssueID               = bdp.IssueID
              , MinimumBidPercent     = bdp.MinimumBidPercent
              , MaximumBidPercent     = bdp.MaximumBidPercent
              , AllowDecrease         = bdp.AllowDescendingRate
              , TermBonds             = bdp.AllowTerm
              , AdjustIssue           = bdp.AllowParAdjustment
              , PctInterest           = bdp.AllowPercentIncrement
              , MaximumDecrease       = bdp.DescMaxPct
              , DateDecrease          = CONVERT( VARCHAR(10), ISNULL( bdp.DescRateDate , '1900-01-01' ), 120 )
              , AwardBasis            = bdp.AwardBasis
              , InternetSale          = bdp.InternetBiddingTypeID
          FROM  dbo.BiddingParameter AS bdp
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  BiddingParameterID, IssueID, MinimumBidPercent, MaximumBidPercent
                    , AllowDecrease, TermBonds, AdjustIssue, PctInterest, MaximumDecrease
                    , DateDecrease, AwardBasis, InternetSale
          FROM  legacy
            UNION ALL
        SELECT  BiddingParameterID, IssueID, MinimumBidPercent, MaximumBidPercent
                    , AllowDecrease, TermBonds, AdjustIssue, PctInterest, MaximumDecrease
                    , DateDecrease, AwardBasis, InternetSale
          FROM  converted )

SELECT  BiddingParameterID       = BiddingParameterID
      , IssueID                  = IssueID
      , BiddingParameterChecksum = CAST( HASHBYTES( 'md5', CAST( BiddingParameterID AS VARCHAR(20) )
                                                         + CAST( IssueID            AS VARCHAR(20) )
                                                         + CAST( MinimumBidPercent  AS VARCHAR(20) )
                                                         + CAST( MaximumBidPercent  AS VARCHAR(20) )
                                                         + CAST( AllowDecrease      AS VARCHAR(20) )
                                                         + CAST( TermBonds          AS VARCHAR(20) )
                                                         + CAST( AdjustIssue        AS VARCHAR(20) )
                                                         + CAST( PctInterest        AS VARCHAR(20) )
                                                         + CAST( MaximumDecrease    AS VARCHAR(20) )
                                                         + DateDecrease
                                                         + AwardBasis
                                                         + CAST( InternetSale AS VARCHAR(20) ) ) AS VARBINARY(128) )
  FROM  inputData ;
