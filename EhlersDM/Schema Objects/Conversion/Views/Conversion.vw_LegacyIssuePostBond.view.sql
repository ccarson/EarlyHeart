CREATE VIEW Conversion.vw_LegacyIssuePostBond
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyIssues
     Author:    Chris Carson
    Purpose:    shows "scrubbed" version of edata.Issue Post Bond data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          Issues Conversion

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  IssueID         =   iss.IssueID
          , AccruedInterest =   CAST( ISNULL( iss.AccruedInterest, 0 )   AS DECIMAL (15,2) )
          , ArbitrageYield  =   CAST( ISNULL( iss.ArbitrageYield, 0 )    AS DECIMAL (11,8) )
          , NICAmount       =   CAST( ISNULL( iss.NIC, 0 )               AS DECIMAL (15,2) )
          , NICPercent      =   CAST( ISNULL( iss.NICpct, 0 )            AS DECIMAL (11,8) )
          , TICPercent      =   CAST( ISNULL( iss.TIC, 0 )               AS DECIMAL (11,8) )
          , AICPercent      =   CAST( ISNULL( iss.AIC, 0 )               AS DECIMAL (11,8) )
          , BBI             =   CAST( ISNULL( iss.BBI, 0 )               AS DECIMAL (11,8) )
          , ModifiedDate    =   ISNULL( iss.ChangeDate, GETDATE() )
          , ModifiedUser    =   ISNULL( NULLIF( iss.ChangeBy, '' ), 'processIssuePostBond' )
      FROM  edata.Issues    AS iss
INNER JOIN  edata.Clients   AS cli ON cli.ClientID = iss.ClientID ;
