CREATE PROCEDURE Import.loadRefunding  ( @IssueID               AS VARCHAR (30) 
                                       , @RefundingPurposeName  AS VARCHAR (150)
                                       , @RefundedPurposeID     AS VARCHAR (30)
                                       , @TotalSavingsAmount    AS VARCHAR (30)
                                       , @NPVSavingsAmount      AS VARCHAR (30)
                                       , @NPVBenefitPercent     AS VARCHAR (30) 
                                       , @CallDate              AS VARCHAR (30) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.loadRefunding
     Author:    Chris Carson
    Purpose:    updates Ehlers with refunding data from Munex


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created

    Logic Summary:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

      WITH  incoming AS (
            SELECT  purposeID           = PurposeID
                  , refundedPurposeID   = CAST( @refundedPurposeID  AS INT )
                  , TotalSavingsAmount  = CAST( @TotalSavingsAmount AS DECIMAL (15,2) )
                  , NPVSavingsAmount    = CAST( @NPVSavingsAmount   AS DECIMAL (15,2) )
                  , NPVBenefitPercent   = CAST( @NPVBenefitPercent  AS DECIMAL (5,3)  )
                  , CallDate            = CAST( @CallDate           AS DATE ) 
              FROM  dbo.Purpose 
             WHERE  PurposeName = @RefundingPurposeName 
               AND  IssueID = CAST( @IssueID AS INT ) )
              
     MERGE  dbo.Refunding   AS tgt
     USING  incoming        AS src ON src.purposeID = tgt.RefundingPurposeID AND src.refundedPurposeID = tgt.RefundingPurposeID
      WHEN  MATCHED THEN
            UPDATE SET  TotalSavingsAmount  = src.TotalSavingsAmount
                      , NPVSavingsAmount    = src.NPVSavingsAmount
                      , NPVBenefitPercent   = src.NPVBenefitPercent
                      , ModifiedDate        = GETDATE()
                      , ModifiedUser        = dbo.udf_GetSystemUser()

      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( RefundingPurposeID, RefundedPurposeID
                        , TotalSavingsAmount, NPVSavingsAmount, NPVBenefitPercent
                        , ModifiedDate, ModifiedUser )

            VALUES ( src.PurposeID, src.refundedPurposeID
                        , src.TotalSavingsAmount, src.NPVSavingsAmount, src.NPVBenefitPercent
                        , GETDATE(), dbo.udf_GetSystemUser() ) ;

END
