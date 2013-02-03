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
        SELECT  BiddingParameterID    = ISNULL( bp.BiddingParameterID, 0 )
              , IssueID               = i.IssueID
              , MinimumBidPercent     = CASE ISNULL( i.Amount, 0 )
                                            WHEN 0 THEN 0
                                            ELSE CAST( ISNULL( ( i.MinimumBid / i.Amount * 100 ), 0 ) AS DECIMAL(6, 2) )
                                        END
              , MaximumBidPercent     = CASE ISNULL( i.Amount, 0 )
                                            WHEN 0 THEN 0
                                            ELSE CAST( ISNULL( ( i.MaximumBid / i.Amount * 100 ), 0 ) AS DECIMAL(6, 2) )
                                        END
              , AllowDecrease         = i.AllowDecrease
              , TermBonds             = i.TermBonds
              , AdjustIssue           = i.AdjustIssue
              , PctInterest           = i.PctInterest
              , MaximumDecrease       = i.MaximumDecrease
              , DateDecrease          = CONVERT( VARCHAR(10) , ISNULL( i.DateDecrease , '1900-01-01' ) , 120 )
              , AwardBasis            = CASE i.AwardBasis WHEN 1 THEN 'TIC' ELSE 'NIC' END
              , InternetSale          = ISNULL( ibt.InternetBiddingTypeID, 2 )
          FROM  edata.dbo.Issues        AS i
     LEFT JOIN  dbo.BiddingParameter    AS bp  ON  bp.IssueID = i.IssueID
     LEFT JOIN  dbo.InternetBiddingType AS ibt ON  ibt.LegacyValue = i.InternetSale
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  BiddingParameterID    = bp.BiddingParameterID
              , IssueID               = bp.IssueID
              , MinimumBidPercent     = bp.MinimumBidPercent
              , MaximumBidPercent     = bp.MaximumBidPercent
              , AllowDecrease         = bp.AllowDescendingRate
              , TermBonds             = bp.AllowTerm
              , AdjustIssue           = bp.AllowParAdjustment
              , PctInterest           = bp.AllowPercentIncrement
              , MaximumDecrease       = bp.DescMaxPct
              , DateDecrease          = CONVERT( VARCHAR(10), ISNULL( bp.DescRateDate , '1900-01-01' ), 120 )
              , AwardBasis            = bp.AwardBasis
              , InternetSale          = bp.InternetBiddingTypeID
          FROM  dbo.BiddingParameter AS bp
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
