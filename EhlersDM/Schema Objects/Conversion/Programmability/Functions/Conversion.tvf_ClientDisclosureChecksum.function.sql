CREATE FUNCTION Conversion.tvf_ClientDisclosureChecksum ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ClientDisclosureChecksum
     Author:    Chris Carson
    Purpose:    computes the checksum for a given ClientID


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @SourceTable    VARCHAR(20)     'Legacy|Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  ClientID        =   ClientID
              , DisclosureType  =   DisclosureType
              , ContractType    =   ContractType
              , ContractDate    =   ContractDate
          FROM  Conversion.vw_LegacyClientDisclosure
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ClientID        =   c.ClientID
              , DisclosureType  =   c.DisclosureContractType
              , ContractType    =   c.ContractBillingType
              , ContractDate    =   ISNULL( d.DocumentDate, '1900-01-01' )
          FROM  dbo.Client          AS c
     LEFT JOIN  dbo.ClientDocument  AS d ON d.ClientID = c.ClientID
         WHERE  @Source = 'Converted'
                AND ISNULL( d.ClientDocumentNameID, 2 ) = 2
                AND ( c.DisclosureContractType <> '' OR
                      c.ContractBillingType    <> '' OR
                      ISNULL( d.DocumentDate, '1900-01-01' ) <> '1900-01-01' OR
                      d.IsOnFile = 1 ) ) ,

        inputData AS (
        SELECT  ClientID, DisclosureType, ContractType, ContractDate FROM legacy
            UNION ALL
        SELECT  ClientID, DisclosureType, ContractType, ContractDate FROM converted )

SELECT  ClientID            = ClientID
      , DisclosureChecksum  = CAST( HASHBYTES ( 'md5', CAST( ClientID AS VARCHAR(20) )
                                                           + DisclosureType
                                                           + ContractType
                                                           + CONVERT( VARCHAR(10), ContractDate, 120 )
                                                           ) AS VARBINARY(128) )
  FROM  inputData ;
