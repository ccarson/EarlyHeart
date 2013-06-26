﻿CREATE TABLE [dbo].[Issue] (
    [IssueID]                      INT             IDENTITY (1, 1) NOT NULL,
    [ClientID]                     INT             NOT NULL,
    [IssueName]                    VARCHAR (150)   NOT NULL,
    [IssueAmount]                  DECIMAL (15, 2) NOT NULL,
    [IssueShortNameID]             INT             NULL,
    [IssueShortNameOS]             VARCHAR (100)   CONSTRAINT [DF_Issue_IssueShortNameOS] DEFAULT ('') NOT NULL,
    [DatedDate]                    DATE            NULL,
    [IssueStatusID]                INT             NULL,
    [IssueTypeID]                  INT             CONSTRAINT [DF_Issue_IssueTypeListID] DEFAULT ((0)) NULL,
    [MethodOfSaleID]               INT             NULL,
    [SecurityTypeID]               INT             NULL,
    [BondFormTypeID]               INT             NULL,
    [InitialOfferingDocumentID]    INT             NULL,
    [TaxStatus]                    VARCHAR (20)    CONSTRAINT [DF_Issue_TaxStatus] DEFAULT ('') NOT NULL,
    [PrivateActBond]               BIT             CONSTRAINT [DF_Issue_PrivateActBond] DEFAULT ((0)) NOT NULL,
    [Bond501C3]                    BIT             CONSTRAINT [DF_Issue_Bond501C3] DEFAULT ((0)) NOT NULL,
    [Cusip6]                       VARCHAR (6)     CONSTRAINT [DF_Issue_Cusip6] DEFAULT ('') NULL,
    [BankQualified]                BIT             CONSTRAINT [DF_Issue_BankQualified] DEFAULT ((1)) NOT NULL,
    [Callable]                     BIT             CONSTRAINT [DF_Issue_Callable] DEFAULT ((1)) NOT NULL,
    [CallFrequencyID]              INT             NULL,
    [SaleDate]                     DATE            NULL,
    [SaleTime]                     TIME (7)        NULL,
    [SettlementDate]               DATE            NULL,
    [OSPrintDate]                  DATE            NULL,
    [AnticipationCertificate]      VARCHAR (50)    CONSTRAINT [DF_Issue_AnticipationCertificate] DEFAULT ('') NOT NULL,
    [InterestPaymentFreqID]        INT             CONSTRAINT [DF_Issue_InterestPaymentFreqID] DEFAULT ((5)) NULL,
    [InterestCalcMethodID]         INT             CONSTRAINT [DF_Issue_InterestCalcMethodID] DEFAULT ((1)) NULL,
    [InterestTypeID]               INT             CONSTRAINT [DF_Issue_InterestTypeID] DEFAULT ((1)) NULL,
    [FirstInterestDate]            DATE            NULL,
    [DebtServiceYear]              VARCHAR (50)    CONSTRAINT [DF_Issue_DebtServiceYear] DEFAULT ('') NOT NULL,
    [PurchasePrice]                DECIMAL (15, 2) CONSTRAINT [DF_Issue_PurchasePrice] DEFAULT ((0.00)) NOT NULL,
    [QualifiedForDebtServiceEqual] BIT             CONSTRAINT [DF_Issue_QualifiedForDebtServiceEqual] DEFAULT ((0)) NOT NULL,
    [GoodFaithPercent]             INT             CONSTRAINT [DF_Issue_GoodFaithPercent] DEFAULT ((0)) NOT NULL,
    [QCDate]                       DATETIME        NULL,
    [ShortDescription]             VARCHAR (200)   CONSTRAINT [DF_Issue_ShortDescription] DEFAULT ('') NOT NULL,
    [LongDescription]              VARCHAR (MAX)   CONSTRAINT [DF_Issue_LongDescription] DEFAULT ('') NOT NULL,
    [IsTargetList]                 BIT             CONSTRAINT [DF_Issue_IsTargetList] DEFAULT ((0)) NOT NULL,
    [RefundedByNote]               VARCHAR (MAX)   CONSTRAINT [DF_Issue_RefundedByNote] DEFAULT ('') NOT NULL,
    [RefundsNote]                  VARCHAR (MAX)   CONSTRAINT [DF_Issue_RefundsNote] DEFAULT ('') NOT NULL,
    [DisclosureTypeID]             INT             CONSTRAINT [DF_Issue_DisclosureTypeID] DEFAULT ((0)) NULL,
    [IsEIPInvest]                  BIT             CONSTRAINT [DF_Issue_IsEIPInvest] DEFAULT ((0)) NOT NULL,
    [IsTwoPercentLimit]            BIT             CONSTRAINT [DF_Issue_IsTwoPercentLimit] DEFAULT ((0)) NOT NULL,
    [TwoPercentLimitBasedOn]       VARCHAR (100)   CONSTRAINT [DF_Issue_TwoPercentLimitBasedOn] DEFAULT ('') NOT NULL,
    [CreditEnhanceFee]             DECIMAL (15, 2) CONSTRAINT [DF_Issue_CreditEnhanceFee] DEFAULT ((0)) NOT NULL,
    [PostIssuanceFee]              DECIMAL (15, 2) CONSTRAINT [DF_Issue_PostIssuanceFee] DEFAULT ((0)) NOT NULL,
    [LineItemTotalEstEhlersFee]    DECIMAL (18)    CONSTRAINT [DF_Issue_LineItemEstimatedEhlersFee] DEFAULT ((0)) NOT NULL,
    [TotalFeePaymentMethodID]      INT             NULL,
    [TotalFeeVerifyDate]           DATE            NULL,
    [TotalFeeVerifyUser]           VARCHAR (20)    CONSTRAINT [DF_Issue_TotalFeeVerifyUser] DEFAULT ('') NOT NULL,
    [TotalEstimatedEhlersFee]      DECIMAL (15, 2) CONSTRAINT [DF_Issue_TotalEstimatedEhlersFee] DEFAULT ((0)) NOT NULL,
    [GoodFaithDestination]         VARCHAR (50)    CONSTRAINT [DF_Issue_GoodFaithDestination] DEFAULT ('To Ehlers') NOT NULL,
    [Notes]                        VARCHAR (MAX)   NULL,
    [DebtStructureNotes]           VARCHAR (MAX)   NULL,
    [ObligorClientID]              INT             NULL,
    [CertificateTypeID]            INT             NULL,
    [FirstDeadline]                DATE            NULL,
    [IsAAC]                        BIT             CONSTRAINT [DF_Issue_IsAAC] DEFAULT ((0)) NOT NULL,
    [IsTAC]                        BIT             CONSTRAINT [DF_Issue_IsTAC] DEFAULT ((0)) NOT NULL,
    [RefundingOfSTFL]              BIT             CONSTRAINT [DF_Issue_RefundingOfSTFL] DEFAULT ((0)) NOT NULL,
    [RefundingOfLocalBankLoan]     BIT             CONSTRAINT [DF_Issue_RefundingOfLocalBankLoan] DEFAULT ((0)) NOT NULL,
    [WIGOPlannedAbatement]         BIT             CONSTRAINT [DF_Issue_WIGOPlannedAbatement] DEFAULT ((0)) NOT NULL,
    [InterimFinancing]             BIT             CONSTRAINT [DF_Issue_InterimFinancing] DEFAULT ((0)) NOT NULL,
    [BalloonMaturitySchedule]      BIT             CONSTRAINT [DF_Issue_BalloonMaturitySchedule] DEFAULT ((0)) NOT NULL,
    [ModifiedDate]                 DATETIME        CONSTRAINT [DF_Issue_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]                 VARCHAR (20)    CONSTRAINT [DF_Issue_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_Issue] PRIMARY KEY CLUSTERED ([IssueID] ASC),
    CONSTRAINT [FK_Issue_BondFormType] FOREIGN KEY ([BondFormTypeID]) REFERENCES [dbo].[BondFormType] ([BondFormTypeID]),
    CONSTRAINT [FK_Issue_CallFrequency] FOREIGN KEY ([CallFrequencyID]) REFERENCES [dbo].[CallFrequency] ([CallFrequencyID]),
    CONSTRAINT [FK_Issue_CertificateType] FOREIGN KEY ([CertificateTypeID]) REFERENCES [dbo].[CertificateType] ([CertificateTypeID]),
    CONSTRAINT [FK_Issue_Client] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Client] ([ClientID]),
    CONSTRAINT [FK_Issue_DisclosureType] FOREIGN KEY ([DisclosureTypeID]) REFERENCES [dbo].[DisclosureType] ([DisclosureTypeID]),
    CONSTRAINT [FK_Issue_InitialOfferingDocument] FOREIGN KEY ([InitialOfferingDocumentID]) REFERENCES [dbo].[InitialOfferingDocument] ([InitialOfferingDocumentID]),
    CONSTRAINT [FK_Issue_InterestCalcMethod] FOREIGN KEY ([InterestCalcMethodID]) REFERENCES [dbo].[InterestCalcMethod] ([InterestCalcMethodID]),
    CONSTRAINT [FK_Issue_InterestPaymentFreq] FOREIGN KEY ([InterestPaymentFreqID]) REFERENCES [dbo].[InterestPaymentFreq] ([InterestPaymentFreqID]),
    CONSTRAINT [FK_Issue_InterestType] FOREIGN KEY ([InterestTypeID]) REFERENCES [dbo].[InterestType] ([InterestTypeID]),
    CONSTRAINT [FK_Issue_IssueShortName] FOREIGN KEY ([IssueShortNameID]) REFERENCES [dbo].[IssueShortName] ([IssueShortNameID]),
    CONSTRAINT [FK_Issue_IssueStatus] FOREIGN KEY ([IssueStatusID]) REFERENCES [dbo].[IssueStatus] ([IssueStatusID]),
    CONSTRAINT [FK_Issue_IssueType] FOREIGN KEY ([IssueTypeID]) REFERENCES [dbo].[IssueType] ([IssueTypeID]),
    CONSTRAINT [FK_Issue_MethodOfSale] FOREIGN KEY ([MethodOfSaleID]) REFERENCES [dbo].[MethodOfSale] ([MethodOfSaleID]),
    CONSTRAINT [FK_Issue_ObligorClient] FOREIGN KEY ([ObligorClientID]) REFERENCES [dbo].[Client] ([ClientID]),
    CONSTRAINT [FK_Issue_PaymentMethod] FOREIGN KEY ([TotalFeePaymentMethodID]) REFERENCES [dbo].[PaymentMethod] ([PaymentMethodID]),
    CONSTRAINT [FK_Issue_SecurityType] FOREIGN KEY ([SecurityTypeID]) REFERENCES [dbo].[SecurityType] ([SecurityTypeID])
);


