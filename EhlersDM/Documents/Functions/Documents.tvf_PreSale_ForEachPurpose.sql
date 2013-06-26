CREATE FUNCTION [Documents].[tvf_PreSale_ForEachPurpose] ( @IssueID AS INT )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Documents.tvf_OSCoverGeneral
     Author:    Marty Schultz
    Purpose:    return OS Cover data for a given Issue

    revisor         date                description
    ---------       -----------         ----------------------------
    mschultz        2013-06-25          created

    Function Arguments:
    @IssueID         int        IssueID for which function will extract data

    Notes:

************************************************************************************************************************************
*/
RETURN
      WITH  purposeData AS (
            SELECT DISTINCT i.IssueID, p.PurposeName, fst.Value
			FROM Issue AS i
			INNER JOIN Purpose AS p ON p.IssueID = i.IssueID
			INNER JOIN FundingSourceType AS fst ON fst.FundingSourceTypeID = p.FundingSourceTypeID
			WHERE i.IssueID = @IssueID) ,
             
            refundingData AS (
            SELECT  IssueID = @IssueID, isRefunding = CASE COUNT(*) WHEN 0 THEN 0 ELSE 1 END
              FROM  dbo.Issue AS i
             WHERE  i.IssueID = @IssueID AND
                    EXISTS ( SELECT 1 FROM dbo.Purpose p WHERE p.IssueID = i.IssueID AND p.FinanceTypeID IN (1,4,5,6,7,8,9,10,11,12,13,14)) ) ,
            
            currentRefundingData AS (
            SELECT  IssueID = @IssueID, isCurrentRefunding = CASE COUNT(*) WHEN 0 THEN 0 ELSE 1 END
              FROM  dbo.Issue AS i
             WHERE  i.IssueID = @IssueID AND
                    EXISTS ( SELECT 1 FROM dbo.Purpose p WHERE p.IssueID = i.IssueID AND p.FinanceTypeID IN (4,5,6)) ) ,
                    
            advanceRefundingData AS (
            SELECT  IssueID = @IssueID, isAdvanceRefunding = CASE COUNT(*) WHEN 0 THEN 0 ELSE 1 END
              FROM  dbo.Issue AS i
             WHERE  i.IssueID = @IssueID AND
                    EXISTS ( SELECT 1 FROM dbo.Purpose p WHERE p.IssueID = i.IssueID AND p.FinanceTypeID IN (1,7,8,9,10,11)) )              

    SELECT  IssueID                     = ISNULL( pd.IssueID, '' )
          , PurposeName                 = ISNULL( pd.PurposeName, '' )
          , FundingSourceType           = ISNULL( pd.Value, '' )
          , isRefunding                 = ISNULL( rd.isRefunding, '' )
          , isCurrentRefunding          = ISNULL( cr.isCurrentRefunding, '' )
          , isAdvanceRefunding          = ISNULL( ar.isAdvanceRefunding, '' )
      FROM  dbo.Issue AS i
 LEFT JOIN  purposeData               AS pd  ON pd.IssueID  = i.IssueID
 LEFT JOIN  refundingData             AS rd  ON rd.IssueID  = i.IssueID
 LEFT JOIN  currentRefundingData      AS cr  ON cr.IssueID  = i.IssueID
 LEFT JOIN  advanceRefundingData      AS ar  ON ar.IssueID  = i.IssueID
 
     WHERE  i.IssueID = @IssueID ;