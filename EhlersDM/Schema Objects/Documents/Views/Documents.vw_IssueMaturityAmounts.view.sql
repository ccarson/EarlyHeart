﻿CREATE VIEW Documents.vw_IssueMaturityAmounts
WITH SCHEMABINDING AS
/*
************************************************************************************************************************************

       View:    Documents.vw_IssueMaturityAmounts
     Author:    Chris Carson
    Purpose:    shows summarized Issue Maturity Amounts


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created -- Issues conversion

    Notes:

************************************************************************************************************************************
*/
    SELECT  ixN           = COUNT_BIG(*)
          , IssueID       = i.IssueID
          , PaymentDate   = pm.PaymentDate
          , Amount        = SUM( pm.PaymentAmount )
      FROM  dbo.IssueMaturity   AS ism
INNER JOIN  dbo.Purpose         AS pur ON iss.IssueID   = pur.IssueID
INNER JOIN  dbo.PurposeMaturity AS prm ON prm.PurposeID = pur.PurposeID
  GROUP BY  i.IssueID, pm.PaymentDate ;

GO

CREATE UNIQUE CLUSTERED INDEX PK_IssueMaturityAmounts
    ON Documents.vw_IssueMaturityAmounts ( IssueID ASC, PaymentDate ASC, Amount ASC ) ;