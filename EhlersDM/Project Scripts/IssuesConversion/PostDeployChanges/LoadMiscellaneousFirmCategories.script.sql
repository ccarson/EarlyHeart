/*
************************************************************************************************************************************
     Script:    LoadMiscellaneousFirmCategories.script.sql
    Purpose:    Add FirmCategory of "Miscellaneous" to FirmCategories table for existing firms
************************************************************************************************************************************
*/

    INSERT INTO FirmCategories    (FirmID, FirmCategoryID, Active, ModifiedDate, ModifiedUser)
    SELECT f.FirmID, 63 AS FirmCategoryId, 0 AS active, GETDATE() AS ModifiedDate, 'mkiemen' AS ModifiedUser
    FROM Firm f 
    WHERE f.FirmID NOT IN 
    (
          SELECT f.firmid FROM Firm f 
          JOIN FirmCategories fc ON f.FirmID = fc.FirmID
          JOIN FirmCategory fc1 ON fc.FirmCategoryID = fc1.FirmCategoryID
          WHERE fc1.FirmCategoryID IN (63)
    )


