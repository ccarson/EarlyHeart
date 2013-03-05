CREATE VIEW Import.vw_IssuesData
/*
************************************************************************************************************************************

       View:    Conversion.vw_IssuesData
     Author:    Chris Carson
    Purpose:    exposes view of all current Issues with Client Name and Issue data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  TOP 100 PERCENT 
            IssueID                 =  i.IssueID
          , IssuerName              =  c.ClientName
          , IssueName               =  ISNULL( i.IssueName,'' )
          , Amount                  =  ISNULL( i.IssueAmount, 0.00 )
          , SaleDate                =  i.SaleDate
      FROM  dbo.Issue   AS i   
INNER JOIN  dbo.Client  AS c ON c.ClientID = i.ClientID
     ORDER  BY IssueID ;