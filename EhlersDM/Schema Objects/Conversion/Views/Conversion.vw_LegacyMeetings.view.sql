CREATE VIEW Conversion.vw_LegacyMeetings
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyMeetings
     Author:    Chris Carson
    Purpose:    consolidates and scrubs data from the edata.Bidders and edata.InternetBidders tables


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
      WITH  preSale AS (
            SELECT  IssueID             = iss.IssueID
                  , MeetingPurposeID    = 9
                  , MeetingTypeID       = mtp.MeetingTypeID
                  , MeetingDate         = iss.PreSaleDate
                  , MeetingTime         = CAST ( REPLACE(iss.preSaleTime, '.', '') AS TIME (7) )
                  , AwardTime           = NULL
                  , ModifiedDate        = ISNULL( iss.ChangeDate, GETDATE() )
                  , ModifiedUser        = ISNULL( NULLIF( LEFT( iss.ChangeBy, 7 ), 'process' ), 'processIssueMeetings' )
              FROM  edata.Issues    AS iss
         LEFT JOIN  dbo.MeetingType AS mtp ON mtp.Value = iss.PreSaleMeetingType
             WHERE  PreSaleDate IS NOT NULL ) ,

            awardSale AS (
            SELECT  IssueID             = iss.IssueID
                  , MeetingPurposeID    = 3
                  , MeetingTypeID       = mtp.MeetingTypeID
                  , MeetingDate         = iss.SaleDate
                  , MeetingTime         = CAST ( REPLACE(iss.SaleTime, '.', '') AS TIME (7) )
                  , AwardTime           = CAST ( REPLACE(iss.AwardTime, '.', '') AS TIME (7) )
                  , ModifiedDate        = ISNULL( iss.ChangeDate, GETDATE() )
                  , ModifiedUser        = ISNULL( NULLIF( LEFT( iss.ChangeBy, 7 ), 'process' ), 'processIssueMeetings' )
              FROM  edata.Issues    AS iss
         LEFT JOIN  dbo.MeetingType AS mtp ON mtp.Value = iss.SaleMeetingType
             WHERE  SaleDate IS NOT NULL ) 

    SELECT  IssueID, MeetingPurposeID, MeetingTypeID, MeetingDate, MeetingTime, AwardTime, ModifiedDate, ModifiedUser FROM preSale
        UNION
    SELECT  IssueID, MeetingPurposeID, MeetingTypeID, MeetingDate, MeetingTime, AwardTime, ModifiedDate, ModifiedUser FROM awardSale ;
