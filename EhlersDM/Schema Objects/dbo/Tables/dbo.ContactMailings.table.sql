CREATE TABLE dbo.ContactMailings (
    ContactMailingsID   INT             NOT NULL    IDENTITY
  , ContactID           INT             NOT NULL
  , MailingTypeID       INT             NOT NULL
  , DeliveryMethodID    INT             NOT NULL    CONSTRAINT DF_ContactMailings_DeliveryMethodID  DEFAULT ((0))
  , OptOut              BIT             NOT NULL    CONSTRAINT DF_ContactMailings_OptOut            DEFAULT ((0))
  , OptOutDate          DATETIME        NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ContactMailings_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ContactMailings_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ContactMailings PRIMARY KEY CLUSTERED ( ContactMailingsID ASC )
  , CONSTRAINT UX_ContactMailings UNIQUE NONCLUSTERED ( ContactID ASC, MailingTypeID ASC )
  , CONSTRAINT FK_ContactMailings_Contact
        FOREIGN KEY ( ContactID ) REFERENCES dbo.Contact ( ContactID )
  , CONSTRAINT FK_ContactMailings_DeliveryMethod
        FOREIGN KEY ( DeliveryMethodID ) REFERENCES dbo.DeliveryMethod ( DeliveryMethodID )
  , CONSTRAINT FK_ContactMailings_MailingType
        FOREIGN KEY ( MailingTypeID ) REFERENCES dbo.MailingType ( MailingTypeID )
) ;
GO

CREATE INDEX IX_ContactMailings_ContactID ON dbo.ContactMailings ( ContactID ASC ) ;
