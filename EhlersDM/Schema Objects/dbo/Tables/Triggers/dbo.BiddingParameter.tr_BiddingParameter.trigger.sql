CREATE TRIGGER dbo.tr_BiddingParameter ON dbo.BiddingParameter
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_BiddingParameter
     Author:    Chris Carson
    Purpose:    loads BiddingParameter data into edata.Issues


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create dbo.AddressHistory records reflecting DELETEs

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processBiddingParameters AS VARBINARY(128) = CAST( 'processBiddingParameters' AS VARBINARY(128) ) ;
    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

    DECLARE @changedIssues AS TABLE ( IssueID INT ) ;


--  1)  Stop processing when trigger is invoked by Conversion.processIssues procedure
    IF  CONTEXT_INFO() = @processBiddingParameters
        RETURN ;

--  3)  Stop processing unless BiddingParameter data has actually changed
    BEGIN TRY
    IF  NOT EXISTS ( SELECT i.BiddingParameterID, i.IssueID, c.BiddingParameterChecksum
                       FROM inserted AS i
                 INNER JOIN Conversion.tvf_BiddingParameterChecksum( 'Converted' ) AS c
                         ON c.BiddingParameterID = i.BiddingParameterID
                        EXCEPT
                     SELECT i.BiddingParameterID, i.IssueID, c.BiddingParameterChecksum
                       FROM inserted AS i
                 INNER JOIN Conversion.tvf_BiddingParameterChecksum( 'Legacy' ) AS c
                         ON c.BiddingParameterID = i.BiddingParameterID )
        RETURN ;

    INSERT  @changedIssues
    SELECT  IssueID FROM inserted
        UNION
    SELECT  IssueID FROM deleted ;

--  4)  Update edata.Issues with relevant data from dbo.Issue
    UPDATE  edata.Issues
       SET  MinimumBid      = c.MinimumBid
          , MaximumBid      = c.MaximumBid
          , AllowDecrease   = c.AllowDecrease
          , TermBonds       = c.TermBonds
          , AdjustIssue     = c.AdjustIssue
          , PctInterest     = c.PctInterest
          , MaximumDecrease = c.MaximumDecrease
          , DateDecrease    = c.DateDecrease
          , AwardBasis      = c.AwardBasis
          , InternetSale    = c.InternetSale
          , ChangeDate      = ISNULL( c.ChangeDate, GETDATE() )
          , ChangeBy        = ISNULL( c.ChangeBy, @SystemUser )
      FROM  edata.Issues AS a
INNER JOIN  @changedIssues AS b
        ON  b.IssueID = a.IssueID
 LEFT JOIN  Conversion.vw_ConvertedBiddingParameter AS c
        ON  c.IssueID = b.IssueID ;
    END TRY
    BEGIN CATCH
        ROLLBACK ; 
        EXECUTE dbo.processEhlersError ; 
    END CATCH         

END
