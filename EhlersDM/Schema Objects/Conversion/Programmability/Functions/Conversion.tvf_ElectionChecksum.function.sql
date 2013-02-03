CREATE FUNCTION Conversion.tvf_ElectionChecksum ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ElectionChecksum
     Author:    Chris Carson
    Purpose:    returns checksum values for given ElectionIDs


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)    'Legacy'|'Converted'

    Notes:
    Use QUOTENAME() to prevent "wrong field" errors.  QUOTENAME() encloses fields with [] and prevents that error from occurring.
    USE CAST for the GoodFaith and Notes from edata.dbo.Firms, HASHBYTES does not compute checksums over text fields.

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  ElectionID      = ElectionID
              , ClientID        = ClientID
              , ElectionDate    = ElectionDate
              , Amount          = Amount
              , Purpose         = ISNULL( Purpose, 0 )
              , Description     = Description
              , VotesYes        = VotesYes
              , VotesNo         = VotesNo
          FROM  Conversion.vw_LegacyElections
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ElectionID      = ElectionID
              , ClientID        = ClientID
              , ElectionDate    = ElectionDate
              , Amount          = ElectionAmount
              , Purpose         = ISNULL( ElectionTypeID, 0 )
              , Description     = Description
              , VotesYes        = YesVotes
              , VotesNo         = NoVotes
          FROM  dbo.Election
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  ElectionID, ClientID, ElectionDate, Amount, Purpose, Description, VotesYes, VotesNo FROM legacy
            UNION ALL
        SELECT  ElectionID, ClientID, ElectionDate, Amount, Purpose, Description, VotesYes, VotesNo FROM converted )


SELECT  ElectionID       =  ElectionID
     ,  ElectionChecksum =  CAST( HASHBYTES( 'md5', CAST( ElectionID     AS varchar (20) )
                                                       +  CAST( ClientID AS varchar (20) )
                                                       +  CONVERT( varchar (10), ElectionDate, 120 )
                                                       +  CAST( Amount   AS varchar (20) )
                                                       +  CAST( Purpose  AS varchar (20) )
                                                       +  Description
                                                       +  CAST( VotesYes AS varchar (20) )
                                                       +  CAST( VotesNo  AS varchar (20) ) ) AS VARBINARY(128) )
  FROM  inputData ;
