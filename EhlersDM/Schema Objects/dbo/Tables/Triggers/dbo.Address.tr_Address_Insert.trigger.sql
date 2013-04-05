CREATE TRIGGER dbo.tr_Address_Insert ON dbo.Address
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_Address_Insert
     Author:    Chris Carson
    Purpose:    insert Trigger for Address


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create dbo.AddressAudit records reflecting INSERTs

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; VARBINARY(128) ) ;


--  1)  Create ContactAddressesAudit records reflecting INSERTs
    INSERT  dbo.AddressAudit (
                AddressID
                    , Address1, Address2, Address3
                    , City, State, Zip
                    , Verified, ChangeType
                    , ModifiedDate, ModifiedUser )
    SELECT  AddressID
                , Address1, Address2, Address3
                , City, State, Zip
                , Verified, 'I'
                , ModifiedDate, ModifiedUser
      FROM  inserted ;
END
