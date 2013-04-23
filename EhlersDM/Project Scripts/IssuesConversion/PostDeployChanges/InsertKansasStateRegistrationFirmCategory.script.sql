/*
Insert a FirmCategories row for State of Kansas as State Registration if one doesnt exist. This will be used on Cost of Issuance page
*/
DECLARE @firmid int
SET @firmid = ISNULL((SELECT f.FirmID  FROM Firm f WHERE f.FirmName = 'State of Kansas - Office of the Attorney General'),0)
IF @firmid > 0  AND NOT EXISTS(SELECT * FROM FirmCategories fc WHERE fc.FirmCategoryID = 64 AND fc.FirmID = @firmid)
	INSERT INTO FirmCategories (FirmID, FirmCategoryID, Active) VALUES (@firmid,64,1)