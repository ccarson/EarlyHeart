CREATE PROCEDURE Import.insertPurposeMaturityRefunding ( @IssueID                   AS VARCHAR (30)
                                                       , @refundingPurposeName      AS VARCHAR (150)
                                                       , @refundedPurposeID         AS VARCHAR (30)
                                                       , @PaymentDate               AS VARCHAR (30)
                                                       , @RefundedAmount            AS VARCHAR (30) ) 
AS
/*
************************************************************************************************************************************

  Procedure:    Import.insertPurposeMaturityRefunding
     Author:    Chris Carson
    Purpose:    INSERTs records onto dbo.PurposeMaturityRefunding  


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:


************************************************************************************************************************************
*/
BEGIN
SET NOCOUNT ON ;

    DECLARE @PurposeID          AS INT ;
    DECLARE @PurposeMaturityID  AS INT ;
    DECLARE @RefundingID        AS INT ;
    

    SELECT  @PurposeID = PurposeID
      FROM  dbo.Purpose
     WHERE  IssueID = CAST( @IssueID AS INT ) and PurposeName = @refundingPurposeName ;
    
    
    SELECT  @PurposeMaturityID = PurposeMaturityID
      FROM  dbo.PurposeMaturity
     WHERE  PurposeID = CAST ( @refundedPurposeID AS INT ) AND PaymentDate = CAST ( @PaymentDate AS DATE )  ;

     
    SELECT  @RefundingID = RefundingID
      FROM  dbo.Refunding
     WHERE  RefundingPurposeID = @PurposeID AND RefundedPurposeID = CAST( @refundedPurposeID AS INT ) 
     
     
    INSERT  dbo.PurposeMaturityRefunding ( 
            PurposeMaturityID, RefundingID, Amount, ModifiedDate, ModifiedUser ) 
    SELECT  @PurposeMaturityID
          , @RefundingID
          , CAST ( @RefundedAmount AS DECIMAL (15, 2) ) 
          , GETDATE()
          , dbo.udf_GetSystemUser() ; 
          

    DELETE  dbo.PurposeMaturityRefunding 
     WHERE  PurposeMaturityID = @PurposeMaturityID
       AND  RefundingID IS NULL ;          

END