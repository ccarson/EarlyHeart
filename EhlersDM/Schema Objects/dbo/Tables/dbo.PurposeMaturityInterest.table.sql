CREATE TABLE dbo.PurposeMaturityInterest (
    PurposeMaturityInterestID INT               NOT NULL    IDENTITY
  , PurposeMaturityID         INT               NOT NULL    
  , Amount                    DECIMAL (15, 2)   NOT NULL    CONSTRAINT DF_PurposeMaturityInterest_Amount        DEFAULT ((0))
  , InterestDate              DATE              NOT NULL    
  , ModifiedDate              DATETIME          NOT NULL    CONSTRAINT DF_PurposeMaturityInterest_ModifiedDate  DEFAULT (getdate())
  , ModifiedUser              VARCHAR (20)      NOT NULL    CONSTRAINT DF_PurposeMaturityInterest_ModifiedUser  DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_PurposeMaturityInterest PRIMARY KEY CLUSTERED ( PurposeMaturityInterestID ASC )
  , CONSTRAINT FK_PurposeMaturityInterest_PurposeMaturity
        FOREIGN KEY ( PurposeMaturityID ) REFERENCES dbo.PurposeMaturity ( PurposeMaturityID )
) ;
