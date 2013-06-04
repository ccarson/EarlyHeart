CREATE TRIGGER  tr_Client
            ON  dbo.Client
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_Client
     Author:    ccarson
    Purpose:    writes Client data back to legacy dbo.Clients

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  Stop processing unless Clients data has actually changed
    3)  MERGE new Client data onto edata.Clients


    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM inserted )
        IF  NOT EXISTS ( SELECT 1 FROM deleted )
            RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'Stop processing unless Clients data has actually changed'
          , @codeBlockDesc03    AS SYSNAME  = 'MERGE new Client data onto edata.Clients' ;


    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @legacyChecksum     AS INT
          , @convertedChecksum  AS INT ;


/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  Stop processing unless Clients data has actually changed
    SELECT  @legacyChecksum = CHECKSUM_AGG( CHECKSUM(*) )
      FROM  Conversion.tvf_ClientChecksum( 'Legacy' ) AS l
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = l.ClientID ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) )
      FROM  Conversion.tvf_ClientChecksum( 'Converted' ) AS c
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID ) ;

    IF  @legacyChecksum = @convertedChecksum
        RETURN ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; -- MERGE new Client data onto edata.Clients
      WITH  changedClients AS (
            SELECT TOP 100 PERCENT *
                   FROM Conversion.vw_ConvertedClients  AS c
             WHERE ClientID IN ( SELECT ClientID FROM inserted )
             ORDER BY ClientID )
     MERGE  edata.Clients   AS tgt
     USING  changedClients  AS src ON tgt.ClientId = src.ClientID
      WHEN  MATCHED THEN
            UPDATE SET  ClientDescriptiveName =  src.ClientDescriptiveName
                      , ClientName            =  src.ClientName
                      , InformalName          =  src.InformalName
                      , Prefix                =  src.Prefix
                      , SchoolDistrictNumber  =  src.SchoolDistrictNumber
                      , Status                =  src.Status
                      , StatusDate            =  src.StatusDate
                      , TaxID                 =  src.TaxID
                      , FiscalYearEnd         =  src.FiscalYearEnd
                      , Phone                 =  src.Phone
                      , Fax                   =  src.Fax
                      , TollFree              =  src.TollFree
                      , TypeJurisdiction      =  src.TypeJurisdiction
                      , GovernBoard           =  src.GovernBoard
                      , Population            =  src.Population
                      , NewspaperName         =  src.NewspaperName
                      , WebSite               =  src.WebSite
                      , Notes                 =  src.Notes
                      , QBClient              =  src.QBClient
                      , AcctClass             =  src.AcctClass
                      , ChangeDate            =  src.ChangeDate
                      , ChangeCode            =  'cvClient'
                      , ChangeBy              =  src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT  ( ClientID, ClientDescriptiveName, ClientName, InformalName, Prefix
                        , SchoolDistrictNumber, Status, StatusDate, TaxID, FiscalYearEnd
                        , Phone, Fax, TollFree, TypeJurisdiction, GovernBoard, Population
                        , NewspaperName, WebSite, Notes, QBClient, AcctClass, ChangeDate
                        , ChangeCode, ChangeBy )
            VALUES  ( src.ClientID, src.ClientDescriptiveName, src.ClientName, src.InformalName, src.Prefix
                        , src.SchoolDistrictNumber, src.Status, src.StatusDate, src.TaxID, src.FiscalYearEnd
                        , src.Phone, src.Fax, src.TollFree, src.TypeJurisdiction, src.GovernBoard, src.Population
                        , src.NewspaperName, src.WebSite, src.Notes, src.QBClient, src.AcctClass, src.ChangeDate
                        , 'cvClient', src.ChangeBy ) ;

