CREATE TABLE dbo.ProjectService (
    ProjectServiceID   INT           NOT NULL   IDENTITY
  , ServiceCategoryID  INT           NOT NULL
  , CommissionTypeID   INT           NULL
  , ServiceName        VARCHAR (150) NOT NULL
  , DisplaySequence    INT           NOT NULL    CONSTRAINT DF_ProjectService_DisplaySequence DEFAULT ((0))
  , InvoiceDescription VARCHAR (MAX) NOT NULL   CONSTRAINT DF_ProjectService_InvoiceDescription DEFAULT ('')
  , IsOSNotify         BIT           NOT NULL   CONSTRAINT DF_ProjectService_IsOSNotify         DEFAULT ((0))
  , IsTimeEntryBill    BIT           NOT NULL   CONSTRAINT DF_ProjectService_IsTimeEntryBill    DEFAULT ((0))
  , ReviewByDefault    VARCHAR (20)  NULL
  , InvoiceTypeDefault VARCHAR (10)  NULL
  , SaleTypeDefault    VARCHAR (2)   NULL
  , EmailTo            VARCHAR (30)  NULL
  , ModifiedDate       DATETIME      NOT NULL    CONSTRAINT DF_ProjectService_ModifiedDate DEFAULT (getdate())
  , ModifiedUser       VARCHAR (20)  NOT NULL    CONSTRAINT DF_ProjectService_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyServiceID    INT           NULL
  , CONSTRAINT PK_ProjectService PRIMARY KEY CLUSTERED ( ProjectServiceID ASC )
  , CONSTRAINT FK_ProjectService_CommissionType
        FOREIGN KEY ( CommissionTypeID ) REFERENCES dbo.CommissionType ( CommissionTypeID )
  , CONSTRAINT FK_ProjectService_ServiceCategory
        FOREIGN KEY ( ServiceCategoryID ) REFERENCES dbo.ServiceCategory ( ServiceCategoryID )
) ;
GO

CREATE INDEX IX_ProjectService_ServiceName ON dbo.ProjectService ( ServiceName ASC ) ;