GO

CREATE INDEX IX_Issue_ClientID ON dbo.Issue( ClientID ASC ) ;
GO

CREATE INDEX IX_Issue_IssueName ON dbo.Issue( IssueName ASC ) ;

GO
CREATE TRIGGER  tr_IssueAudit
            ON  dbo.[Issue]
AFTER INSERT, UPDATE,DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_IssueAudit
     Author:    Mike Kiemen
    Purpose:    Synchronizes Issues data back to legacy systems

    revisor         date                description
    ---------       ----------          ----------------------------
    mkiemen         2013-06-17          created

    Logic Summary:
    1)  

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ; 
    
    DECLARE @action AS CHAR (1) ; 
    
    /* determine trigger operation */
    IF  EXISTS ( SELECT 1 FROM inserted ) 
        IF  EXISTS ( SELECT 1 FROM deleted ) 
            SELECT @action = 'U' ;                  -- inserted and deleted records indicate UPDATE statement
        ELSE
            SELECT @action = 'I' ;                  -- inserted records only indicate INSERT statement
    ELSE
        IF  EXISTS ( SELECT 1 FROM deleted )
            SELECT @action = 'D' ;                  -- deleted records only indicate DELETE statement
        ELSE
            RETURN ;                                -- absence of records indicate no data modified, return
    
      WITH  triggerData AS ( 
            SELECT * FROM inserted WHERE @action <> 'D'
                UNION ALL 
            SELECT * FROM deleted  WHERE @action = 'D' ) 
    
    INSERT IssueAudit (
		IssueID,ClientID,IssueName,IssueAmount,IssueShortNameID,IssueShortNameOS,DatedDate,IssueStatusID,IssueTypeID,
		MethodOfSaleID,SecurityTypeID,BondFormTypeID,InitialOfferingDocumentID,TaxStatus,PrivateActBond,Bond501C3,Cusip6,
		BankQualified,Callable,CallFrequencyID,SaleDate,SaleTime,SettlementDate,OSPrintDate,AnticipationCertificate,InterestPaymentFreqID,
		InterestCalcMethodID,InterestTypeID,FirstInterestDate,DebtServiceYear,PurchasePrice,QualifiedForDebtServiceEqual,
		GoodFaithPercent,QCDate,ShortDescription,LongDescription,IsTargetList,RefundedByNote,RefundsNote,DisclosureTypeID,IsEIPInvest,
		IsTwoPercentLimit,TwoPercentLimitBasedOn,CreditEnhanceFee,PostIssuanceFee,LineItemTotalEstEhlersFee,TotalFeePaymentMethodID,
		TotalFeeVerifyDate,TotalFeeVerifyUser,TotalEstimatedEhlersFee,GoodFaithDestination,Notes,DebtStructureNotes,ObligorClientID,
		CertificateTypeID,FirstDeadline,IsAAC,IsTAC,RefundingOfSTFL,RefundingOfLocalBankLoan,WIGOPlannedAbatement,InterimFinancing,
		BalloonMaturitySchedule,ModifiedDate,ModifiedUser,CreateDate,Action,ChangeColumns
	) 
    SELECT 
		IssueID,ClientID,IssueName,IssueAmount,IssueShortNameID,IssueShortNameOS,DatedDate,IssueStatusID,IssueTypeID,
		MethodOfSaleID,SecurityTypeID,BondFormTypeID,InitialOfferingDocumentID,TaxStatus,PrivateActBond,Bond501C3,Cusip6,
		BankQualified,Callable,CallFrequencyID,SaleDate,SaleTime,SettlementDate,OSPrintDate,AnticipationCertificate,InterestPaymentFreqID,
		InterestCalcMethodID,InterestTypeID,FirstInterestDate,DebtServiceYear,PurchasePrice,QualifiedForDebtServiceEqual,
		GoodFaithPercent,QCDate,ShortDescription,LongDescription,IsTargetList,RefundedByNote,RefundsNote,DisclosureTypeID,IsEIPInvest,
		IsTwoPercentLimit,TwoPercentLimitBasedOn,CreditEnhanceFee,PostIssuanceFee,LineItemTotalEstEhlersFee,TotalFeePaymentMethodID,
		TotalFeeVerifyDate,TotalFeeVerifyUser,TotalEstimatedEhlersFee,GoodFaithDestination,Notes,DebtStructureNotes,ObligorClientID,
		CertificateTypeID,FirstDeadline,IsAAC,IsTAC,RefundingOfSTFL,RefundingOfLocalBankLoan,WIGOPlannedAbatement,InterimFinancing,
		BalloonMaturitySchedule,ModifiedDate,ModifiedUser,GETDATE(), @action,COLUMNS_UPDATED()
    FROM triggerData;
    
    --INSERT  dbo.IssueAudit ( 
    --        TestId, Column1, Column2, Column3, Column4, Column5, Column6
    --            , ModifiedDate, ModifiedUser
    --            , CreateDate, ChangeType, ChangeColumns )
    --SELECT  TestId, Column1, Column2, Column3, Column4, Column5, Column6
    --            , ModifiedDate, ModifiedUser
    --            , GETDATE(), @action
    --            , COLUMNS_UPDATED()
    --  FROM  triggerData ; 

END