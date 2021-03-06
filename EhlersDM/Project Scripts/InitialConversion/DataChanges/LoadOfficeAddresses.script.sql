/*
************************************************************************************************************************************

     Script:    Load Office Addresses.sql
    Project:    Initial Conversion
     Author:    Chris Carson 
    Purpose:    Adds default addresses for Ehlers offices into dbo.Address table

************************************************************************************************************************************
*/

PRINT   'Loading Ehlers Office Addresses into dbo.Address...' ;

SET IDENTITY_INSERT dbo.Address ON ;

INSERT  dbo.Address( AddressID, Address1, Address2, Address3, City, State, Zip, Verified, ModifiedDate, ModifiedUser )
            SELECT  1, N'550 Warrenvile Road', N'Suite 220', N'', N'Lisle', N'IL', N'60532-4311', 0, GETDATE(), N'Conversion' 
UNION ALL   SELECT  2, N'3060 Centre Pointe Drive', N'', N'', N'Roseville', N'MN', N'55113-1122', 0, GETDATE(), N'Conversion' 
UNION ALL   SELECT  3, N'375 Bishops Way', N'Suite 225', N'', N'Brookfield ', N'WI', N'53005', 0, GETDATE(), N'Conversion' ;

SET IDENTITY_INSERT dbo.Address OFF ;

PRINT   '   ...Complete!' ;

