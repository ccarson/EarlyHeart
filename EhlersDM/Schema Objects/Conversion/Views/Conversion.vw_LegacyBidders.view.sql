CREATE VIEW Conversion.vw_LegacyBidders
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyBidders
     Author:    Chris Carson
    Purpose:    consolidates and scrubs data from the edata.dbo.Bidders and edata.dbo.InternetBidders tables


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  IssueID       = b.IssueID
          , FirmID        = b.FirmID
          , PurchasePrice = CAST( ISNULL( b.PurchasePrice, 0 ) AS DECIMAL(15,2) )
          , TICPercent    = CAST( x.pctValue AS DECIMAL(12,8) )
          , NICPercent    = CAST( y.pctValue AS DECIMAL(12,8) )
          , NICAmount     = ISNULL(CAST( CAST( b.nic AS MONEY ) AS DECIMAL(15,2) ), 0 )
          , BABTICPercent = CAST( z.pctValue AS DECIMAL(12,8) )
          , HasWinningBID = CASE b.override WHEN 'u' THEN CAST( 1 AS BIT ) ELSE CAST( 0 AS BIT ) END
          , IsRecoveryAct = CAST( b.ynARRA AS BIT )
      FROM  edata.dbo.Bidders AS b
     CROSS  APPLY Conversion.tvf_transformPercentage ( tic )     AS x
     CROSS  APPLY Conversion.tvf_transformPercentage ( nicPct )  AS y
     CROSS  APPLY Conversion.tvf_transformPercentage ( ARRAtic ) AS z
        UNION  ALL
    SELECT  IssueID       = b.IssueID
          , FirmID        = b.FirmID
          , PurchasePrice = CAST( ISNULL( b.PurchasePrice, 0 ) AS DECIMAL(15,2) )
          , TICPercent    = CAST( x.pctValue AS DECIMAL(12,8) )
          , NICPercent    = CAST( y.pctValue AS DECIMAL(12,8) )
          , NICAmount     = ISNULL(CAST( CAST( b.nic AS MONEY ) AS DECIMAL(15,2) ), 0 )
          , BABTICPercent = CAST( 0 AS DECIMAL(12,8) )
          , HasWinningBID = CAST( 0 AS BIT )
          , IsRecoveryAct = CAST( 0 AS BIT )
      FROM  edata.dbo.InternetBidders AS b
     CROSS  APPLY Conversion.tvf_transformPercentage ( tic )    AS x
     CROSS  APPLY Conversion.tvf_transformPercentage ( nicPct ) AS y
     WHERE NOT EXISTS ( SELECT 1 FROM edata.dbo.bidders AS z
                         WHERE z.FirmID = b.FirmID AND z.IssueID = b.IssueID ) ;
