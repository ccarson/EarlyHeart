CREATE PROCEDURE Conversion.processBiddingHistories
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processBiddingHistories
     Author:    Chris Carson
    Purpose:    converts legacy Bidder and BidMaturities data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Compute CHECKSUM for each view of data used in proc
    2)  Stop processing when the legacy and converted data are equivalent
    3)  Load legacy data into temp storage
    4)  Update BidMaturity temp data with new keys for Bidder
    5)  Delete data from current converted tables
    6)  Reload converted tables with extracted legacy data
    7) Print control totals


************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @BidderRecords                  AS INT = 0
          , @BidMaturityRecords             AS INT = 0
          , @IssueMaturityRecords           AS INT = 0
          , @rc                             AS INT = 0
          , @vw_LegacyBiddersChecksum       AS INT = 0
          , @vw_BidderChecksum              AS INT = 0
          , @vw_LegacyBidAnnual             AS INT = 0
          , @vw_BidMaturityChecksum         AS INT = 0
          , @vw_LegacyMaturitiesChecksum    AS INT = 0
          , @vw_IssueMaturityChecksum       AS INT = 0 ;


--  1)  Compute CHECKSUM for each view of data used in proc
    SELECT  @vw_LegacyBiddersChecksum =
            CHECKSUM_AGG( CHECKSUM( IssueID, FirmID, PurchasePrice, TICPercent
                                  , NICPercent, NICAmount, BABTICPercent
                                  , HasWinningBid, IsRecoveryAct ) )
      FROM  Conversion.vw_LegacyBidders ;

    SELECT  @vw_BidderChecksum =
            CHECKSUM_AGG( CHECKSUM( IssueID, FirmID, BidPrice, TICPercent
                                  , NICPercent, NICAmount, BABTICPercent
                                  , HasWinningBid, IsRecoveryAct ) )
      FROM  dbo.Bidder ;

    SELECT  @vw_LegacyBidAnnual =
            CHECKSUM_AGG( CHECKSUM( IssueID, FirmID, PaymentDate, PaymentAmount
                                  , OrginalPaymentAmount, InterestRate, TermBond ) )
      FROM  Conversion.vw_LegacyBidAnnual ;

    SELECT  @vw_BidMaturityChecksum =
            CHECKSUM_AGG( CHECKSUM( b.IssueID, b.FirmID, bm.PaymentDate, bm.PaymentAmount
                                  , bm.OrginalPaymentAmount, bm.InterestRate, bm.TermBond ) )
      FROM  dbo.BidMaturity AS bm
INNER JOIN  dbo.Bidder AS b ON b.BidderID = bm.BidderID ;


--  2)  Stop processing when the legacy and converted data are equivalent
    IF  ( @vw_LegacyBiddersChecksum    = @vw_BidderChecksum )       AND
        ( @vw_LegacyBidAnnual          = @vw_BidMaturityChecksum )
    BEGIN
        PRINT 'No Legacy Bidding Histories have changed, ending processBiddingHistories' ;
        RETURN ;
    END
    ELSE
        PRINT 'Bidding Histories have changed, converting data ' ;


--  3)  Load legacy data into temp storage
    SELECT  BidderID = IDENTITY(INT, 1, 1 ), *
      INTO  #legacyBiddersData
      FROM  Conversion.vw_legacyBidders ;
    SELECT  @BidderRecords = @@ROWCOUNT ;

    SELECT  BidMaturityID = IDENTITY(INT, 1, 1 ), *
      INTO  #legacyBidAnnualData
      FROM  Conversion.vw_legacyBidAnnual ;
    SELECT  @BidMaturityRecords = @@ROWCOUNT ;


--  4)  Update BidMaturity temp data with new keys for Bidder
    UPDATE  #legacyBidAnnualData
       SET  BidderID = b.BidderID
      FROM  #legacyBidAnnualData AS ba
INNER JOIN  #legacyBiddersData   AS b
        ON  b.IssueID = ba.IssueID AND b.firmID = ba.firmID ;


--  5)  Delete data from current converted tables
    DELETE  dbo.Bidder ;
    DELETE  dbo.BidMaturity ;


--  6)  Reload converted tables with extracted legacy data
    SET IDENTITY_INSERT dbo.Bidder ON ;

    INSERT  dbo.Bidder (
            BidderID, IssueID, FirmID
          , BidSourceID, BidPrice, TICPercent
          , NICPercent, NICAmount
          , BABTICPercent, BABNICPercent
          , HasWinningBid, IsRecoveryAct
          , ModifiedDate, ModifiedUser )

    SELECT  BidderID, IssueID, FirmID
          , 6, PurchasePrice, TICPercent
          , NICPercent, NICAmount
          , BABTICPercent, 0
          , HasWinningBid, IsRecoveryAct
          , GETDATE(), 'processMaturities'
      FROM  #legacyBiddersData ;

    SET IDENTITY_INSERT dbo.Bidder OFF ;

    SET IDENTITY_INSERT dbo.BidMaturity ON ;

    INSERT  dbo.BidMaturity (
            BidMaturityID, BidderID
          , PaymentDate, PaymentAmount
          , OrginalPaymentAmount
          , InterestRate, TermBond
          , ModifiedDate, ModifiedUser )
    SELECT  BidMaturityID, BidderID
          , PaymentDate, PaymentAmount
          , OrginalPaymentAmount
          , InterestRate, TermBond
          , GETDATE(), 'processMaturities'
      FROM  #legacyBidAnnualData ;

    SET IDENTITY_INSERT dbo.BidMaturity OFF ;


--  7) Print control totals
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Records loaded to dbo.Bidder         = ' + CAST( @BidderRecords          AS VARCHAR(20) ) ;
    PRINT '    Records loaded to dbo.BidMaturity    = ' + CAST( @BidMaturityRecords     AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
