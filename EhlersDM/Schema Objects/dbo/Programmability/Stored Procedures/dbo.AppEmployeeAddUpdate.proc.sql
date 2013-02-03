/*
CREATE Proc [AppEmployeeAddUpdate]
		( @inEmployeeID int = null,
		  @inContactID int,
		  @inFirstName varchar(30),
		  @inLastName varchar(30),
		  @inMiddleInitial char(1),
		  @inInitials char(3),
		  @inEmployeeStatus char(2) = 'A',
		  @inHireDate date,
		  @inteam varchar(20),
		  @inOffice char(2),
		  @inEmployeePhone varchar(12),
		  @inEmployeeLDCode char(3),
		  @inEmployeeCellPhone varchar(12),
		  @inEmployeeEmail varchar(50),
		  @inTitle varchar(100),
		  @inTitle2 varchar(100),
		  @inOfficerTitle varchar(100),
		  @inBillRate decimal(5,2),
		  @inBaseRate decimal(5,2),
		  @inBiography varchar(max),
		  @inEducation varchar(2000),
		  @inPriorGovExperience numeric(3,0),
		  @inPriorFAExperience numeric(3,0),
		  @inSignature varchar(50),
		  @inPicture varchar(100),
		  @inWaiverInd char(1),
		  @inPictureWaiverInd char(1),
		  @inCIPFACertificationInd char(1),
		  @inLastUpdateID varchar(10) )
as

-------------------------------------------------------------------------------------------
    KRounds     07/27/2010      New
    Does an update of the Employees table or an Insert if emloyeeID is null, or not found.
    Returns EmployeesID if successfull, else < 0 ( -1) for trapping on calling side.
-------------------------------------------------------------------------------------------

BEGIN
  	SET NOCOUNT ON;
    	
    DECLARE @HoldReturn int,
            @ErrorMessage    VARCHAR(4000),
            --@ErrorNumber     INT,
            --@ErrorSeverity   INT,
            --@ErrorState      INT,
            @ErrorLine       VARCHAR(16),
            @ErrorProcedure  VARCHAR(200);

    BEGIN TRY 
 
        BEGIN TRANSACTION 
        IF isnull(@inEmployeeID, 0 ) > 0
          BEGIN
            UPDATE EhlersEmployees
              SET 	
                ContactID = @inContactID,
                FirstName = @inFirstName,
                LastName =  @inLastName,
                MiddleInitial = @inMiddleInitial,
                Initials = @inInitials,
                EmployeeStatus = @inEmployeeStatus,
                HireDate = @inHireDate,
                team = @inteam,
                Office = @inOffice,
                EmployeePhone = @inEmployeePhone,
                EmployeeLDCode = @inEmployeeLDCode,
                EmployeeCellPhone = @inEmployeeCellPhone,
                EmployeeEmail = @inEmployeeEmail,
                JobTitle = @inTitle,
                JobTitle2 = @inTitle2,
                OfficerTitle = @inOfficerTitle,
                BillRate = @inBillRate,
                BaseRate = @inBaseRate,
                Biography = @inBiography,
                Education = @inEducation,
                PriorGovExperience = @inPriorGovExperience,
                PriorFAExperience = @inPriorFAExperience,
                Signature = @inSignature,
                Picture = NULL,--@inPicture,
                WaiverInd =  @inWaiverInd,
                PictureWaiverInd = @inPictureWaiverInd,
                CIPFACertificationInd = @inCIPFACertificationInd,
                LastUpdateDate = getdate(),
                LastUpdateID = @inLastUpdateID
              WHERE EhlersEmployeeID = @inEmployeeID;
            SET @HoldReturn = @inEmployeeID;
          END;

    IF @@ROWCOUNT < 1 or @inEmployeeID IS NULL
      BEGIN
        INSERT into EhlersEmployees
           (ContactID,
            FirstName,
            LastName,
            MiddleInitial,
            Initials,
            EmployeeStatus,
            HireDate,
            team,
            Office,
            EmployeePhone,
            EmployeeLDCode,
            EmployeeCellPhone,
            EmployeeEmail,
            JobTitle,
            JobTitle2,
            OfficerTitle,
            BillRate,
            BaseRate,
            Biography,
            Education,
            PriorGovExperience,
            PriorFAExperience,
            Signature,
            Picture,
            WaiverInd,
            PictureWaiverInd,
            CIPFACertificationInd,
            LastUpdateDate,
            LastUpdateID )
          SELECT 
            @inContactID,
            @inFirstName,
            @inLastName,
            @inMiddleInitial,
            @inInitials,
            @inEmployeeStatus,
            @inHireDate,
            @inteam,
            @inOffice,
            @inEmployeePhone,
            @inEmployeeLDCode,
            @inEmployeeCellPhone,
            @inEmployeeEmail,
            @inTitle,
            @inTitle2,
            @inOfficerTitle,
            @inBillRate,
            @inBaseRate,
            @inBiography,
            @inEducation,
            @inPriorGovExperience,
            @inPriorFAExperience,
            @inSignature,
            NULL,--@inPicture,
            @inWaiverInd,
            @inPictureWaiverInd,
            @inCIPFACertificationInd,
            GETDATE(),
            @inLastUpdateID;
            
        SET @HoldReturn = @@IDENTITY;
      END;
      COMMIT TRANSACTION; 
    END TRY 
    
    BEGIN CATCH

        SELECT 
            --@ErrorNumber = ERROR_NUMBER(),
            --@ErrorSeverity = ERROR_SEVERITY(),
            --@ErrorState = ERROR_STATE(),
            @ErrorLine = 'errr',--ERROR_LINE(),
            @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-'),
            @ErrorMessage = 'Error # ' + CONVERT(varchar,ERROR_NUMBER()) +' ' + ERROR_MESSAGE();


        ROLLBACK TRANSACTION;
        --SET @HoldReturn = -1;
        
        --EXEC @HoldReturn = AppErrorLogAdd 
        --    'UserNameHere',
        --    'AddUpdateEmployee',
        --    @ErrorMessage,
        --    '',
        --    @ErrorProcedure,
        --    @ErrorLine
    END CATCH        
    
    RETURN @HoldReturn;

END
*/
