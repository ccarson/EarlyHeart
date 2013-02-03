CREATE FUNCTION dbo.udf_GetSystemUser()
RETURNS VARCHAR(20) 
AS
-- =============================================
-- Author:      Mike Kiemen
-- Create date: 1/19/2012
-- Description: Returns the current system username only (sans the domain)
-- =============================================
BEGIN
    DECLARE @userName       AS VARCHAR(20) ;
    DECLARE @system_user    AS NCHAR(30) = SYSTEM_USER ; 

    SELECT  @userName = STUFF( @system_user, 1, CHARINDEX( '\', @system_user ), '' ) ;
    
    RETURN  @userName ; 
END
