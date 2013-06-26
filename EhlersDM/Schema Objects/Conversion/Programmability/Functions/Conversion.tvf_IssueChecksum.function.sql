CREATE FUNCTION Conversion.tvf_IssueChecksum ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_IssueChecksum
     Author:    Chris Carson
    Purpose:    computes the checksum for a given IssueID


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created -- Issues conversion
    

    Function Arguments:
    @Source     VARCHAR(20)    'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  IssueID             =  IssueID
              , DatedDate           =  CONVERT( VARCHAR(10), ISNULL( DatedDate, '1900-01-01' ), 120 )
              , Amount              =  CAST( Amount AS DECIMAL(15,2) )
              , ClientID            =  ClientID
              , IssueName           =  IssueName
              , ShortName           =  ISNULL( ShortName, 0 )
              , IssueStatus         =  ISNULL( IssueStatus, 0 )
              , cusip6              =  ISNULL( cusip6, '' )
              , IssueType           =  ISNULL( IssueType, 0 )
              , SaleType            =  ISNULL( SaleType, 0 )
              , TaxStatus           =  TaxStatus
              , BondForm            =  ISNULL( BondForm, 0 )
              , BankQualified       =  BankQualified
              , SecurityType        =  ISNULL( SecurityType, 0 )
              , SaleDate            =  CONVERT( VARCHAR(10), ISNULL( SaleDate, '1900-01-01' ), 120 )
              , SaleTime            =  CONVERT( VARCHAR(8),  ISNULL( SaleTime, '00:00:00' ), 108 )
              , SettlementDate      =  CONVERT( VARCHAR(10), ISNULL( SettlementDate, '1900-01-01' ), 120 )
              , FirstCouponDate     =  CONVERT( VARCHAR(10), ISNULL( FirstCouponDate, '1900-01-01' ), 120 )
              , IntPmtFreq          =  ISNULL( IntPmtFreq, 0 )
              , IntCalcMeth         =  ISNULL( IntCalcMeth, 0 )
              , CouponType          =  ISNULL( CouponType, 0 )
              , CallFrequency       =  ISNULL( CallFrequency, 0 )
              , DisclosureType      =  ISNULL( DisclosureType, 0 )
              , PurchasePrice       =  CAST ( PurchasePrice AS DECIMAL( 15,2 ) )
              , Notes               =  Notes
              , NotesRefundedBy     =  NotesRefundedBy
              , NotesRefunds        =  NotesRefunds
              , QualityControlDate  =  CONVERT( VARCHAR(10), ISNULL( QualityControlDate, '1900-01-01'), 120 )
              , Purpose             =  Purpose
              , ObligorClientID     =  ISNULL( ObligorClientID, 0 )
              , EIPInvest           =  EIPInvest
          FROM  Conversion.vw_LegacyIssues
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  IssueID             =  IssueID
              , DatedDate           =  CONVERT( VARCHAR(10), ISNULL( DatedDate, '1900-01-01' ), 120 )
              , Amount              =  CAST( IssueAmount AS DECIMAL(15,2) )
              , ClientID            =  ClientID
              , IssueName           =  IssueName
              , ShortName           =  ISNULL( IssueShortNameID, 0 )
              , IssueStatus         =  ISNULL( IssueStatusID, 0 )
              , cusip6              =  ISNULL( Cusip6, '' )
              , IssueType           =  ISNULL( IssueTypeID, 0 )
              , SaleType            =  ISNULL( MethodOfSaleID, 0 )
              , TaxStatus           =  TaxStatus
              , BondForm            =  ISNULL( BondFormTypeID, 0 )
              , BankQualified       =  BankQualified
              , SecurityType        =  ISNULL( SecurityTypeID, 0 )
              , SaleDate            =  CONVERT( VARCHAR(10), ISNULL( SaleDate, '1900-01-01' ), 120 )
              , SaleTime            =  CONVERT( VARCHAR(8),  ISNULL( SaleTime, '00:00:00' ), 108 )
              , SettlementDate      =  CONVERT( VARCHAR(10), ISNULL( SettlementDate, '1900-01-01' ), 120 )
              , FirstCouponDate     =  CONVERT( VARCHAR(10), ISNULL( FirstInterestDate, '1900-01-01' ), 120 )
              , IntPmtFreq          =  ISNULL( InterestPaymentFreqID, 0 )
              , IntCalcMeth         =  ISNULL( InterestCalcMethodID, 0 )
              , CouponType          =  ISNULL( InterestTypeID, 0 )
              , CallFrequency       =  ISNULL( CallFrequencyID, 0 )
              , DisclosureType      =  ISNULL( DisclosureTypeID, 0 )
              , PurchasePrice       =  CAST( PurchasePrice AS DECIMAL( 15,2 ) )
              , Notes               =  ISNULL( Notes, '' )
              , NotesRefundedBy     =  RefundedByNote
              , NotesRefunds        =  RefundsNote
              , QualityControlDate  =  CONVERT( VARCHAR(10), ISNULL( QCDate, '1900-01-01'), 120 )
              , Purpose             =  LongDescription
              , ObligorClientID     =  ISNULL( ObligorClientID, 0 )
              , EIPInvest           =  IsEIPInvest
          FROM  dbo.Issue
         WHERE  @Source = 'Converted' ) ,

        inputData AS (
        SELECT  * FROM legacy
            UNION ALL
        SELECT  * FROM converted )

SELECT  IssueID       = IssueID
      , IssueChecksum = CAST( HASHBYTES ( 'md5', CAST( IssueID AS VARCHAR(20) )
                                                    +  DatedDate
                                                    +  CAST( Amount          AS VARCHAR(20) )
                                                    +  CAST( ClientID        AS VARCHAR(20) )
                                                    +  IssueName
                                                    +  CAST( ShortName       AS VARCHAR(20) )
                                                    +  CAST( IssueStatus     AS VARCHAR(20) )
                                                    +  cusip6
                                                    +  CAST( IssueType       AS VARCHAR(20) )
                                                    +  CAST( SaleType        AS VARCHAR(20) )
                                                    +  TaxStatus
                                                    +  CAST( BondForm        AS VARCHAR(20) )
                                                    +  CAST( BankQualified   AS VARCHAR(20) )
                                                    +  CAST( SecurityType    AS VARCHAR(20) )
                                                    +  SaleDate
                                                    +  SaleTime
                                                    +  SettlementDate
                                                    +  FirstCouponDate
                                                    +  CAST( IntPmtFreq      AS VARCHAR(20) )
                                                    +  CAST( IntCalcMeth     AS VARCHAR(20) )
                                                    +  CAST( CouponType      AS VARCHAR(20) )
                                                    +  CAST( CallFrequency   AS VARCHAR(20) )
                                                    +  CAST( DisclosureType  AS VARCHAR(20) )
                                                    +  CAST( PurchasePrice   AS VARCHAR(20) )
                                                    +  Notes
                                                    +  NotesRefundedBy
                                                    +  NotesRefunds
                                                    +  QualityControlDate
                                                    +  Purpose
                                                    +  CAST( ObligorClientID AS VARCHAR(20) )
                                                    +  CAST( EIPInvest       AS VARCHAR(20) )
                                                    ) AS VARBINARY(128) )
  FROM  inputData ;
