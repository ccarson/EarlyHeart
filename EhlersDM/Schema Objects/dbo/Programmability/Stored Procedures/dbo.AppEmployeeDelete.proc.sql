/*
create PROCEDURE [AppEmployeeDelete]
	(@inEmployeeID Int,
	@outResult INT OUTPUT,
	@outMsg varchar(255) OUTPUT)
AS
-- =============================================
-- Author:		<Keven Rounds>
-- Create date:
-- =============================================
BEGIN
  	SET NOCOUNT ON;
  	
  	set @outResult = '';
    set @outMsg = '';
    	
    DECLARE @HoldReturn int = 0,
            @ErrorMessage    VARCHAR(4000),
            --@ErrorNumber     INT,
            --@ErrorSeverity   INT,
            --@ErrorState      INT,
            @ErrorLine       VARCHAR(16),
            @ErrorProcedure  VARCHAR(200);
 
    BEGIN TRY 
        BEGIN TRANSACTION 
		  DELETE EhlersEmployees
			WHERE EhlersEmployeeID = @inEmployeeID;
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
        
        EXEC @HoldReturn = EhlersSupport..AppErrorLogAdd
            'UserNameHere',
            'AddUpdateEmployee',
            @ErrorMessage,
            '',
            @ErrorProcedure,
            @ErrorLine;
            
        set @outResult = @HoldReturn;
        set @outMsg = 'Error';            
    END CATCH        

    RETURN @HoldReturn;

END
*/