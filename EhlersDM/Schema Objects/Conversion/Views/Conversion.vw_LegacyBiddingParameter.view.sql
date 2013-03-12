CREATE VIEW Conversion.vw_LegacyBiddingParameter
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyBiddingParameters
     Author:    Chris Carson
    Purpose:    Legacy view of Issue -> BidddingParameter data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          updated for Issues Conversion
    

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  BiddingParameterID     = ISNULL( bdp.BiddingParameterID, 0 )
          , IssueID                = iss.IssueID
          , MinimumBid             = CASE ISNULL( iss.Amount, 0 )
                                          WHEN 0 THEN 0
                                          ELSE CAST( ISNULL( (iss.MinimumBid / iss.Amount * 100 ), 0 ) AS DECIMAL(6,2) )
                                     END
          , MaximumBid             = CASE ISNULL( iss.Amount, 0 )
                                          WHEN  0 THEN 0
                                          ELSE  CAST( ISNULL( (iss.MaximumBid / iss.Amount * 100 ), 0 ) AS DECIMAL(6,2) )
                                     END
          , AllowDecrease          = iss.AllowDecrease
          , TermBonds              = iss.TermBonds
          , AdjustIssue            = iss.AdjustIssue
          , PctInterest            = iss.PctInterest
          , MaximumDecrease        = iss.MaximumDecrease
          , DateDecrease           = iss.DateDecrease
          , AwardBasis             = CASE iss.AwardBasis WHEN 1 THEN 'TIC' ELSE 'NIC' END
          , InternetSale           = ISNULL( ibt.InternetBiddingTypeID, 2 )
          , ChangeDate             = ISNULL( iss.ChangeDate, GETDATE() )
          , ChangeBy               = ISNULL( NULLIF( iss.ChangeBy, '' ), 'processBidParam' )
      FROM  edata.Issues            AS iss
 LEFT JOIN  dbo.BiddingParameter    AS bdp ON bdp.IssueID     = iss.IssueID
 LEFT JOIN  dbo.InternetBiddingType AS ibt ON ibt.LegacyValue = iss.InternetSale 
     WHERE  EXISTS ( SELECT 1 FROM edata.Clients AS cli WHERE cli.ClientID = iss.IssueID ) ;
