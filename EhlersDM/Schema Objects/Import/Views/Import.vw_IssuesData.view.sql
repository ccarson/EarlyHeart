CREATE VIEW Import.vw_IssuesData
/*
************************************************************************************************************************************

       View:    Conversion.vw_IssuesData
     Author:    Chris Carson
    Purpose:    exposes view of all current Issues with Client Name and Issue data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created ( Issues Conversion )

    Notes:

************************************************************************************************************************************
*/
AS
      WITH  purposeAmounts AS ( 
            SELECT  PurposeID = PurposeID
                  , Amount    = SUM( PaymentAmount ) 
              FROM  dbo.PurposeMaturity
             GROUP  BY PurposeID ) 

    SELECT  IssueID                 =  iss.IssueID
          , ClientID                =  iss.ClientID
          , PurposeID               =  pur.PurposeID
          , PurposeName             =  pur.PurposeName
          , PurposeAmount           =  ppa.Amount
          , IssuerName              =  cli.ClientName
          , IssueName               =  ISNULL( iss.IssueName,'' )
          , Amount                  =  ISNULL( iss.IssueAmount, 0.00 )
          , SaleDate                =  iss.SaleDate
          , IssuerState             =  adr.State
      FROM  dbo.Issue           AS iss   
INNER JOIN  dbo.Client          AS cli ON cli.ClientID  = iss.ClientID
INNER JOIN  dbo.ClientAddresses AS cad ON cad.ClientID  = cli.ClientID
INNER JOIN  dbo.Address         AS adr ON adr.AddressID = cad.AddressID AND cad.AddressTypeID = 3 
 LEFT JOIN  dbo.Purpose         AS pur ON pur.IssueID   = iss.IssueID
 LEFT JOIN  purposeAmounts      AS ppa ON ppa.PurposeID = pur.PurposeID ; 

 