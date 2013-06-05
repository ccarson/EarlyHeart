
CREATE VIEW [Conversion].[vw_ConvertedMeetings]
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
            SELECT  IssueID             = ism.IssueID
                  , PreSaleMeetingType  = mtp.Value
                  , PreSaleDate         = ism.MeetingDate
                  , PreSaleTime         = CONVERT( varchar(30), ism.meetingTime, 100 )
              FROM  dbo.IssueMeeting  AS ism
         LEFT JOIN  dbo.MeetingType   AS mtp ON mtp.MeetingTypeID = ism.MeetingTypeID
             WHERE  ism.MeetingPurposeID = 9 AND ism.MeetingDate IS NOT NULL ) ,

            awardSale AS (
            SELECT  IssueID             = ism.IssueID
                  , ConsiderationTime   = CONVERT( varchar(30), ism.MeetingTime, 100 )
                  , AwardTime           = CONVERT( varchar(30), ism.AwardTime, 100 )
              FROM  dbo.IssueMeeting  AS ism
         LEFT JOIN  dbo.MeetingType   AS mtp ON mtp.MeetingTypeID = ism.MeetingTypeID
             WHERE  ism.MeetingPurposeID = 3 AND ism.MeetingTime IS NOT NULL ) ,

            issues AS (
            SELECT IssueID FROM preSale
                UNION
            SELECT IssueID FROM awardSale )

    SELECT  iss.IssueID
          , pre.PreSaleMeetingType
          , pre.PreSaleDate
          , pre.PreSaleTime
          , awd.ConsiderationTime
          , awd.AwardTime
      FROM  issues      AS iss
 LEFT JOIN  preSale     AS pre ON pre.IssueID = iss.IssueID
 LEFT JOIN  awardSale   AS awd ON awd.IssueID = iss.IssueID ;
