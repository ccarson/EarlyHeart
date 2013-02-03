/*
CREATE Proc [ProjectAddUpdate]
	  ( @inProjectID int = NULL,
	    @inClientID int,
        @inServiceCategoryID varchar(20),
        @inServiceID INT  = NULL,
        @inProjectName varchar(150),
        @inPrimaryFA int,
        @inSecondaryFA int = NULL,
        @inProjectStatus varchar(20),
        @inProjectStatusEffDate date = '01/01/2099',
        @inLastUpdateDate date = NULL,
        @inLastUpdateID varchar(20)  = 'Missing'
         )
as

-------------------------------------------------------------------------------------------
    KRounds     12/16/2010      New
-------------------------------------------------------------------------------------------

BEGIN
  	SET NOCOUNT ON;
    	
    DECLARE @HoldReturn int = -9999,
            @ErrorMessage    VARCHAR(4000),
            --@ErrorNumber     INT,
            --@ErrorSeverity   INT,
            --@ErrorState      INT,
            @ErrorLine       VARCHAR(16),
            @ErrorProcedure  VARCHAR(200);

    BEGIN TRY 
 
        BEGIN TRANSACTION 
        IF isnull(@inProjectID, 0 ) > 0
          BEGIN
            UPDATE Projects
              SET 	
                ClientID            = @inClientID,
                ServiceCategoryID          = @inServiceCategoryID,
                ServiceID           = @inServiceID,
                ProjectName  = @inProjectName,
                PrimaryFA             = @inPrimaryFA,
                SecondaryFA             = @inSecondaryFA,
                ProjectStatus          = @inProjectStatus,
                ProjectStatusEffDate   = GETDATE(),--@inProjectStatusEffDate,
                LastUpdateDate        = GETDATE(),
                LastUpdateID          = @inLastUpdateID           

              WHERE ProjectID = @inProjectID;
            SET @HoldReturn = @inProjectID;
          END;

    IF @@ROWCOUNT < 1 or @inProjectID IS NULL
      BEGIN
        INSERT into Projects
           (
                ClientID,
                ServiceCategoryID,
                ServiceID,
                ProjectName,
                PrimaryFA,
                SecondaryFA,
                ProjectStatus,
                ProjectStatusEffDate,
                LastUpdateDate,
                LastUpdateID
             )
        SELECT 
            @inClientID,
            @inServiceCategoryID,
            @inServiceID,
            @inProjectName,
            @inPrimaryFA,
            @inSecondaryFA,
            @inProjectStatus,
            GETDATE(),--@inProjectStatusEffDate,
            GETDATE(),
            @inLastUpdateID           
            
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
        
        EXEC @HoldReturn = AppErrorLogAdd 
            'UserNameHere',
            'ProjectAddUpdate',
            @ErrorMessage,
            '',
            @ErrorProcedure,
            @ErrorLine
    END CATCH        
    
    RETURN @HoldReturn;

END
*/
