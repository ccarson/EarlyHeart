CREATE TABLE dbo.StatAuthorityGroupTypes (
    StatAuthorityGroupTypesID INT          NOT NULL  IDENTITY
  , StatAuthorityGroupID      INT          NOT NULL
  , StatAuthorityTypeID       INT          NOT NULL
  , DisplaySequence           INT          NOT NULL    CONSTRAINT DF_StatAuthorityGroupTypes_DisplaySequence DEFAULT 0
  , ModifiedDate              DATETIME     NOT NULL    CONSTRAINT DF_StatAuthorityGroupTypes_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser              VARCHAR (20) NOT NULL    CONSTRAINT DF_StatAuthorityGroupTypes_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_StatAuthorityGroupTypes PRIMARY KEY CLUSTERED ( StatAuthorityGroupTypesID ASC )
  , CONSTRAINT UX_StatAuthorityGroupTypes UNIQUE NONCLUSTERED ( StatAuthorityGroupID ASC, StatAuthorityTypeID ASC )
  , CONSTRAINT FK_StatAuthorityGroupTypes_StatAuthorityGroup
        FOREIGN KEY ( StatAuthorityGroupID ) REFERENCES dbo.StatAuthorityGroup ( StatAuthorityGroupID )
  , CONSTRAINT FK_StatAuthorityGroupTypes_StatAuthorityType
        FOREIGN KEY ( StatAuthorityTypeID ) REFERENCES dbo.StatAuthorityType ( StatAuthorityTypeID )
) ;