END TRY
BEGIN CATCH

    DECLARE @errorTypeID            AS INT              = 1
          , @errorSeverity          AS INT              = ERROR_SEVERITY()
          , @errorState             AS INT              = ERROR_STATE()
          , @errorNumber            AS INT              = ERROR_NUMBER()
          , @errorLine              AS INT              = ERROR_LINE()
          , @errorProcedure         AS SYSNAME          = ERROR_PROCEDURE()
          , @errorMessage           AS VARCHAR (MAX)
          , @formattedErrorMessage  AS VARCHAR (MAX)    = NULL
          , @errorData              AS VARCHAR (MAX)    = NULL ;

    SELECT  @errorData = '<b>contents of inserted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ClientID</th><th>ClientLinkID</th><th>ClientName</th><th>ClientPrefixID</th>'
                       + '<th>SchoolDistrictNumber</th><th>InformalName</th><th>ClientStatusID</th><th>StatusChangeDate</th>'
                       + '<th>Phone</th><th>TollFreePhone</th><th>Fax</th><th>Email</th><th>TaxID</th><th>FiscalYearEnd</th>'
                       + '<th>JurisdictionTypeID</th><th>JurisdictionTypeOS</th><th>GoverningBoardID</th><th>WebSite</th>'
                       + '<th>Newspaper</th><th>Logo</th><th>GovBoardMeetingSchedule</th><th>GovBoardMeetingTime</th>'
                       + '<th>GovBoardMeetingLocation</th><th>QuickBookName</th><th>EhlersJobTeamID</th><th>MSAID</th>'
                       + '<th>RedemptionAgentNumber</th><th>DateIncorporated</th><th>FormOfGovernmentID</th>'
                       + '<th>Population</th><th>PopulationDate</th><th>NumberOfEmployees</th><th>NumberOfEmployeesDate</th>'
                       + '<th>Census2000</th><th>Census2010</th><th>MayorVote</th><th>QualifyForDSE</th>'
                       + '<th>JurisdictionSquareMiles</th><th>HomeRuleCharter</th><th>HomeRuleAmend</th>'
                       + '<th>HomeRuleAmendDate</th><th>Notes</th><th>DisclosureContractType</th><th>ContractBillingType</th>'
                       + '<th>CapitalLoanDistrict</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientID, ''
                                        , td = ClientLinkID, ''
                                        , td = ClientName, ''
                                        , td = ClientPrefixID, ''
                                        , td = SchoolDistrictNumber, ''
                                        , td = InformalName, ''
                                        , td = ClientStatusID, ''
                                        , td = StatusChangeDate, ''
                                        , td = Phone, ''
                                        , td = TollFreePhone, ''
                                        , td = Fax, ''
                                        , td = Email, ''
                                        , td = TaxID, ''
                                        , td = FiscalYearEnd, ''
                                        , td = JurisdictionTypeID, ''
                                        , td = JurisdictionTypeOS, ''
                                        , td = GoverningBoardID, ''
                                        , td = WebSite, ''
                                        , td = Newspaper, ''
                                        , td = Logo, ''
                                        , td = GovBoardMeetingSchedule, ''
                                        , td = GovBoardMeetingTime, ''
                                        , td = GovBoardMeetingLocation, ''
                                        , td = QuickBookName, ''
                                        , td = EhlersJobTeamID, ''
                                        , td = MSAID, ''
                                        , td = RedemptionAgentNumber, ''
                                        , td = DateIncorporated, ''
                                        , td = FormOfGovernmentID, ''
                                        , td = Population, ''
                                        , td = PopulationDate, ''
                                        , td = NumberOfEmployees, ''
                                        , td = NumberOfEmployeesDate, ''
                                        , td = Census2000, ''
                                        , td = Census2010, ''
                                        , td = MayorVote, ''
                                        , td = QualifyForDSE, ''
                                        , td = JurisdictionSquareMiles, ''
                                        , td = HomeRuleCharter, ''
                                        , td = HomeRuleAmend, ''
                                        , td = HomeRuleAmendDate, ''
                                        , td = Notes, ''
                                        , td = DisclosureContractType, ''
                                        , td = ContractBillingType, ''
                                        , td = CapitalLoanDistrict, ''
                                        , td = ModifiedDate, ''
                                        , td = ModifiedUser, ''
                                    FROM  inserted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + N'</table></br></br>' ;

    IF  EXISTS ( SELECT 1 FROM deleted )
        SELECT  @errorData = @errorData
                       + '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ClientID</th><th>ClientLinkID</th><th>ClientName</th><th>ClientPrefixID</th>'
                       + '<th>SchoolDistrictNumber</th><th>InformalName</th><th>ClientStatusID</th><th>StatusChangeDate</th>'
                       + '<th>Phone</th><th>TollFreePhone</th><th>Fax</th><th>Email</th><th>TaxID</th><th>FiscalYearEnd</th>'
                       + '<th>JurisdictionTypeID</th><th>JurisdictionTypeOS</th><th>GoverningBoardID</th><th>WebSite</th>'
                       + '<th>Newspaper</th><th>Logo</th><th>GovBoardMeetingSchedule</th><th>GovBoardMeetingTime</th>'
                       + '<th>GovBoardMeetingLocation</th><th>QuickBookName</th><th>EhlersJobTeamID</th><th>MSAID</th>'
                       + '<th>RedemptionAgentNumber</th><th>DateIncorporated</th><th>FormOfGovernmentID</th>'
                       + '<th>Population</th><th>PopulationDate</th><th>NumberOfEmployees</th><th>NumberOfEmployeesDate</th>'
                       + '<th>Census2000</th><th>Census2010</th><th>MayorVote</th><th>QualifyForDSE</th>'
                       + '<th>JurisdictionSquareMiles</th><th>HomeRuleCharter</th><th>HomeRuleAmend</th>'
                       + '<th>HomeRuleAmendDate</th><th>Notes</th><th>DisclosureContractType</th><th>ContractBillingType</th>'
                       + '<th>CapitalLoanDistrict</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientID, ''
                                        , td = ClientLinkID, ''
                                        , td = ClientName, ''
                                        , td = ClientPrefixID, ''
                                        , td = SchoolDistrictNumber, ''
                                        , td = InformalName, ''
                                        , td = ClientStatusID, ''
                                        , td = StatusChangeDate, ''
                                        , td = Phone, ''
                                        , td = TollFreePhone, ''
                                        , td = Fax, ''
                                        , td = Email, ''
                                        , td = TaxID, ''
                                        , td = FiscalYearEnd, ''
                                        , td = JurisdictionTypeID, ''
                                        , td = JurisdictionTypeOS, ''
                                        , td = GoverningBoardID, ''
                                        , td = WebSite, ''
                                        , td = Newspaper, ''
                                        , td = Logo, ''
                                        , td = GovBoardMeetingSchedule, ''
                                        , td = GovBoardMeetingTime, ''
                                        , td = GovBoardMeetingLocation, ''
                                        , td = QuickBookName, ''
                                        , td = EhlersJobTeamID, ''
                                        , td = MSAID, ''
                                        , td = RedemptionAgentNumber, ''
                                        , td = DateIncorporated, ''
                                        , td = FormOfGovernmentID, ''
                                        , td = Population, ''
                                        , td = PopulationDate, ''
                                        , td = NumberOfEmployees, ''
                                        , td = NumberOfEmployeesDate, ''
                                        , td = Census2000, ''
                                        , td = Census2010, ''
                                        , td = MayorVote, ''
                                        , td = QualifyForDSE, ''
                                        , td = JurisdictionSquareMiles, ''
                                        , td = HomeRuleCharter, ''
                                        , td = HomeRuleAmend, ''
                                        , td = HomeRuleAmendDate, ''
                                        , td = Notes, ''
                                        , td = DisclosureContractType, ''
                                        , td = ContractBillingType, ''
                                        , td = CapitalLoanDistrict, ''
                                        , td = ModifiedDate, ''
                                        , td = ModifiedUser, ''
                                    FROM  deleted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + N'</table></br></br>' ;

    ROLLBACK TRANSACTION ;

    IF  @errorMessage IS NULL
    BEGIN
        SELECT  @errorMessage = ERROR_MESSAGE() ;

        EXECUTE dbo.processEhlersError  @errorTypeID
                                      , @codeBlockNum
                                      , @codeBlockDesc
                                      , @errorNumber
                                      , @errorSeverity
                                      , @errorState
                                      , @errorProcedure
                                      , @errorLine
                                      , @errorMessage
                                      , @errorData ;


        SELECT  @formattedErrorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                                       + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: %s ' ;

        RAISERROR( @formattedErrorMessage, @errorSeverity, @codeBlockNum
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine
                 , @errorMessage ) ;

    END
        ELSE
    BEGIN
        SELECT  @errorMessage   = ERROR_MESSAGE()
              , @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
    END

END CATCH
END
