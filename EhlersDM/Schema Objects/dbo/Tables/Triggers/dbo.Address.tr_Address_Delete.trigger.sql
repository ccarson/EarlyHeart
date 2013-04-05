CREATE TRIGGER dbo.tr_Address_Delete ON dbo.Address
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_Address_Delete
     Author:    Chris Carson
    Purpose:    delete Trigger for Address


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create dbo.AddressHistory records reflecting DELETEs

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

/**/SELECT  @codeBlockNum  = 1
/**/      , @codeBlockDesc = @codeBlockDesc1 ; -- Create dbo.AddressHistory records reflecting DELETEs
    INSERT  dbo.AddressAudit (
                AddressID
                    , Address1, Address2, Address3
                    , City, State, Zip
                    , Verified, ChangeType
                    , ModifiedDate, ModifiedUser )
    SELECT  AddressID
                , Address1, Address2, Address3
                , City, State, Zip
                , Verified, 'D'
                , GETDATE(), @SystemUser
      FROM  deleted ;
END
