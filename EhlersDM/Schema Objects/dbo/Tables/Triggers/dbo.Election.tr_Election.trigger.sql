CREATE TRIGGER  tr_Election
            ON  dbo.Election
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_Election
     Author:    Chris Carson
    Purpose:    writes Election data back to legacy dbo.Elections

    revisor         date            description
    ---------       ----------      ----------------------------
    ccarson         2013-01-24      created
    ccarson         ###DATE###      Issues conversion 

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
    2)  Stop processing unless Firm data has actually changed
    3)  Merge data from dbo.Firm back to edata.Firms

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;

    DECLARE @changedElections       AS TABLE ( ElectionID INT ) ;

--  1)  Stop processing when trigger is invoked by Conversion.processFirms procedure
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;


    BEGIN TRY
--  2)  create list of ElectionIDs affected by statement
    INSERT  @changedElections
    SELECT  ElectionID FROM inserted
        UNION
    SELECT  ElectionID FROM deleted ;


--  3)  MERGE converted election data onto edata.Elections

    SET IDENTITY_INSERT [$(edata)].dbo.Elections ON ;

      WITH  legacyElections AS (
            SELECT * FROM edata.Elections AS e
             WHERE EXISTS ( SELECT 1 FROM @changedElections AS c WHERE c.ElectionID = e.ElectionID ) ) ,

            changedElections AS (
            SELECT * FROM Conversion.vw_ConvertedElections AS e
             WHERE EXISTS ( SELECT 1 FROM @changedElections AS c WHERE c.ElectionID = e.ElectionID ) )
     MERGE  legacyElections  AS  tgt
     USING  changedElections AS src
        ON  tgt.ElectionID = src.ElectionID
      WHEN  MATCHED THEN 
            UPDATE SET ClientID     = src.ClientID
                     , ElectionDate = src.ElectionDate
                     , Amount       = src.Amount
                     , Purpose      = src.Purpose
                     , Description  = src.Description
                     , Passed       = src.Passed
                     , VotesYes     = src.VotesYes
                     , VotesNo      = src.VotesNo
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ElectionID, ClientID, ElectionDate, Amount
                        , Purpose, Description, Passed, VotesYes, VotesNo )
            VALUES ( src.ElectionID, src.ClientID, src.ElectionDate, src.Amount
                        , src.Purpose, src.Description, src.Passed, src.VotesYes, src.VotesNo )

      WHEN  NOT MATCHED BY SOURCE THEN 
            DELETE ; 

    SET IDENTITY_INSERT [$(edata)].dbo.Elections OFF ;

    END TRY
    BEGIN CATCH
        ROLLBACK ;
        EXECUTE dbo.processEhlersError ;
    END CATCH
END
