CREATE PROCEDURE Import.deleteExistingIssueData ( @IssueID AS INT )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.deleteExistingIssueData
     Author:    Chris Carson
    Purpose:    deletes financing data for a given issue


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  DELETE dbo.IssueMaturity
    2)  DELETE dbo.IssuePostBond
    3)  DELETE dbo.PurposeSource
    4)  DELETE dbo.PurposeUse
    5)  DELETE dbo.PurposeMaturityRefunding
    6)  DELETE dbo.PurposeMaturityInterest
    7)  DELETE dbo.PurposeMaturity
    8)  DELETE dbo.Purpose

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

BEGIN TRY
--  1)  DELETE dbo.IssueMaturity
    DELETE  dbo.IssueMaturity WHERE IssueID = @IssueID ;


--  2)  DELETE dbo.IssuePostBond
    DELETE  dbo.IssuePostBond WHERE IssueID = @IssueID ;


--  3)  DELETE dbo.PurposeSource
    DELETE  dbo.PurposeSource
      FROM  dbo.PurposeSource AS ps
     WHERE  EXISTS ( SELECT 1 FROM dbo.Purpose p WHERE p.PurposeID = ps.PurposeID AND p.IssueID = @IssueID ) ;


--  4)  DELETE dbo.PurposeUse
    DELETE  dbo.PurposeUse
      FROM  dbo.PurposeUse AS pu
     WHERE  EXISTS ( SELECT 1 FROM dbo.Purpose p WHERE p.PurposeID = pu.PurposeID AND p.IssueID = @IssueID ) ;


--  5)  DELETE dbo.PurposeMaturityRefunding
    DELETE  dbo.PurposeMaturityRefunding
      FROM  dbo.PurposeMaturityRefunding pmr
     WHERE  EXISTS ( SELECT 1 FROM dbo.PurposeMaturity pm
                 INNER JOIN dbo.Purpose p ON p.PurposeID = pm.PurposeID AND p.IssueID = @IssueID
                      WHERE pm.PurposeMaturityID = pmr.PurposeMaturityID ) ;


--  6)  DELETE dbo.PurposeMaturityInterest
    DELETE  dbo.PurposeMaturityInterest
      FROM  dbo.PurposeMaturityInterest pmi
     WHERE  EXISTS ( SELECT 1 FROM dbo.PurposeMaturity pm
                 INNER JOIN dbo.Purpose p ON p.PurposeID = pm.PurposeID AND p.IssueID = @IssueID
                      WHERE pm.PurposeMaturityID = pmi.PurposeMaturityID ) ;


--  7)  DELETE dbo.PurposeMaturity
    DELETE  dbo.PurposeMaturity
      FROM  dbo.PurposeMaturity pm
     WHERE  EXISTS ( SELECT 1 FROM dbo.Purpose p WHERE p.PurposeID = pm.PurposeID AND p.IssueID = @IssueID ) ;


--  8)  DELETE dbo.Purpose
    DELETE  FROM dbo.Purpose WHERE IssueID = @IssueID ;


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH

END