CREATE TABLE dbo.StatutoryAuthorityJurisdictionTypes (
    StatutoryAuthorityJurisdictionTypesID   INT             NOT NULL    IDENTITY
  , StatutoryAuthorityID                    INT             NOT NULL    
  , JurisdictionTypeID                      INT             NULL        
  , State                                   VARCHAR (2)     NOT NULL    CONSTRAINT DF_StatutoryAuthorityJurisdictionTypes_State         DEFAULT ''                      
  , Active                                  BIT             NOT NULL    CONSTRAINT DF_StatutoryAuthorityJurisdictionTypes_Active        DEFAULT 1                       
  , ModifiedDate                            DATETIME        NOT NULL    CONSTRAINT DF_StatutoryAuthorityJurisdictionTypes_ModifiedDate  DEFAULT GETDATE()               
  , ModifiedUser                            VARCHAR (20)    NOT NULL    CONSTRAINT DF_StatutoryAuthorityJurisdictionTypes_ModifiedUser  DEFAULT dbo.udf_GetSystemUser() 

  , CONSTRAINT PK_StatutoryAuthorityJurisdictionTypes PRIMARY KEY CLUSTERED ( StatutoryAuthorityJurisdictionTypesID ASC ) 
  , CONSTRAINT UX_StatutoryAuthorityJurisdictionTypes 
        UNIQUE NONCLUSTERED ( JurisdictionTypeID ASC, StatutoryAuthorityID ASC, State ASC ) 
  , CONSTRAINT FK_StatutoryAuthorityJurisdictionTypes_JurisdictionType 
        FOREIGN KEY ( JurisdictionTypeID ) REFERENCES dbo.JurisdictionType ( JurisdictionTypeID )
  , CONSTRAINT FK_StatutoryAuthorityJurisdictionTypes_StatutoryAuthority 
        FOREIGN KEY ( StatutoryAuthorityID ) REFERENCES dbo.StatutoryAuthority ( StatutoryAuthorityID )
);
