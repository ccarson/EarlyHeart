CREATE VIEW Conversion.vw_LegacyBiddingParameter
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyBiddingParameters
     Author:    Chris Carson
    Purpose:    Legacy view of Issue -> BidddingParameter data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  BiddingParameterID     = ISNULL( bp.BiddingParameterID, 0 )
          , IssueID                = i.IssueID
          , MinimumBid             = CASE ISNULL( i.Amount, 0 )
                                          WHEN 0 THEN 0
                                          ELSE CAST( ISNULL( (i.MinimumBid / i.Amount * 100 ), 0 ) AS DECIMAL(6,2) )
                                     END
          , MaximumBid             = CASE ISNULL( i.Amount, 0 )
                                          WHEN  0 THEN 0
                                          ELSE  CAST( ISNULL( (i.MaximumBid / i.Amount * 100 ), 0 ) AS DECIMAL(6,2) )
                                     END
          , AllowDecrease          = i.AllowDecrease
          , TermBonds              = i.TermBonds
          , AdjustIssue            = i.AdjustIssue
          , PctInterest            = i.PctInterest
          , MaximumDecrease        = i.MaximumDecrease
          , DateDecrease           = i.DateDecrease
          , AwardBasis             = CASE i.AwardBasis WHEN 1 THEN 'TIC' ELSE 'NIC' END
          , InternetSale           = ISNULL( ibt.InternetBiddingTypeID, 2 )
          , ChangeDate             = ISNULL( i.ChangeDate, GETDATE() )
          , ChangeBy               = ISNULL( NULLIF( i.ChangeBy, '' ), 'processIssues' )
      FROM  edata.dbo.Issues AS i
 LEFT JOIN  dbo.BiddingParameter AS bp ON bp.IssueID = i.IssueID
 LEFT JOIN  dbo.InternetBiddingType AS ibt
        ON  ibt.LegacyValue = i.InternetSale ;
