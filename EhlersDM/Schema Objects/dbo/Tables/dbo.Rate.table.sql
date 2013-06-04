CREATE TABLE [dbo].[Rate] (
    [RateID]        INT              IDENTITY (1, 1) NOT NULL,
    [EffectiveDate] DATE             NOT NULL,
    [BBIRate]       DECIMAL (13, 10) NULL,
    [RBIRate]       DECIMAL (13, 10) NULL,
    [TreasuryRate]  DECIMAL (13, 10) NULL,
    [ModifiedDate]  DATETIME         CONSTRAINT [DF_Rate_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]  VARCHAR (20)     CONSTRAINT [DF_Rate_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_Rate] PRIMARY KEY NONCLUSTERED ([RateID] ASC),
    CONSTRAINT [UX_Rate_EffectiveDate] UNIQUE CLUSTERED ([EffectiveDate] ASC)
);


