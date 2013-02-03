/*
-- =============================================
-- Author:      Brian Larson
-- Create date: 8/9/2010
-- Description: Calculate the Maturity Table Rows.
-- =============================================
CREATE FUNCTION [dbo].[udf_MaturityTable]
(
    @SubIssuePurposeID int
)
RETURNS 
@Maturity TABLE 
(
    LevyYear                int,
    CollectYear             int,
    PaymentDate             date,
    Principal               decimal(16,2),
    Rate                    decimal(5,4),
    Interest                decimal(16,2),
    [NetP&I]                decimal(16,2),
    [P&I+5.00%]             decimal(16,2),
    AssessmentPrincipal     decimal(16,2),
    AssessmentInterestAmt   decimal(16,2),
    TotalAssessment         decimal(16,2),
    FundingSource01         decimal(16,2),
    FundingSource02         decimal(16,2),
    FundingSource03         decimal(16,2),
    FundingSource04         decimal(16,2),
    FundingSource05         decimal(16,2),
    FundingSource06         decimal(16,2),
    FundingSource07         decimal(16,2),
    FundingSource08         decimal(16,2),
    FundingSource09         decimal(16,2),
    FundingSource10         decimal(16,2),
    TotalRevenue            decimal(16,2),
    CityLevy                decimal(16,2)
)
AS
BEGIN
    DECLARE @IntCalc table (
                YearNum                 int, 
                SubIssuePurposeID       int, 
                FirstInterestDate       date,
                LevyYear                int,
                CollectYear             int,
                PaymentDate             date,
                Principal               decimal(16,2),
                Rate                    decimal(5,4),
                Interest                decimal(16,2))


    DECLARE @AssessmentCalc table (
                YearNum                 int, 
                LevyYear                int,
                CollectYear             int,
                PaymentDate             date,
                Principal               decimal(16,2),
                Rate                    decimal(5,4),
                Interest                decimal(16,2),
                [NetP&I]                decimal(16,2),
                [P&I+5.00%]             decimal(16,2),
                AssessmentPrincipal     decimal(16,2),
                AssessmentInterestAmt   decimal(16,2))


    INSERT INTO @IntCalc 
    SELECT 
        ROW_NUMBER() OVER(ORDER BY pm.PaymentDate) AS YearNum,
        sip.SubIssuePurposeID,
        i.FirstInterestDate,
        YEAR(pm.PaymentDate)-2 AS LevyYear,
        YEAR(pm.PaymentDate)-1 AS CollectYear,
        pm.PaymentDate,
        pm.PrincipalAmount AS Principal,
        im.InterestRate AS Rate,
        dbo.udf_MaturityDateInterest(pm.SubIssuePurposeID, DatedDate, pm.PaymentDate) AS Interest
    FROM PurposeMaturities pm
    JOIN SubIssuePurpose sip ON pm.SubIssuePurposeID = sip.SubIssuePurposeID
    JOIN SubIssues si ON sip.SubIssueID = si.SubIssueID
    JOIN Issues i ON si.IssueID = i.IssueID
    JOIN IssueMaturities im ON si.IssueID = im.IssueID
                            AND pm.PaymentDate = im.PaymentDate
    WHERE pm.SubIssuePurposeID = @SubIssuePurposeID


    INSERT INTO @AssessmentCalc
    SELECT 
        YearNum,
        LevyYear,
        CollectYear,
        PaymentDate,
        Principal,
        Rate,
        Interest,
        Principal + Interest AS [NetP&I],
        CONVERT(numeric(16,2), ROUND((Principal + Interest)*1.05, 0)) AS [P&I+5.00%],
        CONVERT(numeric(16,2), ROUND(dbo.udf_AssessmentPrincipal(YearNum - (fs.AssessStartYear - YEAR(FirstInterestDate) + 1), AssessmentRate, AssessmentTerm, AssessmentAmt - ISNULL(AssessPrepayAmt, 0), InterestCalcMethod), 0)) AS AssessmentPrincipal,
        dbo.udf_AssessmentInterest(YearNum - (fs.AssessStartYear - YEAR(FirstInterestDate) + 1), AssessmentRate, AssessmentTerm, AssessmentAmt - ISNULL(AssessPrepayAmt, 0), InterestCalcMethod) AS AssessmentInterestAmt
    FROM @IntCalc ic
    LEFT OUTER JOIN FundingSources fs ON ic.SubIssuePurposeID = fs.SubIssuePurposeID
                            AND fs.FundingSourceType = 'Assessment'
                            
    DECLARE @FS01Amt        decimal(16,2)
    DECLARE @FS01Rate       decimal(5,4)
    DECLARE @FS01Term       int
    DECLARE @FS01Start      int
    DECLARE @FS01IntCalc    varchar(20)
    DECLARE @FS02Amt        decimal(16,2)
    DECLARE @FS02Rate       decimal(5,4)
    DECLARE @FS02Term       int
    DECLARE @FS02Start      int
    DECLARE @FS02IntCalc    varchar(20)
    DECLARE @FS03Amt        decimal(16,2)
    DECLARE @FS03Rate       decimal(5,4)
    DECLARE @FS03Term       int
    DECLARE @FS03Start      int
    DECLARE @FS03IntCalc    varchar(20)
    DECLARE @FS04Amt        decimal(16,2)
    DECLARE @FS04Rate       decimal(5,4)
    DECLARE @FS04Term       int
    DECLARE @FS04Start      int
    DECLARE @FS04IntCalc    varchar(20)
    DECLARE @FS05Amt        decimal(16,2)
    DECLARE @FS05Rate       decimal(5,4)
    DECLARE @FS05Term       int
    DECLARE @FS05Start      int
    DECLARE @FS05IntCalc    varchar(20)
    DECLARE @FS06Amt        decimal(16,2)
    DECLARE @FS06Rate       decimal(5,4)
    DECLARE @FS06Term       int
    DECLARE @FS06Start      int
    DECLARE @FS06IntCalc    varchar(20)
    DECLARE @FS07Amt        decimal(16,2)
    DECLARE @FS07Rate       decimal(5,4)
    DECLARE @FS07Term       int
    DECLARE @FS07Start      int
    DECLARE @FS07IntCalc    varchar(20)
    DECLARE @FS08Amt        decimal(16,2)
    DECLARE @FS08Rate       decimal(5,4)
    DECLARE @FS08Term       int
    DECLARE @FS08Start      int
    DECLARE @FS08IntCalc    varchar(20)
    DECLARE @FS09Amt        decimal(16,2)
    DECLARE @FS09Rate       decimal(5,4)
    DECLARE @FS09Term       int
    DECLARE @FS09Start      int
    DECLARE @FS09IntCalc    varchar(20)
    DECLARE @FS10Amt        decimal(16,2)
    DECLARE @FS10Rate       decimal(5,4)
    DECLARE @FS10Term       int
    DECLARE @FS10Start      int
    DECLARE @FS10IntCalc    varchar(20)
    DECLARE @FSCount        int
    DECLARE @CurrFSID       int
    
    SET @FSCount = 0
    
    SELECT @CurrFSID = MIN(FundingSourceID) 
    FROM FundingSources 
    WHERE SubIssuePurposeID = @SubIssuePurposeID
    AND FundingSourceType <> 'Assessment'
    
    WHILE @CurrFSID IS NOT NULL
    BEGIN
        SET @FSCount = @FSCount + 1

        IF @FSCount = 1 
        BEGIN
            SELECT
                @FS01Amt = FundingSourceAmt,
                @FS01Rate = AssessmentRate,
                @FS01Term = AssessmentTerm,
                @FS01Start = AssessStartYear,
                @FS01IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 2 
        BEGIN
            SELECT
                @FS02Amt = FundingSourceAmt,
                @FS02Rate = AssessmentRate,
                @FS02Term = AssessmentTerm,
                @FS02Start = AssessStartYear,
                @FS02IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 3 
        BEGIN
            SELECT
                @FS03Amt = FundingSourceAmt,
                @FS03Rate = AssessmentRate,
                @FS03Term = AssessmentTerm,
                @FS03Start = AssessStartYear,
                @FS03IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 4 
        BEGIN
            SELECT
                @FS04Amt = FundingSourceAmt,
                @FS04Rate = AssessmentRate,
                @FS04Term = AssessmentTerm,
                @FS04Start = AssessStartYear,
                @FS04IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 5 
        BEGIN
            SELECT
                @FS05Amt = FundingSourceAmt,
                @FS05Rate = AssessmentRate,
                @FS05Term = AssessmentTerm,
                @FS05Start = AssessStartYear,
                @FS05IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 6 
        BEGIN
            SELECT
                @FS06Amt = FundingSourceAmt,
                @FS06Rate = AssessmentRate,
                @FS06Term = AssessmentTerm,
                @FS06Start = AssessStartYear,
                @FS06IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 7 
        BEGIN
            SELECT
                @FS07Amt = FundingSourceAmt,
                @FS07Rate = AssessmentRate,
                @FS07Term = AssessmentTerm,
                @FS07Start = AssessStartYear,
                @FS07IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 8 
        BEGIN
            SELECT
                @FS08Amt = FundingSourceAmt,
                @FS08Rate = AssessmentRate,
                @FS08Term = AssessmentTerm,
                @FS08Start = AssessStartYear,
                @FS08IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 9 
        BEGIN
            SELECT
                @FS09Amt = FundingSourceAmt,
                @FS09Rate = AssessmentRate,
                @FS09Term = AssessmentTerm,
                @FS09Start = AssessStartYear,
                @FS09IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        ELSE IF @FSCount = 10 
        BEGIN
            SELECT
                @FS10Amt = FundingSourceAmt,
                @FS10Rate = AssessmentRate,
                @FS10Term = AssessmentTerm,
                @FS10Start = AssessStartYear,
                @FS10IntCalc = InterestCalcMethod
            FROM
                FundingSources
            WHERE
                FundingSourceID = @CurrFSID
        END
        
                
        SELECT @CurrFSID = MIN(FundingSourceID) 
        FROM FundingSources 
        WHERE SubIssuePurposeID = @SubIssuePurposeID
        AND FundingSourceType <> 'Assessment'
        AND FundingSourceID > @CurrFSID
    END

    INSERT INTO @Maturity 
    SELECT 
        LevyYear,
        CollectYear,
        PaymentDate,
        Principal,
        Rate,
        Interest,
        [NetP&I],
        [P&I+5.00%],
        AssessmentPrincipal,
        AssessmentInterestAmt,
        AssessmentPrincipal + AssessmentInterestAmt AS TotalAssessment,
        CASE 
            WHEN @FSCount < 1 THEN 0.00
            WHEN @FS01Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS01Start + @FS01Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS01IntCalc = 'Fixed' THEN @FS01Amt
                    ELSE ROUND(dbo.udf_PMT(@FS01Rate, @FS01Term, @FS01Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource01,
        CASE 
            WHEN @FSCount < 2 THEN 0.00
            WHEN @FS02Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS02Start + @FS02Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS02IntCalc = 'Fixed' THEN @FS02Amt
                    ELSE ROUND(dbo.udf_PMT(@FS02Rate, @FS02Term, @FS02Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource02,
        CASE 
            WHEN @FSCount < 3 THEN 0.00
            WHEN @FS03Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS03Start + @FS03Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS03IntCalc = 'Fixed' THEN @FS03Amt
                    ELSE ROUND(dbo.udf_PMT(@FS03Rate, @FS03Term, @FS03Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource03,
        CASE 
            WHEN @FSCount < 4 THEN 0.00
            WHEN @FS04Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS04Start + @FS04Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS04IntCalc = 'Fixed' THEN @FS04Amt
                    ELSE ROUND(dbo.udf_PMT(@FS04Rate, @FS04Term, @FS04Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource04,
        CASE 
            WHEN @FSCount < 5 THEN 0.00
            WHEN @FS05Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS05Start + @FS05Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS05IntCalc = 'Fixed' THEN @FS05Amt
                    ELSE ROUND(dbo.udf_PMT(@FS05Rate, @FS05Term, @FS05Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource05,
        CASE 
            WHEN @FSCount < 6 THEN 0.00
            WHEN @FS06Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS06Start + @FS06Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS06IntCalc = 'Fixed' THEN @FS06Amt
                    ELSE ROUND(dbo.udf_PMT(@FS06Rate, @FS06Term, @FS06Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource06,
        CASE 
            WHEN @FSCount < 7 THEN 0.00
            WHEN @FS07Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS07Start + @FS07Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS07IntCalc = 'Fixed' THEN @FS07Amt
                    ELSE ROUND(dbo.udf_PMT(@FS07Rate, @FS07Term, @FS07Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource07,
        CASE 
            WHEN @FSCount < 8 THEN 0.00
            WHEN @FS08Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS08Start + @FS08Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS08IntCalc = 'Fixed' THEN @FS08Amt
                    ELSE ROUND(dbo.udf_PMT(@FS08Rate, @FS08Term, @FS08Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource08,
        CASE 
            WHEN @FSCount < 9 THEN 0.00
            WHEN @FS09Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS09Start + @FS09Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS09IntCalc = 'Fixed' THEN @FS09Amt
                    ELSE ROUND(dbo.udf_PMT(@FS09Rate, @FS09Term, @FS09Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource09,
        CASE 
            WHEN @FSCount < 10 THEN 0.00
            WHEN @FS10Start >= YEAR(PaymentDate) THEN 0.00
            WHEN @FS10Start + @FS10Term < YEAR(PaymentDate) THEN 0.00
            ELSE CASE WHEN @FS10IntCalc = 'Fixed' THEN @FS10Amt
                    ELSE ROUND(dbo.udf_PMT(@FS10Rate, @FS10Term, @FS10Amt, 0.0000, 'End'), 0)
                END
        END AS FundingSource10,
        0.00 AS TotalRevenue,
        0.00 AS CityLevy
        --[P&I+5.00%] + AssessmentPrincipal + AssessmentInterestAmt AS CityLevy
    FROM @AssessmentCalc
    ORDER BY PaymentDate
    
    -- Calculate the total city levy.
    UPDATE @Maturity
    SET TotalRevenue = TotalAssessment + FundingSource01 + 
                    FundingSource02 + FundingSource03 + FundingSource04 + 
                    FundingSource05 + FundingSource06 + FundingSource07 + 
                    FundingSource08 + FundingSource09 + FundingSource10,
        CityLevy = [P&I+5.00%] + TotalAssessment + FundingSource01 + 
                    FundingSource02 + FundingSource03 + FundingSource04 + 
                    FundingSource05 + FundingSource06 + FundingSource07 + 
                    FundingSource08 + FundingSource09 + FundingSource10

    RETURN 
END
*/