CREATE VIEW Conversion.vw_ConvertedElections
AS
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedElections
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
          , ElectionDate    = CAST( e.ElectionDate   AS smalldatetime )
          , Amount          = CAST( e.ElectionAmount AS money )
          , Purpose         = CAST( et.LegacyValue   AS varchar (30) )
          , Description     = CAST( e.Description    AS varchar (100) )
          , Passed          = CAST( CASE
                                        WHEN e.YesVotes > e.NoVotes THEN 'Y'
                                        ELSE 'N'
                                    END AS varchar(1) )
          , VotesYes        = e.YesVotes
          , VotesNo         = e.NoVotes
      FROM  dbo.Election     AS e
 LEFT JOIN  dbo.ElectionType AS et ON et.ElectionTypeID = e.ElectionTypeID ;