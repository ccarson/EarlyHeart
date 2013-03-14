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
    ccarson         ###DATE###          updated for Issues conversion, Bug # 41


    Function Arguments:
    @Source     VARCHAR(20)     'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  BiddingParameterID
              , IssueID           
              , MinimumBidPercent   = MinimumBid
              , MaximumBidPercent   = MaximumBid
              , AllowDecrease     
              , TermBonds         
              , AdjustIssue       
              , PctInterest       
              , MaximumDecrease   
              , DateDecrease        = CONVERT( VARCHAR(10) , ISNULL( DateDecrease , '1900-01-01' ) , 120 )
              , AwardBasis          
              , InternetSale        
          FROM  Conversion.vw_LegacyBiddingParameter
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
