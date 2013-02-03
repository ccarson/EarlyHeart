CREATE VIEW Conversion.vw_LegacyArbitrageService
/*
************************************************************************************************************************************
            
       View:    Conversion.vw_LegacyArbitrageService
     Author:    Chris Carson
    Purpose:    Provides legacy view of converted dbo.ArbitrageService table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************ 
*/
AS
    SELECT  ID              =  i.ID
          , IssueID         =  i.IssueID
          , DtService       =  i.DtService
          , ComputationType =  ISNULL( t.ArbitrageComputationTypeID, 0 ) 
          , ynDataReq       =  i.ynDataReq
          , ynDataIn        =  i.ynDataIn
          , ynReport        =  i.ynReport
          , Fee             =  CAST( ISNULL(i.Fee, 0) AS DECIMAL(15,2) )
          , ModifiedDate    =  ISNULL( x.ChangeDate, GETDATE() ) 
          , ModifiedUser    =  ISNULL( x.ChangeBy, 'processArbitrage' )
      FROM  edata.dbo.IssueArbitrageServices AS i
INNER JOIN  edata.dbo.Issues AS x ON x.IssueID = i.IssueID   
 LEFT JOIN  dbo.ArbitrageComputationType AS t ON t.LegacyValue = i.ComputationType
