/*
CREATE Proc [IssueAddUpdate]
	  (    @inIssueID   int = null,
           @inClientID  int,
           @inProjectID  int = null,
           @inIssueName  varchar(150),
           @inIssueAmount  decimal = 0,
           @inIssueShortName   varchar(65) = null,
           @inIssueShortDesc varchar(200) = null,   --issueverbiage table
           @inIssueLongDesc varchar(max) = null,    --ditto
           @inDatedDate date = null,
           @inIssueStatus   varchar(20) = null,
           @inEhlersFee decimal = 0.0,              --IssueFees table ifee.IssueFeeType = '027-001'
           @inFeeBasis varchar(20) = null,          --ditto
           @inServiceID   int = null,
           @inPrimaryFA    varchar(20) = null,      --issuecontacts table ic.EntityType = '024-001' AND ic.IssueContactRole = '032-003'
           @inSecondaryFA   varchar(20) = null,     --ditto ic1.EntityType = '024-001' AND ic1.IssueContactRole = '032-004'
           @inBondForm      varchar(20) = null,
           @inTaxStatus   varchar(20) = null,
           @inAltMinimumTaxInd char(1) = 'N',
           @inPrivateActBondInd char(1) = 'N',
           @inBond501C3Ind char(1) = 'N',
           @inCusip6 char(6) = null,
           @inBankQualifiedInd  char(1) = 'Y',
           @inSaleDate  date = null,
           @inSaleTime time = null,
           @inSettlementDate  date = null,
           @inOSPrintDate date = null,
           @inBondRatingInd char(1) = 'Y',
           @inBondRatingSP integer = null,
           @inBondRatingMoodys integer = null,
           @inBondRatingFitch integer = null,
           @inRatingType varchar(20) = null,
           @inCreditEnhanceInd char(1) = 'N',
           @inInterestPmtFreq varchar(20) = null,
           @inInterestCalcMethod varchar(20) = null,
           @inFirstInterestDate date = null,
           @inDebtSvcYear varchar(20) = null,
           @inPurchasePrice decimal = null,
           @inTIC Decimal = null,
           @inBABTIC    Decimal = null,
           @inAIC   Decimal = null,
           @inNIC   Decimal = null,
           @inBABNIC decimal = null,
           @inNICAmount decimal = null,
           @inArbitrageYield decimal = null,
           @inElectionID integer = null,
           @inSaleMeetingDate date = null,          --IssueMeetings Table for all below -- imSale.MeetingPurpose = '016-006'
           @inSaleMeetingTime time = null,
           @inSaleMeetingType varchar(20) = null,
           @inSaleMeetingAwardTime time = null,
           @inPreSaleMeetingDate date = null,       -- imPre.MeetingPurpose = '016-001'
           @inPreSaleMeetingTime time = null,
           @inPreSaleMeetingType varchar(20) = null,
           @inParamMeetingDate date = null,         -- imParam.MeetingPurpose = '016-004'
           @inParamMeetingTime time = null,
           @inParamMeetingType varchar(20) = null,
           @inRatifyMeetingDate date = null,        -- imRtfy.MeetingPurpose = '016-005'
           @inRatifyMeetingTime time = null,
           @inRatifyMeetingType varchar(20) = null,
           @inCreditEnhMeetingDate date = null,     -- imCrdt.MeetingPurpose = '016-002'
           @inCreditEnhMeetingTime time = null,
           @inCreditEnhMeetingType varchar(20) = null,
           @inLastUpdateDate date = '01/01/2020',
           @inLastUpdateID varchar(20)
         )
as

-------------------------------------------------------------------------------------------
    KRounds     2/01/2011      New
-------------------------------------------------------------------------------------------

BEGIN
    SET NOCOUNT ON;
	SET XACT_ABORT ON;

    DECLARE @HoldReturn int = -1,
            @ErrorMessage    VARCHAR(4000),
            --@ErrorNumber     INT,
            --@ErrorSeverity   INT,
            --@ErrorState      INT,
            @ErrorLine       VARCHAR(16),
            @ErrorProcedure  VARCHAR(200);

    BEGIN TRY

        BEGIN TRANSACTION
        IF isnull(@inIssueID, 0 ) > 0
          BEGIN
            SET @HoldReturn = @inIssueID;
            UPDATE Issues
               SET
                  ClientID =            @inClientID  ,
                  ProjectID =           @inProjectID  ,
                  IssueName =           @inIssueName  ,
                  IssueAmount =         @inIssueAmount   ,
                  IssueShortName =      @inIssueShortName   ,
                  DatedDate =           @inDatedDate ,
                  IssueStatus =         @inIssueStatus   ,
                  ServiceID =           @inServiceID   ,
                  BondForm =            @inBondForm      ,
                  TaxStatus =           @inTaxStatus   ,
                  AltMinimumTaxInd =    @inAltMinimumTaxInd ,
                  PrivateActBondInd =   @inPrivateActBondInd ,
                  Bond501C3Ind =        @inBond501C3Ind ,
                  Cusip6 =              @inCusip6 ,
                  BankQualifiedInd =    @inBankQualifiedInd,
                  SaleDate =            @inSaleDate  ,
                  SaleTime =            @inSaleTime ,
                  SettlementDate =      @inSettlementDate  ,
                  OSPrintDate =         @inOSPrintDate,
                  BondRatingInd =       @inBondRatingInd ,
                  BondRatingSP =        @inBondRatingSP,
                  BondRatingMoodys =    @inBondRatingMoodys,
                  BondRatingFitch =     @inBondRatingFitch,
                  RatingType =          @inRatingType,
                  CreditEnhanceInd =      @inCreditEnhanceInd,
                  InterestPmtFreq =     @inInterestPmtFreq,
                  InterestCalcMethod =  @inInterestCalcMethod,
                  FirstInterestDate =   @inFirstInterestDate ,
                  DebtSvcYear =         @inDebtSvcYear,
                  PurchasePrice =       @inPurchasePrice,
                  TIC =                 @inTIC ,
                  BABTIC =              @inBABTIC    ,
                  AIC =                 @inAIC   ,
                  NIC =                 @inNIC   ,
                  NICAmount =           @inNICAmount ,
                  BABNIC =              @inBABNIC,
                  ArbitrageYield =      @inArbitrageYield,
                  ElectionID =          @inElectionID,
                  LastUpdateDate        = GETDATE(),
                  LastUpdateID          = @inLastUpdateID

              WHERE IssueID = @inIssueID;
          END;

    IF @@ROWCOUNT < 1 or isnull(@inIssueID,0) = 0
      BEGIN
        INSERT into Issues
           (
            ClientID ,
            ProjectID ,
            IssueName ,
            IssueAmount ,
            IssueShortName ,
            DatedDate ,
            IssueStatus ,
            ServiceID ,
            BondForm ,
            TaxStatus ,
            AltMinimumTaxInd ,
            PrivateActBondInd ,
            Bond501C3Ind ,
            Cusip6 ,
            BankQualifiedInd ,
            SaleDate ,
            SaleTime ,
            SettlementDate ,
                OSPrintDate,
            BondRatingInd ,
            BondRatingSP,
            BondRatingMoodys,
            BondRatingFitch,
            RatingType,
            CreditEnhanceInd,
            InterestPmtFreq,
            InterestCalcMethod,
            FirstInterestDate ,
            DebtSvcYear,
                PurchasePrice,
            TIC ,
            BABTIC ,
            AIC ,
            NIC ,
            BABNIC,
            NICAmount ,
            ArbitrageYield,
                ElectionID,
            LastUpdateDate ,
            LastUpdateID
             )
        SELECT
            @inClientID  ,
            @inProjectID  ,
            @inIssueName  ,
            @inIssueAmount   ,
            @inIssueShortName   ,
            @inDatedDate ,
            @inIssueStatus   ,
            @inServiceID,
            @inBondForm      ,
            @inTaxStatus   ,
            @inAltMinimumTaxInd ,
            @inPrivateActBondInd ,
            @inBond501C3Ind ,
            @inCusip6 ,
            @inBankQualifiedInd,
            @inSaleDate  ,
            @inSaleTime ,
            @inSettlementDate  ,
            @inOSPrintDate,
            @inBondRatingInd ,
            @inBondRatingSP,
            @inBondRatingMoodys,
            @inBondRatingFitch,
            @inRatingType,
            @inCreditEnhanceInd,
            @inInterestPmtFreq,
            @inInterestCalcMethod,
            @inFirstInterestDate ,
            @inDebtSvcYear,
            @inPurchasePrice,
            @inTIC ,
            @inBABTIC    ,
            @inAIC   ,
            @inNIC   ,
            @inBABNIC,
            @inNICAmount ,
            @inArbitrageYield,
            @inElectionID,
            GETDATE(),
            @inLastUpdateID;

        SET @HoldReturn = @@IDENTITY;
      END;

      COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH

        SELECT
            --@ErrorNumber = ERROR_NUMBER(),
            --@ErrorSeverity = ERROR_SEVERITY(),
            --@ErrorState = ERROR_STATE(),
            @ErrorLine = 'errr',--ERROR_LINE(),
            @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-'),
            @ErrorMessage = 'Error # ' + CONVERT(varchar,ERROR_NUMBER()) +' ' + ERROR_MESSAGE();


        ROLLBACK TRANSACTION;
        --SET @HoldReturn = -1;

        EXEC @HoldReturn = EhlersSupport..AppErrorLogAdd
            'UserNameHere',
            'IssueAddUpdate',
            @ErrorMessage,
            '',
            @ErrorProcedure,
            @ErrorLine
    END CATCH

    Select @HoldReturn;

END
*/
