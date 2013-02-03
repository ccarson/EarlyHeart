CREATE TABLE [Meta].[DatabaseChangeLog] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [EventDate]    DATETIME2 (7)  CONSTRAINT [DF_DatabaseChangeLog_EventDate] DEFAULT (sysdatetime()) NOT NULL,
    [Event]        [sysname]      NULL,
    [TSQL]         NVARCHAR (MAX) NULL,
    [EventXML]     XML            NULL,
    [DatabaseName] [sysname]      NULL,
    [SchemaName]   [sysname]      NULL,
    [Object]       [sysname]      NULL,
    [Host]         [sysname]      NULL,
    [IPAddress]    VARCHAR (48)   NULL,
    [Program]      [sysname]      NULL,
    [NTUserName]   [sysname]      NULL,
    CONSTRAINT [PK_DatabaseChangeLog] PRIMARY KEY CLUSTERED ([id] ASC)
);

