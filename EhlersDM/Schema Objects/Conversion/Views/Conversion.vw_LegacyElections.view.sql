CREATE VIEW Conversion.vw_LegacyElections
AS
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyElections
     Author:    Chris Carson
    Purpose:    shows "scrubbed" version of legacy elections data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
    SELECT  ElectionID      = e.ElectionID
          , ClientID        = e.ClientID
          , ElectionDate    = CAST( e.ElectionDate AS date )
          , Amount          = CAST( ISNULL( e.Amount, 0 ) AS decimal (15, 2) )
          , Purpose         = et.ElectionTypeID
          , Description     = ISNULL( e.Description, '' )
          , VotesYes        = e.VotesYes
          , VotesNo         = e.VotesNo
      FROM  edata.dbo.Elections AS e
 LEFT JOIN  dbo.ElectionType    AS et ON et.LegacyValue = e.Purpose ;