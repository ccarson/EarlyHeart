-- =============================================
-- Author:      Mike Kiemen
-- Create date: 4/2/2013
-- Description: Get totals for a issue based on the Issue Maturity term groups
-- =============================================
CREATE PROCEDURE sp_GetIssueTermGroupTotals (
    @IssueId AS INTEGER
)   
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SELECT x.term, MAX(x.PaymentDate) AS MaturityDate, MAX(x.c3) AS Cusip, (SUM(x.total)- SUM(x.Refund)) AS Amount 
    FROM 
    (SELECT term, 
            im.PaymentDate, 
            ISNULL(SUM(pm.PaymentAmount),0) AS Total, 
            ISNULL((SELECT SUM(pmr.Amount) FROM PurposeMaturityRefunding pmr WHERE pmr.PurposeMaturityID = MAX(pm.PurposeMaturityID)),0) AS Refund,
            c3 = MAX(im.Cusip3)
    FROM IssueMaturity im
        JOIN Purpose p ON im.IssueID = p.IssueID
        JOIN PurposeMaturity pm ON p.PurposeID = pm.PurposeID AND im.PaymentDate = pm.PaymentDate
    WHERE im.IssueID = @IssueId AND im.Term > 0
    GROUP BY im.Term, im.PaymentDate
    ) AS x
    GROUP BY x.term
END
