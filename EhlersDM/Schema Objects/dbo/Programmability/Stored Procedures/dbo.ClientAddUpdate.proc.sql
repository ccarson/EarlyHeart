/*
CREATE Proc [ClientAddUpdate]
	  ( @inClientID int = NULL,
        @inClientName varchar(100) = NULL,
        @inClientPrefix varchar(65)  = NULL,
        @inClientState char(2) = NULL,
        @inSchoolDistrictNumber varchar(20) = NULL,
        @inShortName varchar(50) = NULL,
        @inClientStatus varchar(20) = 'N',
        @inClientStatusEffDate date = NULL,
        @inClientLink int  = NULL,
        @inClientPhone char(12)  = NULL,
        @inClientTollFreePhone char(12)  = NULL,
        @inClientFax   char(12)  = NULL,
        @inClientEmail   char(12)  = NULL,
        @inOriginatingFA1  int = NULL,
        @inOriginatingFA2  int = NULL,
        @inClientFA1   int = NULL,
        @inClientFA2   int = NULL,
        @inClientFA3   int = NULL,
        @inClientTaxID char(10)  = NULL,
        @inClientFiscalYearEnd char(5) = NULL,
        @inTypeJurisdiction    varchar(20) = NULL,
        @inGoverningBoard  varchar(20) = NULL,
        @inClientWebSite   varchar(150) = NULL,
        @inClientNewspaper varchar(150) = NULL,
        @inClientLogo  varbinary = NULL,
        @inGovBoardMeetSched   varchar(50)  = NULL,
        @inGovBoardMeetTime    time = NULL,
        @inGovBoardMeetLoc varchar(50) = NULL,
        @inCountyHome  varchar(20) = NULL,
        @inCounty1 varchar(20) = NULL,
        @inCounty2 varchar(20) = NULL,
        @inCounty3 varchar(20) = NULL,
        @inCounty4 varchar(20) = NULL,
        @inCounty5 varchar(20) = NULL,
        @inMSA int = NULL,
        @inQuickBookName varchar(50)  = NULL,
        @inAcctngClass varchar(20) = NULL,
        @inClientABANumber numeric = NULL,
        @inClientAccountNumber varchar(20) = NULL,
        @inDTCAgentNumber varchar(16) = null,
        @inMayorTieBreakInd char(1) = 'Y',
        @inIncorporatedDate date = NULL,
        @inFormOfGovernment varchar(20) = 'N',
        @inHomeRuleCharterInd char(1) = 'N',
        @inHomeRuleAmendInd char(1) = 'N',
        @inHomeRuleAmendDate date = NULL,
        @inLastUpdateDate datetime = NULL,
        @inLastUpdateID varchar(20)  = 'Missing'
         )
as

-------------------------------------------------------------------------------------------
    KRounds     07/27/2010      New
-------------------------------------------------------------------------------------------

BEGIN
  	SET NOCOUNT ON;
    	
    DECLARE @HoldReturn int,
            @ErrorMessage    VARCHAR(4000),
            --@ErrorNumber     INT,
            --@ErrorSeverity   INT,
            --@ErrorState      INT,
            @ErrorLine       VARCHAR(16),
            @ErrorProcedure  VARCHAR(200);

    BEGIN TRY 
 
        BEGIN TRANSACTION 
        IF isnull(@inClientID, 0 ) > 0
          BEGIN
            UPDATE Clients
              SET 	
                ClientName            = @inClientName,
                ClientPrefix          = @inClientPrefix,
                ClientState           = @inClientState,
                SchoolDistrictNumber  = @inSchoolDistrictNumber,
                ShortName             = @inShortName,
                ClientStatus          = @inClientStatus,
                ClientStatusEffDate   = @inClientStatusEffDate,
                ClientLink           = @inClientLink,
                ClientPhone           = @inClientPhone,
                ClientTollFreePhone   = @inClientTollFreePhone,
                ClientFax             = @inClientFax,
                ClientEmail             = @inClientEmail,
                OriginatingFA1        = @inOriginatingFA1,
                OriginatingFA2        = @inOriginatingFA2,
                ClientFA1             = @inClientFA1,
                ClientFA2             = @inClientFA2,
                ClientFA3             = @inClientFA3,
                ClientTaxID           = @inClientTaxID,
                ClientFiscalYearEnd   = @inClientFiscalYearEnd,
                TypeJurisdiction      = @inTypeJurisdiction,
                GoverningBoard        = @inGoverningBoard,
                ClientWebSite         = @inClientWebSite,
                ClientNewspaper       = @inClientNewspaper,
                ClientLogo            = @inClientLogo,
                GovBoardMeetSched     = @inGovBoardMeetSched,
                GovBoardMeetTime      = @inGovBoardMeetTime,
                GovBoardMeetLoc       = @inGovBoardMeetLoc,
                CountyHome            = @inCountyHome,
                County1               = @inCounty1,
                County2               = @inCounty2,
                County3               = @inCounty3,
                County4               = @inCounty4,
                County5               = @inCounty5,
                MSA                  = @inMSA,
                QuickBookName         = @inQuickBookName,
                AcctngClass           = @inAcctngClass,
                ClientABANumber       = @inClientABANumber,
                ClientAccountNumber   = @inClientAccountNumber,
                DTCAgentNumber        = @inDTCAgentNumber,
                MayorTieBreakInd      = @inMayorTieBreakInd,
                IncorporatedDate      = @inIncorporatedDate,
                FormOfGovernment      = @inFormOfGovernment,
                HomeRuleCharterInd    = @inHomeRuleCharterInd,
                HomeRuleAmendInd      = @inHomeRuleAmendInd,
                HomeRuleAmendDate     = @inHomeRuleAmendDate,
                LastUpdateDate        = GETDATE(),
                LastUpdateID          = @inLastUpdateID           

              WHERE ClientID = @inClientID;
            SET @HoldReturn = @inClientID;
          END;

    IF @@ROWCOUNT < 1 or @inClientID IS NULL
      BEGIN
        INSERT into Clients
           (
            ClientName,
            ClientPrefix,
            ClientState,
            SchoolDistrictNumber,
            ShortName,
            ClientStatus,
            ClientStatusEffDate,
            ClientLink,
            ClientPhone,
            ClientTollFreePhone,
            ClientFax,
            ClientEmail,
            OriginatingFA1,
            OriginatingFA2,
            ClientFA1,
            ClientFA2,
            ClientFA3,
            ClientTaxID,
            ClientFiscalYearEnd,
            TypeJurisdiction,
            GoverningBoard,
            ClientWebSite,
            ClientNewspaper,
            ClientLogo,
            GovBoardMeetSched,
            GovBoardMeetTime,
            GovBoardMeetLoc,
            CountyHome,
            County1,
            County2,
            County3,
            County4,
            County5,
            MSA,
            QuickBookName,
            AcctngClass,
            ClientABANumber,
            ClientAccountNumber,
            DTCAgentNumber,
            MayorTieBreakInd,
            IncorporatedDate,
            FormOfGovernment,
            HomeRuleCharterInd,
            HomeRuleAmendInd,
            HomeRuleAmendDate,
            LastUpdateDate,
            LastUpdateID          
             )
        SELECT 
            @inClientName,
            @inClientPrefix,
            @inClientState,
            @inSchoolDistrictNumber,
            @inShortName,
            @inClientStatus,
            @inClientStatusEffDate,
            @inClientLink,
            @inClientPhone,
            @inClientTollFreePhone,
            @inClientFax,
            @inClientEmail,
            @inOriginatingFA1,
            @inOriginatingFA2,
            @inClientFA1,
            @inClientFA2,
            @inClientFA3,
            @inClientTaxID,
            @inClientFiscalYearEnd,
            @inTypeJurisdiction,
            @inGoverningBoard,
            @inClientWebSite,
            @inClientNewspaper,
            @inClientLogo,
            @inGovBoardMeetSched,
            @inGovBoardMeetTime,
            @inGovBoardMeetLoc,
            @inCountyHome,
            @inCounty1,
            @inCounty2,
            @inCounty3,
            @inCounty4,
            @inCounty5,
            @inMSA,
            @inQuickBookName,
            @inAcctngClass, 
            @inClientABANumber,
            @inClientAccountNumber,
            @inDTCAgentNumber,
            @inMayorTieBreakInd,
            @inIncorporatedDate,
            @inFormOfGovernment,
            @inHomeRuleCharterInd,
            @inHomeRuleAmendInd,
            @inHomeRuleAmendDate,
            GETDATE(),
            @inLastUpdateID           
            
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
        
        EXEC @HoldReturn = AppErrorLogAdd 
            'UserNameHere',
            'AddUpdateEmployee',
            @ErrorMessage,
            '',
            @ErrorProcedure,
            @ErrorLine
    END CATCH        
    
    select @HoldReturn;

END
*/
