
CREATE PROCEDURE [dbo].[usp_InsertNewEhlersEmployee] ( @FirstName varchar(50), 
													   @LastName varchar(50), 
													   @EhlersOfficeID int, 
													   @Phone varchar(15), 
													   @Email varchar(150), 
													   @JobTitle varchar(200),
													   @JobGroups AS varchar(MAX),
													   @JobTeams AS varchar(MAX))
AS
/*
************************************************************************************************************************************

  Procedure:    usp_InsertNewEhlersEmployee
     Author:    Mike Kiemen
    Purpose:    INSERTs records for a new Ehlers Employee and there job group


    revisor         date                description
    ---------       -----------         ----------------------------
    mkiemen         2013-06-18          created

    Logic Summary:
    1)  

************************************************************************************************************************************
*/
BEGIN
SET NOCOUNT ON ;

INSERT INTO EhlersEmployee (
	FirstName, LastName, MiddleInitial, Initials, Active, EhlersOfficeID, Phone, CellPhone, Fax, Email, JobTitle, OfficerTitle, 
	BillRate, BaseRate, Biography, Education, HireDate, Waiver, PictureWaiver, CIPFACertified, ModifiedDate, ModifiedUser
)
VALUES (
	@FirstName /* FirstName - VARCHAR(50) NOT NULL */, 
	@LastName /* LastName - VARCHAR(50) NOT NULL */, 
	DEFAULT /* MiddleInitial - VARCHAR(50) NOT NULL */, 
	DEFAULT /* Initials - VARCHAR(50) NOT NULL */, 
	1 /* Active - BIT NOT NULL */, 
	@EhlersOfficeID /* EhlersOfficeID - INT */, 
	@Phone /* Phone - VARCHAR(15) NOT NULL */, 
	DEFAULT /* CellPhone - VARCHAR(15) NOT NULL */, 
	'' /* Fax - VARCHAR(15) */, 
	@Email /* Email - VARCHAR(150) NOT NULL */, 
	@JobTitle /* JobTitle - VARCHAR(200) NOT NULL */, 
	DEFAULT /* OfficerTitle - VARCHAR(100) NOT NULL */, 
	DEFAULT /* BillRate - DECIMAL(15, 2) NOT NULL */, 
	DEFAULT /* BaseRate - DECIMAL(15, 2) NOT NULL */, 
	DEFAULT /* Biography - VARCHAR(MAX) NOT NULL */, 
	DEFAULT /* Education - VARCHAR(MAX) NOT NULL */, 
	GETDATE() /* 'YYYY-MM-DD' HireDate - DATE NOT NULL */, 
	DEFAULT /* Waiver - BIT NOT NULL */, 
	DEFAULT /* PictureWaiver - BIT NOT NULL */, 
	DEFAULT /* CIPFACertified - BIT NOT NULL */, 
	GETDATE() /* 'YYYY-MM-DD hh:mm:ss[.nnn]' ModifiedDate - DATETIME NOT NULL */, 
	SYSTEM_USER /* ModifiedUser - VARCHAR(20) NOT NULL */
)
		
DECLARE @eeID int = SCOPE_IDENTITY()

INSERT INTO EhlersEmployeeJobGroups (
	EhlersEmployeeID,EhlersJobGroupID,Active,ModifiedDate,ModifiedUser
) 
SELECT @eeId AS EhlersEmployeeID, 
		Item AS EhlersJobGroupID, 
		1 AS Active, 
		GETDATE() AS ModifiedDate, 
		SYSTEM_USER AS ModifiedUser
FROM dbo.tvf_CSVSplit(@JobGroups, ',') tc

INSERT INTO EhlersEmployeeJobTeams (
	EhlersEmployeeID,EhlersJobTeamID,Active,ModifiedDate,ModifiedUser
) 
SELECT @eeId AS EhlersEmployeeID, 
		Item AS EhlersJobTeamID, 
		1 AS Active, 
		GETDATE() AS ModifiedDate, 
		SYSTEM_USER AS ModifiedUser
FROM dbo.tvf_CSVSplit(@JobTeams, ',') tc


END