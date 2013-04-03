CREATE TABLE dbo.ClientWireInstruction (
    ClientWireInstructionID INT           NOT NULL  IDENTITY
  , ClientID                INT           NOT NULL
  , Title                   VARCHAR (50)  NOT NULL
  , Instruction             VARCHAR (200) NOT NULL
  , ModifiedDate            DATETIME      NOT NULL    CONSTRAINT DF_ClientWireInstruction_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)  NOT NULL    CONSTRAINT DF_ClientWireInstruction_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientWireInstruction_Client PRIMARY KEY CLUSTERED ( ClientWireInstructionID ASC )
  , CONSTRAINT FK_ClientWireInstruction_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_ClientWireInstruction_ClientID ON dbo.ClientWireInstruction ( ClientID ASC ) ;
