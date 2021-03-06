/*
************************************************************************************************************************************

     Script:    LoadStaticLists.script.sql
    Project:    Initial Conversion
     Author:    Chris Carson 
    Purpose:    Initialize Static Lists tables with data

************************************************************************************************************************************
*/
DECLARE @count  AS INT ;

BEGIN TRY

    SET IDENTITY_INSERT dbo.ServiceCategory ON ;

    INSERT  dbo.ServiceCategory ( ServiceCategoryID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )
    SELECT  1, N'Debt Services', 1, 1, N'', GETDATE(), N'Conversion', N'DI'
    UNION ALL SELECT  2, N'Economic Development/Redevelopment', 2, 1, N'', GETDATE(), N'Conversion', N'ED'
    UNION ALL SELECT  3, N'Financial Planning', 4, 1, N'', GETDATE(), N'Conversion', N'FP'
    UNION ALL SELECT  4, N'General Financial Advisory', 5, 1, N'', GETDATE(), N'Conversion', N'GCS'
    UNION ALL SELECT  10, N'Special Services', 3, 1, NULL, GETDATE(), N'Conversion', N'MC' ;
    SET IDENTITY_INSERT dbo.ServiceCategory OFF ;
    SET IDENTITY_INSERT dbo.CommissionType ON ;

    INSERT  dbo.CommissionType ( CommissionTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Financing with No OS', 0, 1, N'', GETDATE(), N'Conversion', N'3'
    UNION ALL SELECT  2, N'Financing with OS', 0, 1, N'', GETDATE(), N'Conversion', N'1'
    UNION ALL SELECT  3, N'Hourly Rate / Flat Fee', 0, 1, N'', GETDATE(), N'Conversion', N'2'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.CommissionType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.CommissionType OFF ;
    SET IDENTITY_INSERT dbo.ProjectService ON ;

    INSERT  dbo.ProjectService ( ProjectServiceID, ServiceCategoryID, CommissionTypeID, ServiceName, DisplaySequence, InvoiceDescription, IsOSNotify, IsTimeEntryBill, ReviewByDefault, InvoiceTypeDefault, SaleTypeDefault, EmailTo, ModifiedDate, ModifiedUser, LegacyServiceId )  
    SELECT  355, 1, 3, N'Arbitrage Monitoring Services', 20, N'For financial advisory services related to Arbitrage Monitoring', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 89
    UNION ALL SELECT  356, 1, NULL, N'Issuance of Debt', 1, N'See Initial Offerind document for invoice description', 1, 0, N'FA', N'PD', N'NA', N'??', GETDATE(), N'Conversion', 83
    UNION ALL SELECT  357, 1, 3, N'Call Notice', 24, N'For all financial advisory services in connection with the _______ partial/full redemption of the above debt issue.', 0, 0, N'DE', N'PD', N'', N'DE', GETDATE(), N'Conversion', 14
    UNION ALL SELECT  358, 1, 3, N'Cash Defeasance', 25, N'For all financial advisory services in connection with the cash defeasance of the above debt issue.', 0, 0, N'DE', N'PD', N'', N'DE', GETDATE(), N'Conversion', 15
    UNION ALL SELECT  359, 1, 2, N'Continuing Disclosure Reporting', 22, N'For all financial advisory services in connection with drafting and filing Continuing Disclosure Reporting requirements.', 0, 0, N'Disc.l Analyst', N'PD', N'', N'', GETDATE(), N'Conversion', 16
    UNION ALL SELECT  360, 1, 3, N'Debt/Debt Service Benchmarking/Study', 21, N'', 0, 1, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 97
    UNION ALL SELECT  361, 1, 1, N'Federal/State Loan/Grant', 96, N'For all financial advisory services rendered in connection with securing a federal or state grant or loan.', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 13
    UNION ALL SELECT  362, 1, 3, N'General Consulting', 97, N'', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 1
    UNION ALL SELECT  364, 2, 3, N'Business District Creation', 14, N'', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 90
    UNION ALL SELECT  365, 2, 3, N'Business Subsidies Policies', 11, N'For financial advisory services provided in assisting the governing board develop Business Subsidy Policies', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 55
    UNION ALL SELECT  366, 2, 3, N'Developer Selection/Proforma/Analysis/Negotiation', 5, N'For financial advisory services provided to assist in analysis of developer proposals and selection of a developer.', 0, 1, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 95
    UNION ALL SELECT  367, 2, 3, N'Establishment of Special Governmental Authority', 13, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 54
    UNION ALL SELECT  368, 2, 3, N'Establishment of Special Service District', 12, N'For financial advisory services provided to assist in establishment of the above Special Service District', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 53
    UNION ALL SELECT  369, 2, 3, N'General Consulting', 99, N'', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 77
    UNION ALL SELECT  370, 2, 3, N'JobZ', 10, N'For financial advisory services provided in assisting through the regulatory process and negotiations with the business', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 57
    UNION ALL SELECT  371, 2, 3, N'Pay As You Go Financing   ( TIF Rev. Bonds )', 1, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 66
    UNION ALL SELECT  372, 2, 3, N'Project Management Services', 6, N'For financial advisory services provided to assist in managing development activities related to the above project.', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 50
    UNION ALL SELECT  373, 2, 3, N'Quick TIF Reporting Software', 9, N'For the purchase of Quick TIF software', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 73
    UNION ALL SELECT  374, 2, 3, N'Tax Abatement', 2, N'For financial advisory services provided in presenting options for using abatement, abatement policies, and implementation of the policy for the above project.', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 56
    UNION ALL SELECT  375, 2, 3, N'TIF District Amendment', 1, N'', 0, 0, N'TIF Coord', N'PD', N'', N'', GETDATE(), N'Conversion', 59
    UNION ALL SELECT  376, 2, 3, N'TIF District Creation', 1, N'', 0, 0, N'TIF Coord', N'PD', N'', N'', GETDATE(), N'Conversion', 58
    UNION ALL SELECT  377, 2, 3, N'TIF District Establishment or Modification', 1, N'For financial advisory services rendered in conjunction with the establishment or modification of a tax increment district.', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 78
    UNION ALL SELECT  378, 2, 3, N'TIF Reporting', 1, N'', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 68
    UNION ALL SELECT  379, 2, 3, N'TIF Reporting/OSA Non-Compliance Letters', 8, N'For financial advisory services provided to assist in or prepare annual TIF reports or responses to the OSA', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 70
    UNION ALL SELECT  380, 2, 3, N'TIF Status Reports/TIF Administration', 4, N'', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 69
    UNION ALL SELECT  381, 2, 3, N'TIF/Abatement Cashflows/Feasibility Analysis', 3, N'For financial advisory services provided to update performance and identify any changes in the TIF district related to the above project.', 0, 1, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 96
    UNION ALL SELECT  382, 3, 2, N'Budget Projection Model', 6, N'', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 116
    UNION ALL SELECT  383, 3, 3, N'Capital Funding Plan', 4, N'For financial advisory services in connection with the coordination and preparation of a capital funding plan', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 106
    UNION ALL SELECT  384, 3, 3, N'Capital Improvements Planning', 4, N'For financial advisory services in connection with the coordination and preparation of a capital improvements plan', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 32
    UNION ALL SELECT  385, 3, 3, N'Cash Flow Analysis', 8, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 29
    UNION ALL SELECT  386, 3, 3, N'Comparative Analysis', 6, N'', 0, 1, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 108
    UNION ALL SELECT  387, 3, 3, N'Feasibility Study ', 12, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 38
    UNION ALL SELECT  388, 3, 3, N'Financial Management Plan', 1, N'For financial advisory services in connection with the coordination and preparation of a financial management plan', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 30
    UNION ALL SELECT  389, 3, 3, N'Financial Planning', 6, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 24
    UNION ALL SELECT  390, 3, 3, N'Financial Policy Development', 3, N'For financial advisory services provided in assisting the governing board develop Financial Policies', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 99
    UNION ALL SELECT  391, 3, 3, N'Fiscal Impact Study/Analysis', 11, N'', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 37
    UNION ALL SELECT  392, 3, 3, N'General Consulting', 22, N'', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 80
    UNION ALL SELECT  393, 3, 3, N'Impact Fee Study/Analysis', 10, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 35
    UNION ALL SELECT  394, 3, 3, N'Key Financial Strategies', 9, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 31
    UNION ALL SELECT  395, 3, 3, N'Merger/Consolidation/Annexation', 2, N'For financial advisory services provided in connection with a merger / acquisition / annexation with _______________.', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 41
    UNION ALL SELECT  396, 3, 3, N'Operating Levy', 7, N'For Financial Advisory Services related to the Levy Referendum', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 26
    UNION ALL SELECT  397, 3, 3, N'Rate Study/Analysis', 2, N'For financial advisory services provided in connection with the preparation of a Rate Study and Analysis', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 36
    UNION ALL SELECT  398, 3, 3, N'Strategic Planning & Goal Setting', 5, N'For financial advisory services provided in connection with facilitating and summarizing goal setting sessions.', 0, 1, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 27
    UNION ALL SELECT  399, 4, 3, N'General Consulting', 1, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 79
    UNION ALL SELECT  400, 10, 3, N'Budget Preparation Assistance', 13, N'', 0, 1, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 39
    UNION ALL SELECT  401, 10, 3, N'Capital Projects Levy Assistance ', 12, N'For all financial advisory Services provided for the Capital Projects Levy', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 17
    UNION ALL SELECT  402, 10, 3, N'Community Communications/Newsletters/Annual Reports', 6, N'For financial advisory services provided in connection with preparation of public/citizen information and communications.', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 48
    UNION ALL SELECT  403, 10, 3, N'Enrollment Study', 11, N'For all financial advisory services provided in connection with the preparation and presentation of an enrollment study.', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 18
    UNION ALL SELECT  404, 10, 3, N'General Consulting', 99, N'', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 81
    UNION ALL SELECT  405, 10, 3, N'Grant Writing', 3, N'For all financial advisory services provided in connection with the preparation and presentation of an enrollment study.', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 100
    UNION ALL SELECT  406, 10, 3, N'Management Study', 8, N'For financial advisory services in connection with the preparation of a population study.', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 102
    UNION ALL SELECT  407, 10, 3, N'Population Study', 10, N'For financial advisory services in connection with the preparation of a population study.', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 20
    UNION ALL SELECT  408, 10, 3, N'Public Participation Process for Facilities/Redev.', 5, N'For all financial advisory services provided to create an educational process involving citizen input for the above project.', 0, 1, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 101
    UNION ALL SELECT  409, 10, 3, N'Referendum Strategies/Services', 7, N'For all financial advisory services provided in assistance with preparing public referendum communications materials.', 0, 1, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 88
    UNION ALL SELECT  410, 10, 3, N'Tax Abatement Analysis', 13, N'', 0, 0, N'', N'PD', N'', N'', GETDATE(), N'Conversion', 107
    UNION ALL SELECT  411, 10, 3, N'Truth in Taxation', 9, N'For financial advisory services in connection with preparation of Truth in Taxation Presentation.', 0, 0, N'FA/Batch', N'PD', N'', N'', GETDATE(), N'Conversion', 21
    UNION ALL SELECT  412, 10, 3, N'Yield Chart', 13, N'Consulting services rendered for development of the Community''s Yield Chart', 0, 0, N'FA', N'PD', N'', N'', GETDATE(), N'Conversion', 23  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ProjectService    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ProjectService OFF ;
    SET IDENTITY_INSERT dbo.StatAuthorityGroup ON ;

    INSERT  dbo.StatAuthorityGroup ( StatAuthorityGroupID, Value, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'IL', N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'MN - All', N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'MN City', N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'MN CO', N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'MN SD', N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'WI', N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'WI SD', N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.StatAuthorityGroup    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.StatAuthorityGroup OFF ;
    SET IDENTITY_INSERT dbo.StatAuthorityType ON ;

    INSERT  dbo.StatAuthorityType ( StatAuthorityTypeID, Value, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Alternate Revenue Source', N'Alternate Revenue Source - Section 15', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Library Limited Tax Debt Certificates ', N'Public Library District Act of 1991 of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Library Refunding Bonds', N'Public Library District Act of 1991 of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Park Alternate Revenue Bonds', N'Park District Code of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Park Limited Tax Bonds', N'Park District Code of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Park Refunding', N'Park District Code of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'G.O. Limited School Bonds', N'School Code of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  8, N'School Building Bonds', N'School Code of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  9, N'School Refunding Bonds', N'School Code of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  10, N'School Tax Anticipation Warrants', N'School Code of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  11, N'Refunding Bonds', N'Local Government Debt Reform Act of the State of Illinois', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  12, N'GO Capital Improvement Bonds - County 373.40', N'Section 373.40', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  13, N'G.O. Bonds - Chapter 475', N'Chapter 475', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  14, N'GO Capital Notes 373.01 Subsection3', N'Section 373.01 Subsection 3', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  15, N'GO Courthouse Bonds 375.18', N'Section 375.18', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  16, N'GO Ditch Bonds 103E', N'Chapter 103E', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  17, N'Gross Rev Healthcare Facilities Bonds 447', N'Chapter 447', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  18, N'GO Jail/Law Enforcement Bonds 641.23', N'Section 641.23', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  19, N'Nursing Home Bonds 376.56', N'Section 376.56', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  20, N'Public Project Revenue Bonds 469 & 641.24', N'Chapter 469 Section 641.24', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  21, N'GO Road Reconstruction Bonds 475.58', N'Section 475.58', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  22, N'GO Sewer and Water Revenue Bonds 444', N'Chapters 444', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  23, N'GO State-Aid Road Bonds 162.181', N'Section 162.181', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  24, N'GO Tax Abatement Bonds - County 469', N'Chapter 469', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  25, N'GO Watershed Improvement Bonds 103D & 103E', N'Chapters 103D and 103E', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  26, N'Annual Appropriation 469', N'Chapter 469', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  27, N'GO Capital Improvement Plan Bonds 475.521', N'Section 475.521', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  28, N'GO Capital Notes - City 410.32 & 412.301', N'Sections 410.32 and 412.301', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  29, N'Electric Revenue Bonds   453', N'Chapter 453', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  30, N'GO Equipment Certificates 412.301', N'Section 412.301', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  31, N'Housing Development Bonds 469', N'Chapter 469', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  32, N'GO Improvement Bonds 429', N'Chapter 429', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  33, N'GO Loan Anticipation Notes 444.075 & 475.61', N'Sections 444.075 and 475.61', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  34, N'Public Project Revenue Bonds - City 469 & 465.71', N'Chapter 469, Section 465.71', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  35, N'Public Utility Revenue Warrants 447.45 to 447.50', N'Sections 447.45 to 447.50', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  36, N'GO Revenue Bonds 444', N'Chapter 444', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  37, N'GO Street Reconstruction 475.58', N'Section 475.58', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  38, N'GO Sewer Revenue Bonds 444', N'Chapter 444', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  39, N'GO TAC''s 412.261', N'Section 412.261', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  40, N'GO Tax Abatement Bonds 469', N'Chapter 469', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  41, N'GO TIF Bonds 469', N'Chapter 469', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  42, N'GO AAC''s 126C.50 to 126C.56', N'Sections 126C.50 through 126C.56', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  43, N'GO Alt Fac Bonds 123B.59', N'Section 123B.59', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  44, N'GO School Building Bonds 475', N'Chapter 475', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  45, N'GO Cap Fac Bonds 123B.62', N'Section 123B.62', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  46, N'GO OPEB Bonds 475.52 ( 6 )', N'Section 475.52, Sub 6', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  47, N'GO School Bldg. Ref. Bonds 475.67', N'Section 475.67', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  48, N'CDA Lease Revenue Bonds 66.1333 & 66.1335', N'Sections 66.1333 and 66.1335', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  49, N'GO Ban''s  67.12( 1 )( b )', N'Section 67.12( 1 )( b )', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  50, N'GO Bonds 67.04', N'Section 67.04', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  51, N'GO Com Dev Bonds 67.04 & 66.1105', N'Sections 67.04 & 66.1105', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  52, N'GO Notes 67.12', N'Section 67.12', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  53, N'Revenue Ban''s 66.0621( 4 )( L )', N'Section 66.0621( 4 )( L )', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  54, N'Revenue Bonds 66.0621', N'Section 66.0621', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  55, N'Special Assessment "B" Bonds 66.0713', N'Section 66.0713', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  56, N'GO School Building Bonds 67.04', N'Section 67.04', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  57, N'TRAN''s 67.12( B )( a )1', N'Section 67.12( 8 )( a )1', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  58, N'Home Rule Powers', N'Home Rule Powers', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  59, N'Statutory Powers', N'Statutory Powers', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  60, N'Annual Appropriation - County 469', N'Chapter 469', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  61, N'GO Ice Arena Bonds 475', N'Chapter 475', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  62, N'GO PIR Fund Bonds 429', N'Chapter 429', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  63, N'GO Sewage Disposal Bonds 115 & 429', N'Chapters 115 and 429', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  64, N'GO Water Revenue Bonds 444', N'Chapter 444', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  65, N'GO TAC''s 126C.50 to 126C.56', N'Sections 126C.50 through 126C.56', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.StatAuthorityType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.StatAuthorityType OFF ;
    SET IDENTITY_INSERT dbo.StatAuthorityGroupTypes ON ;

    INSERT  dbo.StatAuthorityGroupTypes ( StatAuthorityGroupTypesID, StatAuthorityGroupID, StatAuthorityTypeID, DisplaySequence, ModifiedDate, ModifiedUser )  
    SELECT  1, 1, 1, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  2, 1, 2, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  3, 1, 3, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  4, 1, 4, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  5, 1, 5, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  6, 1, 6, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  7, 1, 7, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  8, 1, 8, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  9, 1, 9, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  10, 1, 10, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  11, 1, 11, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  12, 4, 12, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  13, 2, 13, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  14, 4, 14, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  15, 4, 15, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  16, 4, 16, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  17, 4, 17, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  18, 4, 18, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  19, 4, 19, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  20, 4, 20, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  21, 4, 21, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  22, 3, 22, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  23, 4, 23, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  24, 4, 24, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  25, 4, 25, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  26, 3, 26, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  27, 3, 27, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  28, 3, 28, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  29, 3, 29, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  30, 3, 30, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  31, 3, 31, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  32, 3, 32, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  33, 3, 33, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  34, 3, 34, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  35, 3, 35, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  36, 3, 36, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  37, 3, 37, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  38, 3, 38, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  39, 3, 39, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  40, 3, 40, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  41, 3, 41, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  42, 5, 42, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  43, 5, 43, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  44, 5, 44, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  45, 5, 45, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  46, 5, 46, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  47, 5, 47, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  48, 6, 48, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  49, 6, 49, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  50, 6, 50, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  51, 6, 51, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  52, 6, 52, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  53, 6, 53, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  54, 6, 54, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  55, 6, 55, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  56, 7, 56, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  57, 7, 57, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  58, 1, 58, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  59, 1, 59, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  60, 4, 60, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  61, 3, 61, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  62, 3, 62, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  63, 3, 63, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  64, 3, 64, 0, GETDATE(), N'Conversion'
    UNION ALL SELECT  65, 5, 65, 0, GETDATE(), N'Conversion'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.StatAuthorityGroupTypes    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.StatAuthorityGroupTypes OFF ;
    SET IDENTITY_INSERT dbo.States ON ;

    INSERT  dbo.States ( StatesID, Abbreviation, FullName, DisplaySequence )  
    SELECT  105, N'AK', N'Alaska', 10
    UNION ALL SELECT  106, N'AL', N'Alabama', 10
    UNION ALL SELECT  107, N'AR', N'Arkansas', 10
    UNION ALL SELECT  108, N'AZ', N'Arizona', 10
    UNION ALL SELECT  109, N'CA', N'California', 10
    UNION ALL SELECT  110, N'CO', N'Colorado', 10
    UNION ALL SELECT  111, N'CT', N'Connecticut', 10
    UNION ALL SELECT  112, N'DC', N'District of Columbia', 10
    UNION ALL SELECT  113, N'DE', N'Delaware', 10
    UNION ALL SELECT  114, N'FL', N'Florida', 10
    UNION ALL SELECT  115, N'GA', N'Georgia', 10
    UNION ALL SELECT  116, N'HI', N'Hawaii', 10
    UNION ALL SELECT  117, N'IA', N'Iowa', 10
    UNION ALL SELECT  118, N'ID', N'Idaho', 10
    UNION ALL SELECT  119, N'IL', N'Illinois', 3
    UNION ALL SELECT  120, N'IN', N'Indiana', 10
    UNION ALL SELECT  121, N'KS', N'Kansas', 4
    UNION ALL SELECT  122, N'KY', N'Kentucky', 10
    UNION ALL SELECT  123, N'LA', N'Louisiana', 10
    UNION ALL SELECT  124, N'MA', N'Massachusetts', 10
    UNION ALL SELECT  125, N'MD', N'Maryland', 10
    UNION ALL SELECT  126, N'ME', N'Maine', 10
    UNION ALL SELECT  127, N'MI', N'Michigan', 10
    UNION ALL SELECT  128, N'MN', N'Minnesota', 1
    UNION ALL SELECT  129, N'MO', N'Missouri', 10
    UNION ALL SELECT  130, N'MS', N'Mississippi', 10
    UNION ALL SELECT  131, N'MT', N'Montana', 10
    UNION ALL SELECT  132, N'NA', N'NA', 99
    UNION ALL SELECT  133, N'NC', N'North Carolina', 10
    UNION ALL SELECT  134, N'ND', N'North Dakota', 10
    UNION ALL SELECT  135, N'NE', N'Nebraska', 10
    UNION ALL SELECT  136, N'NH', N'New Hampshire', 10
    UNION ALL SELECT  137, N'NJ', N'New Jersey', 10
    UNION ALL SELECT  138, N'NM', N'New Mexico', 10
    UNION ALL SELECT  139, N'NV', N'Nevada', 10
    UNION ALL SELECT  140, N'NY', N'New York', 10
    UNION ALL SELECT  141, N'OH', N'Ohio', 10
    UNION ALL SELECT  142, N'OK', N'Oklahoma', 10
    UNION ALL SELECT  143, N'OR', N'Oregon', 10
    UNION ALL SELECT  144, N'PA', N'Pennsylvania', 10
    UNION ALL SELECT  145, N'RI', N'Rhode Island', 10
    UNION ALL SELECT  146, N'SC', N'South Carolina', 10
    UNION ALL SELECT  147, N'SD', N'South Dakota', 10
    UNION ALL SELECT  148, N'TN', N'Tennessee', 10
    UNION ALL SELECT  149, N'TX', N'Texas', 10
    UNION ALL SELECT  150, N'UT', N'Utah', 10
    UNION ALL SELECT  151, N'VA', N'Virginia', 10
    UNION ALL SELECT  152, N'VT', N'Vermont', 10
    UNION ALL SELECT  153, N'WA', N'Washington', 10
    UNION ALL SELECT  154, N'WI', N'Wisconsin', 2
    UNION ALL SELECT  155, N'WV', N'West Virginia', 10
    UNION ALL SELECT  156, N'WY', N'Wyoming', 10  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.States    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.States OFF ;
    SET IDENTITY_INSERT dbo.County ON ;

    INSERT  dbo.County ( CountyID, Name )  
    SELECT  1209, N'Adair'
    UNION ALL SELECT  1210, N'Adams'
    UNION ALL SELECT  1211, N'Aitkin'
    UNION ALL SELECT  1212, N'Alexander'
    UNION ALL SELECT  1213, N'Allamakee'
    UNION ALL SELECT  1214, N'Allen'
    UNION ALL SELECT  1215, N'Anderson'
    UNION ALL SELECT  1216, N'Anoka'
    UNION ALL SELECT  1217, N'Appanoose'
    UNION ALL SELECT  1218, N'Ashland'
    UNION ALL SELECT  1219, N'Atchison'
    UNION ALL SELECT  1220, N'Audubon'
    UNION ALL SELECT  1221, N'Barber'
    UNION ALL SELECT  1222, N'Barron'
    UNION ALL SELECT  1223, N'Barton'
    UNION ALL SELECT  1224, N'Bayfield'
    UNION ALL SELECT  1225, N'Becker'
    UNION ALL SELECT  1226, N'Beltrami'
    UNION ALL SELECT  1227, N'Belvidere'
    UNION ALL SELECT  1228, N'Benton'
    UNION ALL SELECT  1229, N'Big Stone'
    UNION ALL SELECT  1230, N'Black Hawk'
    UNION ALL SELECT  1231, N'Blue Earth'
    UNION ALL SELECT  1232, N'Bond'
    UNION ALL SELECT  1233, N'Boone'
    UNION ALL SELECT  1234, N'Bourbon'
    UNION ALL SELECT  1235, N'Bremer'
    UNION ALL SELECT  1236, N'Brown'
    UNION ALL SELECT  1237, N'Buchanan'
    UNION ALL SELECT  1238, N'Buena Vista'
    UNION ALL SELECT  1239, N'Buffalo'
    UNION ALL SELECT  1240, N'Bureau'
    UNION ALL SELECT  1241, N'Burnett'
    UNION ALL SELECT  1242, N'Butler'
    UNION ALL SELECT  1243, N'Calhoun'
    UNION ALL SELECT  1244, N'Calumet'
    UNION ALL SELECT  1245, N'Carlton'
    UNION ALL SELECT  1246, N'Carroll'
    UNION ALL SELECT  1247, N'Carver'
    UNION ALL SELECT  1248, N'Cass'
    UNION ALL SELECT  1249, N'Cedar'
    UNION ALL SELECT  1250, N'Cerro Gordo'
    UNION ALL SELECT  1251, N'Champaign'
    UNION ALL SELECT  1252, N'Chase'
    UNION ALL SELECT  1253, N'Chautauqua'
    UNION ALL SELECT  1254, N'Cherokee'
    UNION ALL SELECT  1255, N'Cheyenne'
    UNION ALL SELECT  1256, N'Chickasaw'
    UNION ALL SELECT  1257, N'Chippewa'
    UNION ALL SELECT  1258, N'Chisago'
    UNION ALL SELECT  1259, N'Christian'
    UNION ALL SELECT  1260, N'Clark'
    UNION ALL SELECT  1261, N'Clarke'
    UNION ALL SELECT  1262, N'Clay'
    UNION ALL SELECT  1263, N'Clayton'
    UNION ALL SELECT  1264, N'Clearwater'
    UNION ALL SELECT  1265, N'Clinton'
    UNION ALL SELECT  1266, N'Cloud'
    UNION ALL SELECT  1267, N'Coffey'
    UNION ALL SELECT  1268, N'Coles'
    UNION ALL SELECT  1269, N'Columbia'
    UNION ALL SELECT  1270, N'Comanche'
    UNION ALL SELECT  1271, N'Cook'
    UNION ALL SELECT  1272, N'Cottonwood'
    UNION ALL SELECT  1273, N'Cowley'
    UNION ALL SELECT  1274, N'Crawford'
    UNION ALL SELECT  1275, N'Crow Wing'
    UNION ALL SELECT  1276, N'Cumberland'
    UNION ALL SELECT  1277, N'Dakota'
    UNION ALL SELECT  1278, N'Dallas'
    UNION ALL SELECT  1279, N'Dane'
    UNION ALL SELECT  1280, N'Davis'
    UNION ALL SELECT  1281, N'De Witt'
    UNION ALL SELECT  1282, N'Decatur'
    UNION ALL SELECT  1283, N'DeKalb'
    UNION ALL SELECT  1284, N'Delaware'
    UNION ALL SELECT  1285, N'Des Moines'
    UNION ALL SELECT  1286, N'Dickinson'
    UNION ALL SELECT  1287, N'Dodge'
    UNION ALL SELECT  1288, N'Doniphan'
    UNION ALL SELECT  1289, N'Door'
    UNION ALL SELECT  1290, N'Douglas'
    UNION ALL SELECT  1291, N'Dubuque'
    UNION ALL SELECT  1292, N'Dunn'
    UNION ALL SELECT  1293, N'DuPage'
    UNION ALL SELECT  1294, N'Eau Claire'
    UNION ALL SELECT  1295, N'Edgar'
    UNION ALL SELECT  1296, N'Edwards'
    UNION ALL SELECT  1297, N'Effingham'
    UNION ALL SELECT  1298, N'Elk'
    UNION ALL SELECT  1299, N'Ellis'
    UNION ALL SELECT  1300, N'Ellsworth'
    UNION ALL SELECT  1301, N'Emmet'
    UNION ALL SELECT  1302, N'Faribault'
    UNION ALL SELECT  1303, N'Fayette'
    UNION ALL SELECT  1304, N'Fillmore'
    UNION ALL SELECT  1305, N'Finney'
    UNION ALL SELECT  1306, N'Florence'
    UNION ALL SELECT  1307, N'Floyd'
    UNION ALL SELECT  1308, N'Fond du Lac'
    UNION ALL SELECT  1309, N'Ford'
    UNION ALL SELECT  1310, N'Forest'
    UNION ALL SELECT  1311, N'Franklin'
    UNION ALL SELECT  1312, N'Freeborn'
    UNION ALL SELECT  1313, N'Fremont'
    UNION ALL SELECT  1314, N'Fulton'
    UNION ALL SELECT  1315, N'Gallatin'
    UNION ALL SELECT  1316, N'Geary'
    UNION ALL SELECT  1317, N'Goodhue'
    UNION ALL SELECT  1318, N'Gove'
    UNION ALL SELECT  1319, N'Graham'
    UNION ALL SELECT  1320, N'Grant'
    UNION ALL SELECT  1321, N'Gray'
    UNION ALL SELECT  1322, N'Greeley'
    UNION ALL SELECT  1323, N'Green'
    UNION ALL SELECT  1324, N'Green Lake'
    UNION ALL SELECT  1325, N'Greene'
    UNION ALL SELECT  1326, N'Greenwood'
    UNION ALL SELECT  1327, N'Grundy'
    UNION ALL SELECT  1328, N'Guthrie'
    UNION ALL SELECT  1329, N'Hamilton'
    UNION ALL SELECT  1330, N'Hancock'
    UNION ALL SELECT  1331, N'Hardin'
    UNION ALL SELECT  1332, N'Harper'
    UNION ALL SELECT  1333, N'Harrison'
    UNION ALL SELECT  1334, N'Harvey'
    UNION ALL SELECT  1335, N'Haskell'
    UNION ALL SELECT  1336, N'Henderson'
    UNION ALL SELECT  1337, N'Hennepin'
    UNION ALL SELECT  1338, N'Henry'
    UNION ALL SELECT  1339, N'Hodgeman'
    UNION ALL SELECT  1340, N'Houston'
    UNION ALL SELECT  1341, N'Howard'
    UNION ALL SELECT  1342, N'Hubbard'
    UNION ALL SELECT  1343, N'Humboldt'
    UNION ALL SELECT  1344, N'Ida'
    UNION ALL SELECT  1345, N'Iowa'
    UNION ALL SELECT  1346, N'Iron'
    UNION ALL SELECT  1347, N'Iroquois'
    UNION ALL SELECT  1348, N'Isanti'
    UNION ALL SELECT  1349, N'Itasca'
    UNION ALL SELECT  1350, N'Jackson'
    UNION ALL SELECT  1351, N'Jasper'
    UNION ALL SELECT  1352, N'Jefferson'
    UNION ALL SELECT  1353, N'Jersey'
    UNION ALL SELECT  1354, N'Jewell'
    UNION ALL SELECT  1355, N'Jo Daviess'
    UNION ALL SELECT  1356, N'Johnson'
    UNION ALL SELECT  1357, N'Jones'
    UNION ALL SELECT  1358, N'Juneau'
    UNION ALL SELECT  1359, N'Kanabec'
    UNION ALL SELECT  1360, N'Kandiyohi'
    UNION ALL SELECT  1361, N'Kane'
    UNION ALL SELECT  1362, N'Kankakee'
    UNION ALL SELECT  1363, N'Kearny'
    UNION ALL SELECT  1364, N'Kendall'
    UNION ALL SELECT  1365, N'Kenosha'
    UNION ALL SELECT  1366, N'Keokuk'
    UNION ALL SELECT  1367, N'Kewaunee'
    UNION ALL SELECT  1368, N'Kingman'
    UNION ALL SELECT  1369, N'Kiowa'
    UNION ALL SELECT  1370, N'Kittson'
    UNION ALL SELECT  1371, N'Knox'
    UNION ALL SELECT  1372, N'Koochiching'
    UNION ALL SELECT  1373, N'Kossuth'
    UNION ALL SELECT  1374, N'La Crosse'
    UNION ALL SELECT  1375, N'Labette'
    UNION ALL SELECT  1376, N'Lac Qui Parle'
    UNION ALL SELECT  1377, N'Lafayette'
    UNION ALL SELECT  1378, N'Lake'
    UNION ALL SELECT  1379, N'Lake Of The Woods'
    UNION ALL SELECT  1380, N'Lane'
    UNION ALL SELECT  1381, N'Langlade'
    UNION ALL SELECT  1382, N'LaSalle'
    UNION ALL SELECT  1383, N'Lawrence'
    UNION ALL SELECT  1384, N'Le Sueur'
    UNION ALL SELECT  1385, N'Leavenworth'
    UNION ALL SELECT  1386, N'Lee'
    UNION ALL SELECT  1387, N'Lincoln'
    UNION ALL SELECT  1388, N'Linn'
    UNION ALL SELECT  1389, N'Livingston'
    UNION ALL SELECT  1390, N'Logan'
    UNION ALL SELECT  1391, N'Louisa'
    UNION ALL SELECT  1392, N'Lucas'
    UNION ALL SELECT  1393, N'Lyon'
    UNION ALL SELECT  1394, N'Macon'
    UNION ALL SELECT  1395, N'Macoupin'
    UNION ALL SELECT  1396, N'Madison'
    UNION ALL SELECT  1397, N'Mahaska'
    UNION ALL SELECT  1398, N'Mahnomen'
    UNION ALL SELECT  1399, N'Manitowoc'
    UNION ALL SELECT  1400, N'Marathon'
    UNION ALL SELECT  1401, N'Marinette'
    UNION ALL SELECT  1402, N'Marion'
    UNION ALL SELECT  1403, N'Marquette'
    UNION ALL SELECT  1404, N'Marshall'
    UNION ALL SELECT  1405, N'Martin'
    UNION ALL SELECT  1406, N'Mason'
    UNION ALL SELECT  1407, N'Massac'
    UNION ALL SELECT  1408, N'McDonough'
    UNION ALL SELECT  1409, N'McHenry'
    UNION ALL SELECT  1410, N'McLean'
    UNION ALL SELECT  1411, N'McLeod'
    UNION ALL SELECT  1412, N'McPherson'
    UNION ALL SELECT  1413, N'Meade'
    UNION ALL SELECT  1414, N'Meeker'
    UNION ALL SELECT  1415, N'Menard'
    UNION ALL SELECT  1416, N'Menominee'
    UNION ALL SELECT  1417, N'Mercer'
    UNION ALL SELECT  1418, N'Miami'
    UNION ALL SELECT  1419, N'Mille Lacs'
    UNION ALL SELECT  1420, N'Mills'
    UNION ALL SELECT  1421, N'Milwaukee'
    UNION ALL SELECT  1422, N'Mitchell'
    UNION ALL SELECT  1423, N'Monona'
    UNION ALL SELECT  1424, N'Monroe'
    UNION ALL SELECT  1425, N'Montgomery'
    UNION ALL SELECT  1426, N'Morgan'
    UNION ALL SELECT  1427, N'Morris'
    UNION ALL SELECT  1428, N'Morrison'
    UNION ALL SELECT  1429, N'Morton'
    UNION ALL SELECT  1430, N'Moultrie'
    UNION ALL SELECT  1431, N'Mower'
    UNION ALL SELECT  1432, N'Murray'
    UNION ALL SELECT  1433, N'Muscatine'
    UNION ALL SELECT  1434, N'Nemaha'
    UNION ALL SELECT  1435, N'Neosho'
    UNION ALL SELECT  1436, N'Ness'
    UNION ALL SELECT  1437, N'Nicollet'
    UNION ALL SELECT  1438, N'Nobles'
    UNION ALL SELECT  1439, N'Norman'
    UNION ALL SELECT  1440, N'Norton'
    UNION ALL SELECT  1441, N'O''Brien'
    UNION ALL SELECT  1442, N'Oconto'
    UNION ALL SELECT  1443, N'Ogle'
    UNION ALL SELECT  1444, N'Olmsted'
    UNION ALL SELECT  1445, N'Oneida'
    UNION ALL SELECT  1446, N'Osage'
    UNION ALL SELECT  1447, N'Osborne'
    UNION ALL SELECT  1448, N'Osceola'
    UNION ALL SELECT  1449, N'Ottawa'
    UNION ALL SELECT  1450, N'Otter Tail'
    UNION ALL SELECT  1451, N'Outagamie'
    UNION ALL SELECT  1452, N'Ozaukee'
    UNION ALL SELECT  1453, N'Page'
    UNION ALL SELECT  1454, N'Palo Alto'
    UNION ALL SELECT  1455, N'Pawnee'
    UNION ALL SELECT  1456, N'Pennington'
    UNION ALL SELECT  1457, N'Peoria'
    UNION ALL SELECT  1458, N'Pepin'
    UNION ALL SELECT  1459, N'Perry'
    UNION ALL SELECT  1460, N'Phillips'
    UNION ALL SELECT  1461, N'Piatt'
    UNION ALL SELECT  1462, N'Pierce'
    UNION ALL SELECT  1463, N'Pike'
    UNION ALL SELECT  1464, N'Pine'
    UNION ALL SELECT  1465, N'Pipestone'
    UNION ALL SELECT  1466, N'Plymouth'
    UNION ALL SELECT  1467, N'Pocahontas'
    UNION ALL SELECT  1468, N'Polk'
    UNION ALL SELECT  1469, N'Pope'
    UNION ALL SELECT  1470, N'Portage'
    UNION ALL SELECT  1471, N'Pottawatomie'
    UNION ALL SELECT  1472, N'Pottawattamie'
    UNION ALL SELECT  1473, N'Poweshiek'
    UNION ALL SELECT  1474, N'Pratt'
    UNION ALL SELECT  1475, N'Price'
    UNION ALL SELECT  1476, N'Pulaski'
    UNION ALL SELECT  1477, N'Putnam'
    UNION ALL SELECT  1478, N'Racine'
    UNION ALL SELECT  1479, N'Ramsey'
    UNION ALL SELECT  1480, N'Randolph'
    UNION ALL SELECT  1481, N'Rawlins'
    UNION ALL SELECT  1482, N'Red Lake'
    UNION ALL SELECT  1483, N'Redwood'
    UNION ALL SELECT  1484, N'Reno'
    UNION ALL SELECT  1485, N'Renville'
    UNION ALL SELECT  1486, N'Republic'
    UNION ALL SELECT  1487, N'Rice'
    UNION ALL SELECT  1488, N'Richland'
    UNION ALL SELECT  1489, N'Riley'
    UNION ALL SELECT  1490, N'Ringgold'
    UNION ALL SELECT  1491, N'Rock'
    UNION ALL SELECT  1492, N'Rock Island'
    UNION ALL SELECT  1493, N'Rooks'
    UNION ALL SELECT  1494, N'Roseau'
    UNION ALL SELECT  1495, N'Rush'
    UNION ALL SELECT  1496, N'Rusk'
    UNION ALL SELECT  1497, N'Russell'
    UNION ALL SELECT  1498, N'Sac'
    UNION ALL SELECT  1499, N'Saline'
    UNION ALL SELECT  1500, N'Sangamon'
    UNION ALL SELECT  1501, N'Sauk'
    UNION ALL SELECT  1502, N'Sawyer'
    UNION ALL SELECT  1503, N'Schuyler'
    UNION ALL SELECT  1504, N'Scott'
    UNION ALL SELECT  1505, N'Sedgwick'
    UNION ALL SELECT  1506, N'Seward'
    UNION ALL SELECT  1507, N'Shawano'
    UNION ALL SELECT  1508, N'Shawnee'
    UNION ALL SELECT  1509, N'Sheboygan'
    UNION ALL SELECT  1510, N'Shelby'
    UNION ALL SELECT  1511, N'Sherburne'
    UNION ALL SELECT  1512, N'Sheridan'
    UNION ALL SELECT  1513, N'Sherman'
    UNION ALL SELECT  1514, N'Sibley'
    UNION ALL SELECT  1515, N'Sioux'
    UNION ALL SELECT  1516, N'Smith'
    UNION ALL SELECT  1517, N'St Louis'
    UNION ALL SELECT  1518, N'St. Clair'
    UNION ALL SELECT  1519, N'St. Croix'
    UNION ALL SELECT  1520, N'Stafford'
    UNION ALL SELECT  1521, N'Stanton'
    UNION ALL SELECT  1522, N'Stark'
    UNION ALL SELECT  1523, N'Stearns'
    UNION ALL SELECT  1524, N'Steele'
    UNION ALL SELECT  1525, N'Stephenson'
    UNION ALL SELECT  1526, N'Stevens'
    UNION ALL SELECT  1527, N'Story'
    UNION ALL SELECT  1528, N'Sumner'
    UNION ALL SELECT  1529, N'Swift'
    UNION ALL SELECT  1530, N'Tama'
    UNION ALL SELECT  1531, N'Taylor'
    UNION ALL SELECT  1532, N'Tazewell'
    UNION ALL SELECT  1533, N'Thomas'
    UNION ALL SELECT  1534, N'Todd'
    UNION ALL SELECT  1535, N'Traverse'
    UNION ALL SELECT  1536, N'Trego'
    UNION ALL SELECT  1537, N'Trempealeau'
    UNION ALL SELECT  1538, N'Union'
    UNION ALL SELECT  1539, N'Van Buren'
    UNION ALL SELECT  1540, N'Vermilion'
    UNION ALL SELECT  1541, N'Vernon'
    UNION ALL SELECT  1542, N'Vilas'
    UNION ALL SELECT  1543, N'Wabash'
    UNION ALL SELECT  1544, N'Wabasha'
    UNION ALL SELECT  1545, N'Wabaunsee'
    UNION ALL SELECT  1546, N'Wadena'
    UNION ALL SELECT  1547, N'Wallace'
    UNION ALL SELECT  1548, N'Walworth'
    UNION ALL SELECT  1549, N'Wapello'
    UNION ALL SELECT  1550, N'Warren'
    UNION ALL SELECT  1551, N'Waseca'
    UNION ALL SELECT  1552, N'Washburn'
    UNION ALL SELECT  1553, N'Washington'
    UNION ALL SELECT  1554, N'Wassac'
    UNION ALL SELECT  1555, N'Watonwan'
    UNION ALL SELECT  1556, N'Waukesha'
    UNION ALL SELECT  1557, N'Waupaca'
    UNION ALL SELECT  1558, N'Waushara'
    UNION ALL SELECT  1559, N'Wayne'
    UNION ALL SELECT  1560, N'Webster'
    UNION ALL SELECT  1561, N'White'
    UNION ALL SELECT  1562, N'Whiteside'
    UNION ALL SELECT  1563, N'Wichita'
    UNION ALL SELECT  1564, N'Wilkin'
    UNION ALL SELECT  1565, N'Will'
    UNION ALL SELECT  1566, N'Williamson'
    UNION ALL SELECT  1567, N'Wilson'
    UNION ALL SELECT  1568, N'Winnebago'
    UNION ALL SELECT  1569, N'Winnesheik'
    UNION ALL SELECT  1570, N'Winona'
    UNION ALL SELECT  1571, N'Wood'
    UNION ALL SELECT  1572, N'Woodbury'
    UNION ALL SELECT  1573, N'Woodford'
    UNION ALL SELECT  1574, N'Woodson'
    UNION ALL SELECT  1575, N'Worth'
    UNION ALL SELECT  1576, N'Wright'
    UNION ALL SELECT  1577, N'Wyandotte'
    UNION ALL SELECT  1578, N'Yellow Medicine'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.County    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.County OFF ;
    SET IDENTITY_INSERT dbo.StatesCounties ON ;

    INSERT  dbo.StatesCounties ( StatesCountiesID, CountyID, StatesID, OldKeyID )  
    SELECT  935, 1209, 117, N'054-002'
    UNION ALL SELECT  936, 1210, 117, N'054-003'
    UNION ALL SELECT  937, 1210, 154, N'054-292'
    UNION ALL SELECT  938, 1210, 119, N'054-101'
    UNION ALL SELECT  939, 1211, 128, N'054-204'
    UNION ALL SELECT  940, 1212, 119, N'054-102'
    UNION ALL SELECT  941, 1213, 117, N'054-004'
    UNION ALL SELECT  942, 1214, 121, N'054-366'
    UNION ALL SELECT  943, 1215, 121, N'054-367'
    UNION ALL SELECT  944, 1216, 128, N'054-205'
    UNION ALL SELECT  945, 1217, 117, N'054-005'
    UNION ALL SELECT  946, 1218, 154, N'054-293'
    UNION ALL SELECT  947, 1219, 121, N'054-368'
    UNION ALL SELECT  948, 1220, 117, N'054-006'
    UNION ALL SELECT  949, 1221, 121, N'054-369'
    UNION ALL SELECT  950, 1222, 154, N'054-294'
    UNION ALL SELECT  951, 1223, 121, N'054-370'
    UNION ALL SELECT  952, 1224, 154, N'054-295'
    UNION ALL SELECT  953, 1225, 128, N'054-206'
    UNION ALL SELECT  954, 1226, 128, N'054-207'
    UNION ALL SELECT  955, 1227, 119, N'054-364'
    UNION ALL SELECT  956, 1228, 128, N'054-208'
    UNION ALL SELECT  957, 1228, 117, N'054-007'
    UNION ALL SELECT  958, 1229, 128, N'054-209'
    UNION ALL SELECT  959, 1230, 117, N'054-008'
    UNION ALL SELECT  960, 1231, 128, N'054-210'
    UNION ALL SELECT  961, 1232, 119, N'054-103'
    UNION ALL SELECT  962, 1233, 119, N'054-104'
    UNION ALL SELECT  963, 1233, 117, N'054-009'
    UNION ALL SELECT  964, 1234, 121, N'054-371'
    UNION ALL SELECT  965, 1235, 117, N'054-010'
    UNION ALL SELECT  966, 1236, 128, N'054-211'
    UNION ALL SELECT  967, 1236, 154, N'054-296'
    UNION ALL SELECT  968, 1236, 121, N'054-372'
    UNION ALL SELECT  969, 1236, 119, N'054-105'
    UNION ALL SELECT  970, 1237, 117, N'054-011'
    UNION ALL SELECT  971, 1238, 117, N'054-012'
    UNION ALL SELECT  972, 1239, 154, N'054-297'
    UNION ALL SELECT  973, 1240, 119, N'054-106'
    UNION ALL SELECT  974, 1241, 154, N'054-298'
    UNION ALL SELECT  975, 1242, 117, N'054-013'
    UNION ALL SELECT  976, 1242, 121, N'054-373'
    UNION ALL SELECT  977, 1243, 119, N'054-107'
    UNION ALL SELECT  978, 1243, 117, N'054-014'
    UNION ALL SELECT  979, 1244, 154, N'054-299'
    UNION ALL SELECT  980, 1245, 128, N'054-212'
    UNION ALL SELECT  981, 1246, 117, N'054-015'
    UNION ALL SELECT  982, 1246, 119, N'054-108'
    UNION ALL SELECT  983, 1247, 128, N'054-213'
    UNION ALL SELECT  984, 1248, 128, N'054-214'
    UNION ALL SELECT  985, 1248, 117, N'054-016'
    UNION ALL SELECT  986, 1248, 119, N'054-109'
    UNION ALL SELECT  987, 1249, 117, N'054-017'
    UNION ALL SELECT  988, 1250, 117, N'054-018'
    UNION ALL SELECT  989, 1251, 119, N'054-110'
    UNION ALL SELECT  990, 1252, 121, N'054-374'
    UNION ALL SELECT  991, 1253, 121, N'054-375'
    UNION ALL SELECT  992, 1254, 121, N'054-376'
    UNION ALL SELECT  993, 1254, 117, N'054-019'
    UNION ALL SELECT  994, 1255, 121, N'054-377'
    UNION ALL SELECT  995, 1256, 117, N'054-020'
    UNION ALL SELECT  996, 1257, 128, N'054-215'
    UNION ALL SELECT  997, 1257, 154, N'054-300'
    UNION ALL SELECT  998, 1258, 128, N'054-216'
    UNION ALL SELECT  999, 1259, 119, N'054-111'
    UNION ALL SELECT  1000, 1260, 119, N'054-112'
    UNION ALL SELECT  1001, 1260, 121, N'054-378'
    UNION ALL SELECT  1002, 1260, 154, N'054-301'
    UNION ALL SELECT  1003, 1261, 117, N'054-021'
    UNION ALL SELECT  1004, 1262, 117, N'054-022'
    UNION ALL SELECT  1005, 1262, 128, N'054-217'
    UNION ALL SELECT  1006, 1262, 121, N'054-379'
    UNION ALL SELECT  1007, 1262, 119, N'054-113'
    UNION ALL SELECT  1008, 1263, 117, N'054-023'
    UNION ALL SELECT  1009, 1264, 128, N'054-218'
    UNION ALL SELECT  1010, 1265, 117, N'054-024'
    UNION ALL SELECT  1011, 1265, 119, N'054-114'
    UNION ALL SELECT  1012, 1266, 121, N'054-380'
    UNION ALL SELECT  1013, 1267, 121, N'054-381'
    UNION ALL SELECT  1014, 1268, 119, N'054-115'
    UNION ALL SELECT  1015, 1269, 154, N'054-302'
    UNION ALL SELECT  1016, 1270, 121, N'054-382'
    UNION ALL SELECT  1017, 1271, 119, N'054-116'
    UNION ALL SELECT  1018, 1271, 128, N'054-219'
    UNION ALL SELECT  1019, 1272, 128, N'054-220'
    UNION ALL SELECT  1020, 1273, 121, N'054-383'
    UNION ALL SELECT  1021, 1274, 121, N'054-384'
    UNION ALL SELECT  1022, 1274, 119, N'054-117'
    UNION ALL SELECT  1023, 1274, 154, N'054-303'
    UNION ALL SELECT  1024, 1274, 117, N'054-025'
    UNION ALL SELECT  1025, 1275, 128, N'054-221'
    UNION ALL SELECT  1026, 1276, 119, N'054-118'
    UNION ALL SELECT  1027, 1277, 128, N'054-222'
    UNION ALL SELECT  1028, 1278, 117, N'054-026'
    UNION ALL SELECT  1029, 1279, 154, N'054-304'
    UNION ALL SELECT  1030, 1280, 117, N'054-027'
    UNION ALL SELECT  1031, 1281, 119, N'054-120'
    UNION ALL SELECT  1032, 1282, 117, N'054-028'
    UNION ALL SELECT  1033, 1282, 121, N'054-385'
    UNION ALL SELECT  1034, 1283, 119, N'054-119'
    UNION ALL SELECT  1035, 1284, 117, N'054-029'
    UNION ALL SELECT  1036, 1285, 117, N'054-030'
    UNION ALL SELECT  1037, 1286, 117, N'054-031'
    UNION ALL SELECT  1038, 1286, 121, N'054-386'
    UNION ALL SELECT  1039, 1287, 154, N'054-305'
    UNION ALL SELECT  1040, 1287, 128, N'054-223'
    UNION ALL SELECT  1041, 1288, 121, N'054-387'
    UNION ALL SELECT  1042, 1289, 154, N'054-306'
    UNION ALL SELECT  1043, 1290, 154, N'054-307'
    UNION ALL SELECT  1044, 1290, 128, N'054-224'
    UNION ALL SELECT  1045, 1290, 119, N'054-121'
    UNION ALL SELECT  1046, 1290, 121, N'054-388'
    UNION ALL SELECT  1047, 1291, 117, N'054-032'
    UNION ALL SELECT  1048, 1292, 154, N'054-308'
    UNION ALL SELECT  1049, 1293, 119, N'054-122'
    UNION ALL SELECT  1050, 1294, 154, N'054-309'
    UNION ALL SELECT  1051, 1295, 119, N'054-123'
    UNION ALL SELECT  1052, 1296, 119, N'054-124'
    UNION ALL SELECT  1053, 1296, 121, N'054-389'
    UNION ALL SELECT  1054, 1297, 119, N'054-125'
    UNION ALL SELECT  1055, 1298, 121, N'054-390'
    UNION ALL SELECT  1056, 1299, 121, N'054-391'
    UNION ALL SELECT  1057, 1300, 121, N'054-392'
    UNION ALL SELECT  1058, 1301, 117, N'054-033'
    UNION ALL SELECT  1059, 1302, 128, N'054-225'
    UNION ALL SELECT  1060, 1303, 117, N'054-034'
    UNION ALL SELECT  1061, 1303, 119, N'054-126'
    UNION ALL SELECT  1062, 1304, 128, N'054-226'
    UNION ALL SELECT  1063, 1305, 121, N'054-393'
    UNION ALL SELECT  1064, 1306, 154, N'054-310'
    UNION ALL SELECT  1065, 1307, 117, N'054-035'
    UNION ALL SELECT  1066, 1308, 154, N'054-311'
    UNION ALL SELECT  1067, 1309, 119, N'054-127'
    UNION ALL SELECT  1068, 1309, 121, N'054-394'
    UNION ALL SELECT  1069, 1310, 154, N'054-312'
    UNION ALL SELECT  1070, 1311, 119, N'054-128'
    UNION ALL SELECT  1071, 1311, 117, N'054-036'
    UNION ALL SELECT  1072, 1311, 121, N'054-395'
    UNION ALL SELECT  1073, 1312, 128, N'054-227'
    UNION ALL SELECT  1074, 1313, 117, N'054-037'
    UNION ALL SELECT  1075, 1314, 119, N'054-129'
    UNION ALL SELECT  1076, 1315, 119, N'054-130'
    UNION ALL SELECT  1077, 1316, 121, N'054-396'
    UNION ALL SELECT  1078, 1317, 128, N'054-228'
    UNION ALL SELECT  1079, 1318, 121, N'054-397'
    UNION ALL SELECT  1080, 1319, 121, N'054-398'
    UNION ALL SELECT  1081, 1320, 121, N'054-399'
    UNION ALL SELECT  1082, 1320, 128, N'054-229'
    UNION ALL SELECT  1083, 1320, 154, N'054-313'
    UNION ALL SELECT  1084, 1321, 121, N'054-400'
    UNION ALL SELECT  1085, 1322, 121, N'054-401'
    UNION ALL SELECT  1086, 1323, 154, N'054-314'
    UNION ALL SELECT  1087, 1324, 154, N'054-315'
    UNION ALL SELECT  1088, 1325, 119, N'054-131'
    UNION ALL SELECT  1089, 1325, 117, N'054-038'
    UNION ALL SELECT  1090, 1326, 121, N'054-402'
    UNION ALL SELECT  1091, 1327, 117, N'054-039'
    UNION ALL SELECT  1092, 1327, 119, N'054-132'
    UNION ALL SELECT  1093, 1328, 117, N'054-040'
    UNION ALL SELECT  1094, 1329, 117, N'054-041'
    UNION ALL SELECT  1095, 1329, 119, N'054-133'
    UNION ALL SELECT  1096, 1329, 121, N'054-403'
    UNION ALL SELECT  1097, 1330, 119, N'054-134'
    UNION ALL SELECT  1098, 1330, 117, N'054-042'
    UNION ALL SELECT  1099, 1331, 117, N'054-043'
    UNION ALL SELECT  1100, 1331, 119, N'054-135'
    UNION ALL SELECT  1101, 1332, 121, N'054-404'
    UNION ALL SELECT  1102, 1333, 117, N'054-044'
    UNION ALL SELECT  1103, 1334, 121, N'054-405'
    UNION ALL SELECT  1104, 1335, 121, N'054-406'
    UNION ALL SELECT  1105, 1336, 119, N'054-136'
    UNION ALL SELECT  1106, 1337, 128, N'054-230'
    UNION ALL SELECT  1107, 1338, 119, N'054-137'
    UNION ALL SELECT  1108, 1338, 117, N'054-045'
    UNION ALL SELECT  1109, 1339, 121, N'054-407'
    UNION ALL SELECT  1110, 1340, 128, N'054-231'
    UNION ALL SELECT  1111, 1341, 117, N'054-046'
    UNION ALL SELECT  1112, 1342, 128, N'054-232'
    UNION ALL SELECT  1113, 1343, 117, N'054-047'
    UNION ALL SELECT  1114, 1344, 117, N'054-048'
    UNION ALL SELECT  1115, 1345, 117, N'054-049'
    UNION ALL SELECT  1116, 1345, 154, N'054-316'
    UNION ALL SELECT  1117, 1346, 154, N'054-317'
    UNION ALL SELECT  1118, 1347, 119, N'054-138'
    UNION ALL SELECT  1119, 1348, 128, N'054-233'
    UNION ALL SELECT  1120, 1349, 128, N'054-234'
    UNION ALL SELECT  1121, 1350, 128, N'054-235'
    UNION ALL SELECT  1122, 1350, 154, N'054-318'
    UNION ALL SELECT  1123, 1350, 119, N'054-139'
    UNION ALL SELECT  1124, 1350, 117, N'054-050'
    UNION ALL SELECT  1125, 1350, 121, N'054-408'
    UNION ALL SELECT  1126, 1351, 117, N'054-051'
    UNION ALL SELECT  1127, 1351, 119, N'054-140'
    UNION ALL SELECT  1128, 1352, 119, N'054-141'
    UNION ALL SELECT  1129, 1352, 117, N'054-052'
    UNION ALL SELECT  1130, 1352, 154, N'054-319'
    UNION ALL SELECT  1131, 1352, 121, N'054-409'
    UNION ALL SELECT  1132, 1353, 119, N'054-142'
    UNION ALL SELECT  1133, 1354, 121, N'054-410'
    UNION ALL SELECT  1134, 1355, 119, N'054-143'
    UNION ALL SELECT  1135, 1356, 119, N'054-144'
    UNION ALL SELECT  1136, 1356, 117, N'054-053'
    UNION ALL SELECT  1137, 1356, 121, N'054-365'
    UNION ALL SELECT  1138, 1357, 117, N'054-054'
    UNION ALL SELECT  1139, 1358, 154, N'054-320'
    UNION ALL SELECT  1140, 1359, 128, N'054-236'
    UNION ALL SELECT  1141, 1360, 128, N'054-237'
    UNION ALL SELECT  1142, 1361, 119, N'054-145'
    UNION ALL SELECT  1143, 1362, 119, N'054-146'
    UNION ALL SELECT  1144, 1363, 121, N'054-411'
    UNION ALL SELECT  1145, 1364, 119, N'054-147'
    UNION ALL SELECT  1146, 1365, 154, N'054-321'
    UNION ALL SELECT  1147, 1366, 117, N'054-055'
    UNION ALL SELECT  1148, 1367, 154, N'054-322'
    UNION ALL SELECT  1149, 1368, 121, N'054-412'
    UNION ALL SELECT  1150, 1369, 121, N'054-413'
    UNION ALL SELECT  1151, 1370, 128, N'054-238'
    UNION ALL SELECT  1152, 1371, 119, N'054-148'
    UNION ALL SELECT  1153, 1372, 128, N'054-239'
    UNION ALL SELECT  1154, 1373, 117, N'054-056'
    UNION ALL SELECT  1155, 1374, 154, N'054-323'
    UNION ALL SELECT  1156, 1375, 121, N'054-414'
    UNION ALL SELECT  1157, 1376, 128, N'054-240'
    UNION ALL SELECT  1158, 1377, 154, N'054-324'
    UNION ALL SELECT  1159, 1378, 128, N'054-241'
    UNION ALL SELECT  1160, 1378, 119, N'054-149'
    UNION ALL SELECT  1161, 1379, 128, N'054-242'
    UNION ALL SELECT  1162, 1380, 121, N'054-415'
    UNION ALL SELECT  1163, 1381, 154, N'054-325'
    UNION ALL SELECT  1164, 1382, 119, N'054-150'
    UNION ALL SELECT  1165, 1383, 119, N'054-151'
    UNION ALL SELECT  1166, 1384, 128, N'054-243'
    UNION ALL SELECT  1167, 1385, 121, N'054-416'
    UNION ALL SELECT  1168, 1386, 119, N'054-152'
    UNION ALL SELECT  1169, 1386, 117, N'054-057'
    UNION ALL SELECT  1170, 1387, 128, N'054-244'
    UNION ALL SELECT  1171, 1387, 154, N'054-326'
    UNION ALL SELECT  1172, 1387, 121, N'054-417'
    UNION ALL SELECT  1173, 1388, 121, N'054-418'
    UNION ALL SELECT  1174, 1388, 117, N'054-058'
    UNION ALL SELECT  1175, 1389, 119, N'054-153'
    UNION ALL SELECT  1176, 1390, 119, N'054-154'
    UNION ALL SELECT  1177, 1390, 121, N'054-419'
    UNION ALL SELECT  1178, 1391, 117, N'054-059'
    UNION ALL SELECT  1179, 1392, 117, N'054-060'
    UNION ALL SELECT  1180, 1393, 117, N'054-061'
    UNION ALL SELECT  1181, 1393, 128, N'054-245'
    UNION ALL SELECT  1182, 1393, 121, N'054-420'
    UNION ALL SELECT  1183, 1394, 119, N'054-155'
    UNION ALL SELECT  1184, 1395, 119, N'054-156'
    UNION ALL SELECT  1185, 1396, 119, N'054-157'
    UNION ALL SELECT  1186, 1396, 117, N'054-062'
    UNION ALL SELECT  1187, 1397, 117, N'054-063'
    UNION ALL SELECT  1188, 1398, 128, N'054-246'
    UNION ALL SELECT  1189, 1399, 154, N'054-327'
    UNION ALL SELECT  1190, 1400, 154, N'054-328'
    UNION ALL SELECT  1191, 1401, 154, N'054-329'
    UNION ALL SELECT  1192, 1402, 117, N'054-064'
    UNION ALL SELECT  1193, 1402, 119, N'054-158'
    UNION ALL SELECT  1194, 1402, 121, N'054-421'
    UNION ALL SELECT  1195, 1403, 154, N'054-330'
    UNION ALL SELECT  1196, 1404, 128, N'054-247'
    UNION ALL SELECT  1197, 1404, 119, N'054-159'
    UNION ALL SELECT  1198, 1404, 117, N'054-065'
    UNION ALL SELECT  1199, 1404, 121, N'054-422'
    UNION ALL SELECT  1200, 1405, 128, N'054-248'
    UNION ALL SELECT  1201, 1406, 119, N'054-160'
    UNION ALL SELECT  1202, 1407, 119, N'054-161'
    UNION ALL SELECT  1203, 1408, 119, N'054-162'
    UNION ALL SELECT  1204, 1409, 119, N'054-163'
    UNION ALL SELECT  1205, 1410, 119, N'054-164'
    UNION ALL SELECT  1206, 1411, 128, N'054-249'
    UNION ALL SELECT  1207, 1412, 121, N'054-423'
    UNION ALL SELECT  1208, 1413, 121, N'054-424'
    UNION ALL SELECT  1209, 1414, 128, N'054-250'
    UNION ALL SELECT  1210, 1415, 119, N'054-165'
    UNION ALL SELECT  1211, 1416, 154, N'054-331'
    UNION ALL SELECT  1212, 1417, 119, N'054-166'
    UNION ALL SELECT  1213, 1418, 121, N'054-425'
    UNION ALL SELECT  1214, 1419, 128, N'054-251'
    UNION ALL SELECT  1215, 1420, 117, N'054-066'
    UNION ALL SELECT  1216, 1421, 154, N'054-332'
    UNION ALL SELECT  1217, 1422, 117, N'054-067'
    UNION ALL SELECT  1218, 1422, 121, N'054-426'
    UNION ALL SELECT  1219, 1423, 117, N'054-068'
    UNION ALL SELECT  1220, 1424, 117, N'054-069'
    UNION ALL SELECT  1221, 1424, 119, N'054-167'
    UNION ALL SELECT  1222, 1424, 154, N'054-333'
    UNION ALL SELECT  1223, 1425, 119, N'054-168'
    UNION ALL SELECT  1224, 1425, 117, N'054-070'
    UNION ALL SELECT  1225, 1425, 121, N'054-427'
    UNION ALL SELECT  1226, 1426, 119, N'054-169'
    UNION ALL SELECT  1227, 1427, 121, N'054-428'
    UNION ALL SELECT  1228, 1428, 128, N'054-252'
    UNION ALL SELECT  1229, 1429, 121, N'054-429'
    UNION ALL SELECT  1230, 1430, 119, N'054-170'
    UNION ALL SELECT  1231, 1431, 128, N'054-253'
    UNION ALL SELECT  1232, 1432, 128, N'054-254'
    UNION ALL SELECT  1233, 1433, 117, N'054-071'
    UNION ALL SELECT  1234, 1434, 121, N'054-430'
    UNION ALL SELECT  1235, 1435, 121, N'054-431'
    UNION ALL SELECT  1236, 1436, 121, N'054-432'
    UNION ALL SELECT  1237, 1437, 128, N'054-255'
    UNION ALL SELECT  1238, 1438, 128, N'054-256'
    UNION ALL SELECT  1239, 1439, 128, N'054-257'
    UNION ALL SELECT  1240, 1440, 121, N'054-433'
    UNION ALL SELECT  1241, 1441, 117, N'054-072'
    UNION ALL SELECT  1242, 1442, 154, N'054-334'
    UNION ALL SELECT  1243, 1443, 119, N'054-171'
    UNION ALL SELECT  1244, 1444, 128, N'054-258'
    UNION ALL SELECT  1245, 1445, 154, N'054-335'
    UNION ALL SELECT  1246, 1446, 121, N'054-434'
    UNION ALL SELECT  1247, 1447, 121, N'054-435'
    UNION ALL SELECT  1248, 1448, 117, N'054-073'
    UNION ALL SELECT  1249, 1449, 121, N'054-436'
    UNION ALL SELECT  1250, 1450, 128, N'054-259'
    UNION ALL SELECT  1251, 1451, 154, N'054-336'
    UNION ALL SELECT  1252, 1452, 154, N'054-337'
    UNION ALL SELECT  1253, 1453, 117, N'054-074'
    UNION ALL SELECT  1254, 1454, 117, N'054-075'
    UNION ALL SELECT  1255, 1455, 121, N'054-437'
    UNION ALL SELECT  1256, 1456, 128, N'054-260'
    UNION ALL SELECT  1257, 1457, 119, N'054-172'
    UNION ALL SELECT  1258, 1458, 154, N'054-338'
    UNION ALL SELECT  1259, 1459, 119, N'054-173'
    UNION ALL SELECT  1260, 1460, 121, N'054-438'
    UNION ALL SELECT  1261, 1461, 119, N'054-174'
    UNION ALL SELECT  1262, 1462, 154, N'054-339'
    UNION ALL SELECT  1263, 1463, 119, N'054-175'
    UNION ALL SELECT  1264, 1464, 128, N'054-261'
    UNION ALL SELECT  1265, 1465, 128, N'054-262'
    UNION ALL SELECT  1266, 1466, 117, N'054-076'
    UNION ALL SELECT  1267, 1467, 117, N'054-077'
    UNION ALL SELECT  1268, 1468, 117, N'054-078'
    UNION ALL SELECT  1269, 1468, 128, N'054-263'
    UNION ALL SELECT  1270, 1468, 154, N'054-340'
    UNION ALL SELECT  1271, 1469, 128, N'054-264'
    UNION ALL SELECT  1272, 1469, 119, N'054-176'
    UNION ALL SELECT  1273, 1470, 154, N'054-341'
    UNION ALL SELECT  1274, 1471, 121, N'054-439'
    UNION ALL SELECT  1275, 1472, 117, N'054-079'
    UNION ALL SELECT  1276, 1473, 117, N'054-080'
    UNION ALL SELECT  1277, 1474, 121, N'054-440'
    UNION ALL SELECT  1278, 1475, 154, N'054-342'
    UNION ALL SELECT  1279, 1476, 119, N'054-177'
    UNION ALL SELECT  1280, 1477, 119, N'054-178'
    UNION ALL SELECT  1281, 1478, 154, N'054-343'
    UNION ALL SELECT  1282, 1479, 128, N'054-265'
    UNION ALL SELECT  1283, 1480, 119, N'054-179'
    UNION ALL SELECT  1284, 1481, 121, N'054-441'
    UNION ALL SELECT  1285, 1482, 128, N'054-266'
    UNION ALL SELECT  1286, 1483, 128, N'054-267'
    UNION ALL SELECT  1287, 1484, 121, N'054-442'
    UNION ALL SELECT  1288, 1485, 128, N'054-268'
    UNION ALL SELECT  1289, 1486, 121, N'054-443'
    UNION ALL SELECT  1290, 1487, 121, N'054-444'
    UNION ALL SELECT  1291, 1487, 128, N'054-269'
    UNION ALL SELECT  1292, 1488, 154, N'054-344'
    UNION ALL SELECT  1293, 1488, 119, N'054-180'
    UNION ALL SELECT  1294, 1489, 121, N'054-445'
    UNION ALL SELECT  1295, 1490, 117, N'054-081'
    UNION ALL SELECT  1296, 1491, 154, N'054-345'
    UNION ALL SELECT  1297, 1491, 128, N'054-270'
    UNION ALL SELECT  1298, 1492, 119, N'054-181'
    UNION ALL SELECT  1299, 1493, 121, N'054-446'
    UNION ALL SELECT  1300, 1494, 128, N'054-271'
    UNION ALL SELECT  1301, 1495, 121, N'054-447'
    UNION ALL SELECT  1302, 1496, 154, N'054-346'
    UNION ALL SELECT  1303, 1497, 121, N'054-448'
    UNION ALL SELECT  1304, 1498, 117, N'054-082'
    UNION ALL SELECT  1305, 1499, 119, N'054-182'
    UNION ALL SELECT  1306, 1499, 121, N'054-449'
    UNION ALL SELECT  1307, 1500, 119, N'054-183'
    UNION ALL SELECT  1308, 1501, 154, N'054-347'
    UNION ALL SELECT  1309, 1502, 154, N'054-348'
    UNION ALL SELECT  1310, 1503, 119, N'054-184'
    UNION ALL SELECT  1311, 1504, 119, N'054-185'
    UNION ALL SELECT  1312, 1504, 117, N'054-083'
    UNION ALL SELECT  1313, 1504, 128, N'054-272'
    UNION ALL SELECT  1314, 1504, 121, N'054-450'
    UNION ALL SELECT  1315, 1505, 121, N'054-451'
    UNION ALL SELECT  1316, 1506, 121, N'054-452'
    UNION ALL SELECT  1317, 1507, 154, N'054-349'
    UNION ALL SELECT  1318, 1508, 121, N'054-453'
    UNION ALL SELECT  1319, 1509, 154, N'054-350'
    UNION ALL SELECT  1320, 1510, 117, N'054-084'
    UNION ALL SELECT  1321, 1510, 119, N'054-186'
    UNION ALL SELECT  1322, 1511, 128, N'054-273'
    UNION ALL SELECT  1323, 1512, 121, N'054-454'
    UNION ALL SELECT  1324, 1513, 121, N'054-455'
    UNION ALL SELECT  1325, 1514, 128, N'054-274'
    UNION ALL SELECT  1326, 1515, 117, N'054-085'
    UNION ALL SELECT  1327, 1516, 121, N'054-456'
    UNION ALL SELECT  1328, 1517, 128, N'054-275'
    UNION ALL SELECT  1329, 1518, 119, N'054-187'
    UNION ALL SELECT  1330, 1519, 154, N'054-351'
    UNION ALL SELECT  1331, 1520, 121, N'054-457'
    UNION ALL SELECT  1332, 1521, 121, N'054-458'
    UNION ALL SELECT  1333, 1522, 119, N'054-188'
    UNION ALL SELECT  1334, 1523, 128, N'054-276'
    UNION ALL SELECT  1335, 1524, 128, N'054-277'
    UNION ALL SELECT  1336, 1525, 119, N'054-189'
    UNION ALL SELECT  1337, 1526, 128, N'054-278'
    UNION ALL SELECT  1338, 1526, 121, N'054-459'
    UNION ALL SELECT  1339, 1527, 117, N'054-086'
    UNION ALL SELECT  1340, 1528, 121, N'054-460'
    UNION ALL SELECT  1341, 1529, 128, N'054-279'
    UNION ALL SELECT  1342, 1530, 117, N'054-087'
    UNION ALL SELECT  1343, 1531, 117, N'054-088'
    UNION ALL SELECT  1344, 1531, 154, N'054-352'
    UNION ALL SELECT  1345, 1532, 119, N'054-190'
    UNION ALL SELECT  1346, 1533, 121, N'054-461'
    UNION ALL SELECT  1347, 1534, 128, N'054-280'
    UNION ALL SELECT  1348, 1535, 128, N'054-281'
    UNION ALL SELECT  1349, 1536, 121, N'054-462'
    UNION ALL SELECT  1350, 1537, 154, N'054-353'
    UNION ALL SELECT  1351, 1538, 119, N'054-191'
    UNION ALL SELECT  1352, 1538, 117, N'054-089'
    UNION ALL SELECT  1353, 1539, 117, N'054-090'
    UNION ALL SELECT  1354, 1540, 119, N'054-192'
    UNION ALL SELECT  1355, 1541, 154, N'054-354'
    UNION ALL SELECT  1356, 1542, 154, N'054-355'
    UNION ALL SELECT  1357, 1543, 119, N'054-193'
    UNION ALL SELECT  1358, 1544, 128, N'054-282'
    UNION ALL SELECT  1359, 1545, 121, N'054-463'
    UNION ALL SELECT  1360, 1546, 128, N'054-283'
    UNION ALL SELECT  1361, 1547, 121, N'054-464'
    UNION ALL SELECT  1362, 1548, 154, N'054-356'
    UNION ALL SELECT  1363, 1549, 117, N'054-091'
    UNION ALL SELECT  1364, 1550, 117, N'054-092'
    UNION ALL SELECT  1365, 1550, 119, N'054-194'
    UNION ALL SELECT  1366, 1551, 128, N'054-284'
    UNION ALL SELECT  1367, 1552, 154, N'054-357'
    UNION ALL SELECT  1368, 1553, 154, N'054-358'
    UNION ALL SELECT  1369, 1553, 128, N'054-285'
    UNION ALL SELECT  1370, 1553, 119, N'054-195'
    UNION ALL SELECT  1371, 1553, 117, N'054-093'
    UNION ALL SELECT  1372, 1553, 121, N'054-465'
    UNION ALL SELECT  1373, 1554, 119, N'054-196'
    UNION ALL SELECT  1374, 1555, 128, N'054-286'
    UNION ALL SELECT  1375, 1556, 154, N'054-359'
    UNION ALL SELECT  1376, 1557, 154, N'054-360'
    UNION ALL SELECT  1377, 1558, 154, N'054-361'
    UNION ALL SELECT  1378, 1559, 119, N'054-197'
    UNION ALL SELECT  1379, 1559, 117, N'054-094'
    UNION ALL SELECT  1380, 1560, 117, N'054-095'
    UNION ALL SELECT  1381, 1561, 119, N'054-198'
    UNION ALL SELECT  1382, 1562, 119, N'054-199'
    UNION ALL SELECT  1383, 1563, 121, N'054-466'
    UNION ALL SELECT  1384, 1564, 128, N'054-287'
    UNION ALL SELECT  1385, 1565, 119, N'054-200'
    UNION ALL SELECT  1386, 1566, 119, N'054-201'
    UNION ALL SELECT  1387, 1567, 121, N'054-467'
    UNION ALL SELECT  1388, 1568, 119, N'054-202'
    UNION ALL SELECT  1389, 1568, 117, N'054-096'
    UNION ALL SELECT  1390, 1568, 154, N'054-362'
    UNION ALL SELECT  1391, 1569, 117, N'054-097'
    UNION ALL SELECT  1392, 1570, 128, N'054-288'
    UNION ALL SELECT  1393, 1571, 154, N'054-363'
    UNION ALL SELECT  1394, 1572, 117, N'054-098'
    UNION ALL SELECT  1395, 1573, 119, N'054-203'
    UNION ALL SELECT  1396, 1574, 121, N'054-468'
    UNION ALL SELECT  1397, 1575, 117, N'054-099'
    UNION ALL SELECT  1398, 1576, 117, N'054-100'
    UNION ALL SELECT  1399, 1576, 128, N'054-289'
    UNION ALL SELECT  1400, 1577, 121, N'054-469'
    UNION ALL SELECT  1401, 1578, 128, N'054-290'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.StatesCounties    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.StatesCounties OFF ;
    SET IDENTITY_INSERT dbo.EhlersOffice ON ;

    INSERT  dbo.EhlersOffice ( EhlersOfficeID, AddressID, Phone, TollFree, Fax, WebSite, ReportFooter, ModifiedDate, ModifiedUser )  
    SELECT  1, 1, N'(630) 271-3330', N'', N'(630) 271-3369', N'', NULL, GETDATE(), N'Conversion'
    UNION ALL SELECT  2, 2, N'(651) 697-8500', N'', N'(651) 697-8555', N'', NULL, GETDATE(), N'Conversion'
    UNION ALL SELECT  3, 3, N'(262) 785-1520', N'', N'(262) 785-1810', N'', NULL, GETDATE(), N'Conversion'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.EhlersOffice    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.EhlersOffice OFF ;
    SET IDENTITY_INSERT dbo.EhlersEmployee ON ;
    INSERT  dbo.EhlersEmployee ( EhlersEmployeeID, FirstName, LastName, MiddleInitial, Initials, Active, EhlersOfficeID, Phone, CellPhone, Fax, Email, JobTitle, OfficerTitle, BillRate, BaseRate, Biography, Education, HireDate, Waiver, PictureWaiver, CIPFACertified, ModifiedDate, ModifiedUser ) 
    SELECT   1, N'Brian', N'Shannon', N'', N'BJS', 1, 2, N'6516978515', N'6514852650', N'6516978555', N'bshannon@ehlers-inc.com', N'Senior Financial Analyst', N'', CAST( 190.00 AS Decimal( 15, 2 ) ), CAST( 81.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Prior to joining Ehlers &amp; Associates in 1998 as a Financial Analyst, Mr.Shannon worked as an account representative with a major banking firm in Corporate Trust while utilizing his wide range of experience and playing a significant role in Public Finance. His extensive background with various computer programs and spreadsheets allows him to develop tailored computer models to meet the specific financial needs of municipal clients. He has experience working with Cities, Villages, Counties, Towns, School Districts and universities. His special expertise is in analyzing, structuring, documenting, and underwriting municipal securities, analyzing and structuring cash defeasances, advance refundings, multi-issue debt programs, and computer analysis utilizing Munex and Excel. 
&lt;/p&gt;', N'Bachelor of Science in both Finance and Economics from the University of Wisconsin-La Crosse', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   2, N'Beth', N'Ruyle', N'', N'BSR', 0, 1, N'6302713332', N'6305619633', N'6302713369', N'bruyle@ehlers-inc.com', N'Financial Advisor', N'Executive Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x05240B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CBB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   4, N'Connie', N'Kuck', N'', N'CAK', 1, 2, N'6516978527', N'', N'6516978555', N'ckuck@ehlers-inc.com', N'Senior Bond Sale Coordinator', N'', CAST( 150.00 AS Decimal( 15, 2 ) ), CAST( 57.00 AS Decimal( 15, 2 ) ), N'Ms. Kuck joined the Ehlers team in 1994 bringing with her the experience of working with the underwriting department of Piper Jaffray Inc. She has experience working in Ehlers Bond Sale area and as the Company&#039;s Continuing Disclosure Coordinator and is currently a Senior Bond Sale Coordinator. In this capacity, Ms. Kuck is responsible for coordinating all aspects of the actual bond sale and closing including, responding to questions of underwriters concerning bond sale specifications, receiving the competitive bids on sale day, coordinating the closing with underwriters, completing documentation required for the closing, and arranging for transfer of proceeds at closing.', N'', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   5, N'Carolyn', N'Drude', N'', N'CGD', 1, 2, N'6516978511', N'6123081795', N'6516978555', N'cdrude@ehlers-inc.com', N'Senior Financial Advisor', N'Executive Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x5D0C0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   6, N'Darlene', N'Bahr', N'', N'DAB', 0, 3, N'2627966169', N'', N'2627851810', N'dbahr@ehlers-inc.com', N'Senior Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'<p>Senior Analyst</p>
<p>Since joining Ehlers & Associates in 1986, Ms. Bahr has worked with
the Brookfield, Wisconsin, team. She is a senior analyst working with financial
advisors for Wisconsin cities, villages, towns, sanitary districts and schools 
issuing various kinds of debt including general obligation, utility revenue, 
and lease revenue debt and current and advance refundings, and cash flow 
financing. She also coordinates work products and schedules for accounts and 
gathers, analyzes and organizes data for official statements. She also prepares 
comprehensive books following the closing of the financings, including a summary 
of the financing and all pertinent documents relating thereto. She provides 
on-going services to Ehlers'' clients and is a liaison for full disclosure 
reporting requirements.
</p>
<p>
She is certified as a Certified Independent Public Finance Advisor by the 
National Association of Independent Public Finance Advisors Association. 
</p>', N'', CAST( 0x02270B00 AS Date ), 1, 0, 1, CAST( 0x0000A14000B35CBB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   7, N'Dave', N'Wagner', N'', N'DAW', 1, 3, N'2627966163', N'4143333090', N'2627851810', N'dwagner@ehlers-inc.com', N'Senior Financial Advisor', N'Senior Vice President', CAST( 225.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xFF1B0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   8, N'David', N'Anderson', N'', N'DBA', 0, 3, N'2627966166', N'', N'2627851810', N'', N'Senior Financial Advisor', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CBC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   9, N'Debra', N'Engstrom', N'', N'DE', 0, 2, N'6516978502', N'', N'6516978555', N'', N'Human Resources Director', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CBC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   10, N'David', N'Hozza', N'', N'DH', 0, 1, N'6303556100', N'', N'6303556177', N'', N'Financial Advisor', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CBC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   11, N'Debbie', N'Holmes', N'', N'DJHo', 1, 2, N'6516978536', N'', N'6516978555', N'dholmes@ehlers-inc.com', N'Business Analyst', N'', CAST( 150.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Holmes has been actively involved in public finance with Ehlers since 1998. She currently serves as a Senior Analyst in the Minnesota office and works with issuers in both Minnesota and Wisconsin. As a Senior Analyst, she is responsible for the preparation of official statements, coordinating legal documentation, and preparing post-sale documentation including sale resolutions, closing memorandums, debt service schedules, and tax levy calculations.', N'Bachelor of Science ( Business Administration )  - Magna cum laude, Northwestern College - Roseville, MN', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   12, N'Diana', N'Lockard', N'', N'DLL', 1, 2, N'6516978534', N'', N'6516978555', N'dlockard@ehlers-inc.com', N'Senior Disclosure Coordinator', N'', CAST( 150.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Lockard has been actively involved in public finance with Ehlers since 1984. She is a Senior Coordinating Analyst in the Minnesota office and works with Minnesota School Districts, Cities, Townships and Counties. Ms. Lockard is responsible for the coordination of work processes in the MN Analyst Department.  These duties include overseeing the preparation of official statements, bond issue summary books, sale resolutions, closing memorandums, debt service schedules, tax levy calculations, and the coordination of legal documentation.', N'Bachelor of Arts ( Communication ) University of Minnesota - Duluth', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   13, N'Doris', N'Harris', N'', N'DMH', 0, 1, N'6303556100', N'', N'6303556177', N'', N'', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CBD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   14, N'Diane', N'Piechocki', N'', N'DP', 0, 2, N'6516978533', N'', N'6516978555', N'', N'Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CBD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   15, N'Deb', N'Peterson', N'', N'DRP', 1, 2, N'6516978528', N'', N'6516978555', N'dpeterson@ehlers-inc.com', N'Senior Bond Sale Coordinator', N'Administrative Vice President', CAST( 150.00 AS Decimal( 15, 2 ) ), CAST( 57.00 AS Decimal( 15, 2 ) ), N'<p>Ms. Peterson joined Ehlers & Associates in December of 1985. As Senior Bond Sale Coordinator, Ms. Eller is responsible for coordinating all aspects of the actual bond sale including, responding to questions of underwriters concerning bond sale specifications, receiving the competitive bids on sale day, coordinating the closing with underwriters, completing documentation required for the closing and arranging for transfer of proceeds at closing. In addition, she also coordinates the completion and distribution of documents relating to early redemptions, defeasances and current and advance refundings.</p>', N'', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   16, N'David', N'Lundeen', N'', N'DSL', 0, 1, N'6302713336', N'6303350782', N'6302713369', N'dlundeen@ehlers-inc.com', N'Financial Advisor', N'', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x641F0B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CBE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   17, N'Elizabeth', N'Diaz', N'', N'ED', 1, 2, N'6516978519', N'', N'6516978555', N'ediaz@ehlers-inc.com', N'Senior Financial Specialist', N'', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x52250B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CBE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   18, N'Gary', N'Olsen', N'', N'GWO', 1, 2, N'6516978513', N'6514023562', N'6516978555', N'golsen@ehlers-inc.com', N'Financial Advisor', N'Vice President', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x4E230B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   19, N'James', N'Mann', N'A.', N'JAM', 1, 3, N'2627966162', N'4145076981', N'2627851810', N'jmann@ehlers-inc.com', N'Financial Advisor', N'Vice President', CAST( 200.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xC1240B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   20, N'Joel', N'Sutter', N'', N'JAS', 1, 2, N'6516978514', N'6128161077', N'6516978555', N'jsutter@ehlers-inc.com', N'Senior Financial Advisor', N'Executive Vice President', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x861F0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CBE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   21, N'Jim', N'Prosser', N'', N'JDP', 0, 1, N'6302713334', N'', N'6516978555', N'', N'Financial Advisor', N'', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 1, 0, 1, CAST( 0x0000A14000B35CBE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   22, N'Jereme', N'Allen', N'', N'JMA', 0, 2, N'6516978529', N'', N'6516978555', N'jallen@ehlers-inc.com', N'IT Support &amp; Facilities Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 1, 0, CAST( 0x0000A14000B35CBE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   23, N'Jon', N'Platts', N'', N'JP', 0, 3, N'2627966176', N'2624244243', N'2627851810', N'', N'Financial Advisor', N'', CAST( 100.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'
<p>Financial Advisor</p>
<p>
Dr. Platts, formerly the Superintendent of the School District of Milton, 
Wisconsin, brings 33 years of public school administrative experience to the firm.
</p>
<p>
During 30 years in the superintendency and three years as business manager for 
the School District of Milton, he was responsible for financial operations. This 
included a very positive 32-year working relationship with Ehlers &amp; Associates, 
Inc. and the successful completion of nine major building/remodeling projects.
</p>
<p>
In addition to his background in program and facilities planning, school 
construction and successful bond issue approval campaigns, he brings a sound 
background in understanding Wisconsin school law, state aids and tax structure. 
This, of course, includes a thorough understanding of tax levies, debt management 
and budget constraints that are unique to Wisconsin school districts. 
</p>
<p>
Preparatory Education: He is a graduate of the University of Wisconsin/Whitewater 
in accounting/business education and holds a Master&apos;s Degree, Specialist 
Degree, and Ph.D. from the University of Wisconsin/Madison in Educational 
Administration.
</p>
', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CBF AS DateTime ), N'ccarson'  UNION ALL
    SELECT   24, N'Jana', N'Ristamaki', N'', N'JxR', 0, 2, N'6516978501', N'', N'6516978555', N'', N'', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CBF AS DateTime ), N'ccarson'  UNION ALL
    SELECT   25, N'Rusty', N'Fifield', N'', N'JRF', 0, 2, N'6516978506', N'', N'6516978555', N'', N'Financial Advisor', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CBF AS DateTime ), N'ccarson'  UNION ALL
    SELECT   26, N'Kimberly', N'Gaetz', N'', N'KAG', 0, 2, N'6516978500', N'', N'6516978555', N'', N'Analyst Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CC0 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   27, N'Kristin', N'Hanson', N'A.', N'KAH', 0, 2, N'6516978512', N'6128017132', N'6516978555', N'khanson@ehlers-inc.com', N'Financial Advisor', N'Senior Vice President', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x1E1D0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC0 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   28, N'Kay', N'Robinson', N'', N'KFR', 0, 2, N'6516978527', N'', N'6516978555', N'', N'Bond Sale Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CC0 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   29, N'Kris', N'Crouse', N'', N'KLC', 0, 2, N'6516978539', N'', N'6516978555', N'kcrouse@ehlers-inc.com', N'Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'Ms. Crouse has been actively involved in public finance with Ehlers since 2001. She currently serves as an Analyst in the Minnesota office and works with issuers in both Minnesota and Wisconsin.  As an Analyst, her main duties include coordinating legal documentation and gathering, analyzing and organizing data necessary to produce official statements and continuing disclosure reports.', N'Bachelor of Arts, University of Minnesota-Twin Cities', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC0 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   30, N'Kathleen', N'Myers', N'', N'KTM', 1, 3, N'2627966177', N'', N'2627851810', N'kmyers@ehlers-inc.com', N'Senior Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Myers joined Ehlers &amp; Associates in October 1999 and works from our Brookfield, Wisconsin office as a Senior Analyst. Her main duties include gathering, analyzing and organizing data necessary to produce official statements; preparing post-sale documentation following each assigned financing, preparation and submittal of annual disclosure reports, assisting financial advisors in their preparatory work for their clients and monitoring outstanding debt for potential refundings.', N'Bachelor of Arts in Mathematics with an emphasis in Statistics from University of Wisconsin - Platteville.', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   31, N'Lindsay', N'Oilschlager', N'', N'LJO', 0, 2, N'6516978500', N'', N'6516978555', N'', N'Receptionist', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CC1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   32, N'Michael', N'Harrigan', N'C.', N'MCH', 1, 3, N'2627966165', N'4148814485', N'2627851810', N'mharrigan@ehlers-inc.com', N'Senior Financial Advisor', N'Chairman/Executive Vice President', CAST( 225.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x681A0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   33, N'Mary', N'Zywiec', N'', N'MLZ', 1, 3, N'2627966171', N'', N'2627851810', N'mzywiec@ehlers-inc.com', N'Senior Financial Analyst', N'', CAST( 185.00 AS Decimal( 15, 2 ) ), CAST( 81.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Prior to joining Ehlers &amp; Associates in 1995 as a Financial Analyst, Ms. Zywiec served over 10 years with major regional investment banking firms while utilizing her wide range of experience and playing a significant role in Public Finance. Her extensive background with various computer programs and spreadsheets allows her to develop tailored computer models to meet the specific financial needs of municipal clients. She has experience working with Cities, Villages, 
Counties, Towns, School Districts and universities. Her special expertise is in analyzing, structuring, documenting, and underwriting municipal securities, analyzing and structuring cash defeasances, advance refundings and multi-issue debt programs, and computer analysis utilizing Munex and Excel. She has extensive 
experience in developing and implementing 5 year Capital Financing Plans and presentations to the major rating agencies on behalf of the issuer. 
&lt;/p&gt;', N'Bachelor of Science in Business with emphasis in Marketing from Western Illinois University and also attended University of Denver.', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   34, N'Mindy', N'Barrett', N'', N'MMB', 1, 1, N'6302713342', N'', N'6302713369', N'mbarrett@ehlers-inc.com', N'TIF Coordinator', N'', CAST( 95.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Mindy Barrett returned to Ehlers &amp; Associates in September of 2006 and currently is a Tax Increment Financing Coordinator in our Lisle office. She is responsible for assisting in the development and implementation of tax increment finance eligibility studies and redevelopment plans.
&lt;/p&gt;
&lt;p&gt;
Prior to joining Ehlers, she worked as a Program Manager for the South Suburban Mayors and Managers Association and most recently, she served as the Director of Finance for an environmental consulting firm.
&lt;/p&gt;', N'Bachelors of Arts degree in Public Administration from the Governors State University and Masters of Science degree in Public Services Management from DePaul University in Chicago', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   35, N'Michelle', N'Harris', N'', N'MMH', 1, 1, N'6302713337', N'', N'6302713369', N'mharris@ehlers-inc.com', N'Senior Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Harris has been with Ehlers &amp; Associates since April 1999 and currently is a Senior Analyst in our Lisle office. Prior to joining Ehlers, she worked in the insurance industry. Her main duties include the preparation of official statements; continuing disclosure services; and preparing post-sale documentation including debt service schedules, tax levy calculations, closing memorandums and bond issue summary books.', N'Bachelor of Arts ( Business Management )
North Central College, Naperville, IL', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   37, N'Mark', N'Ruff', N'', N'MTR', 1, 2, N'6516978505', N'6127475780', N'6516978555', N'mruff@ehlers-inc.com', N'Senior Financial Advisor', N'Executive Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x1E1D0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC2 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   38, N'Nancy', N'DeMarais', N'', N'NAD', 0, 2, N'6516978535', N'', N'6516970281', N'ndemarais@ehlers-inc.com', N'Administrative Coordinator', N'Corporate Secretary', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'Ms. DeMarais has been actively involved in public finance at Ehlers since 1983.  She currently serves as Administrative Coordinator and Corporate Secretary for Ehlers and its subsidiary, Bond Trust Services Corporation, providing support to the Board and President on special projects and implementation of strategic planning objectives. She additionally coordinates the corporate training program; assists in developing work processes using existing and new technology; and supports and coordinates business development activities for all three of Ehlers'' offices.  She continues to provide analytical support to Financial Advisors in the Minnesota office on special financings for school districts, cities, utilities, townships, and counties.  Nancy has served as a member of the Ehlers'' Management Team and the Board of Directors.', N'Major in Business Administration at St. Cloud State University', CAST( 0x75250B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC2 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   39, N'Nikki', N'Shannon', N'', N'NS', 0, 2, N'6516978518', N'', N'6516978555', N'', N'TIF Coordinator', N'', CAST( 160.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;
Nikki Shannon has been with Ehlers &amp; Associates since January of 2002.  
Currently Mrs. Shannon is a Tax Increment Financing Coordinator and works 
specifically with Minnesota cities and counties.  She is responsible for 
creating and maintaining all necessary legal and financial documents and 
files related to Tax Increment Districts including TIF plans, notices to 
county and school districts, public hearing notices, approval resolutions, 
TIF district maps, property data collection and computation of fiscal impacts.  
Mrs. Shannon also assists in the coordination of the annual Ehlers &amp; Associates 
Public Finance Seminar.
&lt;/p&gt;', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CC2 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   41, N'Paula', N'Czaplewski', N'', N'PAC', 1, 3, N'2627966183', N'', N'2627851810', N'pczaplewski@ehlers-inc.com', N'TIF and Disclosure Coordinator', N'', CAST( 100.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Czaplewski has been actively involved in public finance with Ehlers &amp; Associates since 1995.  She is the TIF &amp; Disclosure Coordinator in the Wisconsin office and works with Wisconsin communities.   She helps clients achieve their redevelopment and economic development goals through the use of tax increment financing by preparing all procedurally required legal and financial documents related to tax increment financing ( TIF ) districts, including incorporating legislative changes, drafting TIF plans, official notices and correspondence, resolutions, and timeline schedules.  In addition she gathers the state required documents, including the parcel &amp; mapping data necessary to complete the state forms, and reviews for statutory compliance in order to obtain state certification and ensure statutory deadlines are met.  In the role of Disclosure Coordinator she maintains information on all Ehlers clients subject to annual full disclosure reporting, as well as gathers, analyzes and organizes the clients annual economic &amp; financial data updates necessary to complete the continuing disclosure reports and meet statutory deadlines.  In addition she is responsible for the hourly billings, and the initial drafting of contracts, engagement letters, and proposal responses for the Wisconsin office.', N'', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC2 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   42, N'Philip', N'Cosson', N'L.', N'PLC', 1, 3, N'2627966161', N'2626170395', N'2627851810', N'pcosson@ehlers-inc.com', N'Financial Advisor', N'Executive Vice President', CAST( 200.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x081F0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC2 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   43, N'Robert', N'Ehlers Jr', N'', N'REJr', 0, 2, N'6516978508', N'', N'6516978555', N'', N'Financial Advisor', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CC3 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   44, N'Rebecca', N'Kurtz', N'', N'RK', 1, 2, N'6516978516', N'6512706623', N'6516978555', N'rkurtz@ehlers-inc.com', N'Financial Advisor', N'Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x80240B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC3 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   45, N'Rosemary', N'Masloski', N'', N'RM', 0, 2, N'6516978530', N'', N'6516978555', N'rosemary@ehlers-inc.com', N'Marketing Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC3 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   46, N'Susan', N'Landrum', N'', N'SAL', 0, 2, N'6516978531', N'', N'6516978555', N'slandrum@ehlers-inc.com', N'TIF Coordinator', N'', CAST( 170.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Landrum is a Tax Increment Financing Coordinator and works with cities, counties, and villages in Minnesota and Wisconsin to achieve their redevelopment, housing, and economic development goals through the use of tax increment financing ( TIF ).  Ms. Landrum prepares TIF documents, resolutions, and official notices to create and amend districts, and ensures clients meet statutory deadlines and procedural requirements.
<br><br>
Prior to joining Ehlers in 2000, Ms. Landrum worked at the Minnesota Department of Employment and Economic Development ( DEED ), assisting in the promotion of Minnesota as a viable business economy.', N'Bachelor of Arts degree from the College of St. Catherine, St. Paul, Minnesota, double majoring in International Business/Economics and German', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC4 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   47, N'Sid', N'Inman', N'', N'SCI', 1, 2, N'6516978507', N'6127475040', N'6516978555', N'sinman@ehlers-inc.com', N'Senior Financial Advisor', N'Senior Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x1E1D0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC4 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   48, N'Steve', N'Apfelbacher', N'', N'SFA', 1, 2, N'6516978510', N'6128682298', N'6516978555', N'sapfelbacher@ehlers-inc.com', N'Senior Financial Advisor', N'President', CAST( 205.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x30070B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC4 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   49, N'Steve', N'Larson', N'', N'SHL', 1, 1, N'6302713331', N'6302159246', N'6302713369', N'slarson@ehlers-inc.com', N'Senior Financial Advisor', N'Executive Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x9A220B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC4 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   50, N'Shelly', N'Eldridge', N'', N'SJE', 1, 2, N'6516978504', N'6512702872', N'6516978555', N'seldridge@ehlers-inc.com', N'Financial Advisor', N'Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xC01F0B00 AS Date ), 1, 0, 1, CAST( 0x0000A14000B35CC5 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   51, N'Sandy', N'Ludford', N'', N'SJL', 0, 2, N'6516978532', N'', N'6516978555', N'', N'Senior Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CC6 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   52, N'Stacie', N'Kvilvang', N'', N'SK', 1, 2, N'6516978506', N'6128017732', N'6516978555', N'skvilvang@ehlers-inc.com', N'Financial Advisor', N'Executive Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xF6260B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC6 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   53, N'Sean', N'Lentz', N'', N'SML', 1, 2, N'6516978509', N'6512532446', N'6516978555', N'slentz@ehlers-inc.com', N'Financial Advisor', N'Executive Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x5A1C0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC6 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   54, N'Todd', N'Hagen', N'', N'TJH', 1, 2, N'6516978508', N'6129619131', N'6516970281', N'thagen@ehlers-inc.com', N'Financial Advisor', N'Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xDE260B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC6 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   55, N'Terri', N'Scott', N'', N'TLN', 0, 3, N'2627966169', N'', N'2627851810', N'tscott@ehlers-inc.com', N'Senior Coordinating Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Senior Analyst&lt;/p&gt;
&lt;p&gt;
Terri Scott has been with Ehlers &amp; Associates since December of 1997 and 
currently is a Senior Analyst in the Brookfield, Wisconsin office. Terri had 
ten years of various accounting and finance experience before joining Ehlers. 
Her main duties include gathering, analyzing and organizing data necessary to 
produce official statements; preparing summary books following each assigned 
financing and assisting financial advisors in their preparatory work for their 
clients.  Terri also assists the Financial Advisors in the preparation of 
project plans for tax incremental districts, along with all state required 
filings and procedures. 
&lt;/p&gt;', N'Bachelor of Arts from the University of Wisconsin-Milwaukee with a 
degree in Psychology and an emphasis in Business Administration', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   56, N'Tony', N'Reichenberger', N'', N'TAR', 0, 2, N'6516978523', N'', N'6516978555', N'', N'', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CC7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   57, N'Melissa', N'Johnson', N'', N'MJ', 0, 2, N'6516978547', N'', N'6516978555', N'mjohnson@ehlers-inc.com', N'Disclosure Coordinator', N'', CAST( 185.00 AS Decimal( 15, 2 ) ), CAST( 81.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Melissa ( Stirn ) Johnson joined Ehlers as a Financial Advisor on the Minnesota Education Team in 2002. As a Financial Advisor, Ms. Johnson provided assistance to school districts in the areas of school building bonds, operating referendums, tax impact analysis, current and advanced refundings, cash flow borrowing and lease purchases.  In December 2005 Ms. Johnson filled a newly created position at Ehlers as a Financial Analyst.  She specializes in analysis of refunding opportunities, tracking of data on financial markets and municipal bonds and other related analytical work.
&lt;/p&gt;
&lt;p&gt;
Prior to joining Ehlers Ms. Johnson worked as a Research Analyst at the Department of Revenue, in the Research and Property Tax Divisions. She was responsible for revenue forecasting, analysis of proposed tax legislation, and evaluation of various aid formulas and property tax reform initiatives. She also served as a Research Analyst/Assistant with the Minnesota House of Representatives Research Department, Scott County Department of Administration and the Center for Urban and Regional Affairs.
&lt;/p&gt;', N'Cum laude graduate of Gustavus Adolphus College, St. Peter, MN in political science. Masters of Arts in Public Policy from the Hubert H. Humphrey Institute of Public Affairs, University of Minnesota', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   58, N'Betsy', N'Knoche', N'', N'BK', 1, 2, N'6516978537', N'6512494323', N'6516978555', N'bknoche@ehlers-inc.com', N'Financial Advisor', N'', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x20270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   59, N'Carol', N'Sweeney', N'', N'CS', 1, 2, N'6516978501', N'', N'6516978555', N'csweeney@ehlers-inc.com', N'Corporate Treasurer', N'Treasurer', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CC7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   60, N'Jessica', N'Cook', N'', N'JSC', 1, 2, N'6516978546', N'9522009926', N'6516978555', N'jcook@ehlers-inc.com', N'Financial Advisor', N'', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x04290B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   61, N'Todd', N'Taves', N'', N'TWT', 1, 3, N'2627966173', N'4144160962', N'2627851810', N'ttaves@ehlers-inc.com', N'Financial Advisor', N'Executive Vice President', CAST( 200.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x69280B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   62, N'John', N'Repsholdt', N'', N'JR', 0, 1, N'6302713333', N'6308531081', N'6302713369', N'jrepsholdt@ehlers-inc.com', N'Financial Advisor', N'', CAST( 100.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x18290B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   63, N'Shannon', N'Foley', N'', N'SF', 0, 2, N'6516978532', N'', N'6516978555', N'', N'Associate Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;
Ms. Foley joined Ehlers &amp; Associates in September of 2003. She is currently 
an Analyst Assistant. Her main duties include gathering, analyzing and organizing 
data necessary to produce official statements.  She graduated with a Bachelor 
of Arts from the University of Minnesota.  Prior to joining Ehlers, she worked 
for the State of Minnesota as a State Programs Administrative Technical Specialist.
&lt;/p&gt;', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CC8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   64, N'Wendy', N'Lundberg', N'', N'WL', 1, 2, N'6516978540', N'', N'6516978555', N'wlundberg@ehlers-inc.com', N'Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Lundberg has been actively involved in public finance with Ehlers since 2003. She currently serves as an Analyst in the Minnesota office and works with issuers in both Minnesota and Wisconsin.  As an Analyst, her main duties include coordinating legal documentation, and gathering, analyzing and organizing data necessary to produce official statements and continuing disclosure reports.', N'Bachelor of Science - Magna cum laude, College of Saint Catherine - St. Paul, MN', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   65, N'Brian', N'Reilly', N'', N'BR', 1, 2, N'6516978541', N'6512839179', N'6516978555', N'breilly@ehlers-inc.com', N'Financial Advisor', N'Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x82290B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CC8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   66, N'Angela', N'Davis', N'', N'AD', 0, 2, N'6516978542', N'', N'6516978555', N'', N'Bond Sale Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Ms. Davis joined Ehlers &amp; Associates in 2003.   Her primary role is Paying Agent Administrator for Bond Trust Services Corporation, a limited purpose trust company providing paying agent services to municipalities in the Midwest and a wholly owned subsidiary of Ehlers &amp; Associates, Inc.  She is responsible for invoicing and receiving principal and interest payment from BTSC clients and wiring the payments to The Depository Trust Company.&lt;/p&gt;
&lt;p&gt;
Ms. Davis also provides support to the Ehlers’ Bond Sale Department assisting with all aspects of the bond sale and closing process.  She also assists with processing early redemptions and with researching various issues/questions on behalf of clients and staff.&lt;/p&gt;
&lt;p&gt;
Ms. Davis came to Ehlers from U.S. Bank were she was an Account Administrator/Trust Officer in the Corporate Trust Department where she administered new and existing Trustee accounts as well as investigated and solved client/bondholder questions or concerns.  She previously held a position as supervisor on the Trust Finance Management Specialist team at U.S. Bank where she was responsible for calculating and setting of monthly principal and/or interest payments on variable rate bond issues, processing Letters of Credit, and reinvestment and liquidation of various securities according to legal documents.&lt;/p&gt;', N'', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   67, N'Alicia', N'Baldwin', N'', N'AlB', 1, 2, N'6516978523', N'', N'6516978555', N'aaulwes@ehlers-inc.com', N'Bond Sale Coordinator', N'', CAST( 150.00 AS Decimal( 15, 2 ) ), CAST( 57.00 AS Decimal( 15, 2 ) ), N'Ms. Aulwes has been with Ehlers &amp; Associates since November of 2003.  As a Bond Sale Coordinator, Ms. Aulwes is responsible for coordinating all aspects of the actual bond sale including, responding to questions of underwriters concerning bond sale specifications, receiving the competitive bids on sale day, coordinating the closing with underwriters, completing documentation required for the closing and arranging for transfer of proceeds at closing.  Additional responsibilities are to maintain an historical database of bond sales in the Upper Midwest.', N'Bachelor of Arts degree from the University of Minnesota, Twin Cities.', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   68, N'Alissa', N'Bishop', N'', N'AB', 0, 3, N'2627966160', N'', N'2627851810', N'', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Office Assistant&lt;/p&gt;
&lt;p&gt;
Ms. Bishop joined Ehlers &amp; Associates in January, 2004 and works out of 
our Brookfield, Wisconsin office as an Office Assistant. Her main duties 
include general office support, answer phones, greet clients, help with 
seminar arrangements, assist with analyst duties, update project lists weekly 
and assist with the preparation of presentations. 
&lt;/p&gt;
&lt;p&gt;
Preparatory Education: Legal Secretary Associate Degree from Moraine Park 
Technical College, Beaver Dam, Wisconsin.
&lt;/p&gt;', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CC9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   69, N'Kristie', N'Van Bogart', N'', N'KV', 1, 2, N'6516978502', N'', N'6516978555', N'kvanbogart@ehlers-inc.com', N'Human Resources Director', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Kristie Van Bogart joined Ehlers and Associates as the Human Resources Director in Oct 2002.  She brings 20+ years of human resources and line management experience to the team.  She has experience within the HR arena focusing in 
recruiting, project management, performance management and process design and improvement.  The majority of her experience has been with Fortune 500 firms. 
&lt;/p&gt; 
&lt;p&gt;
Ms. Van Bogart is responsible to support all three of Ehlers offices with human resource needs.  
&lt;/p&gt;', N'Bachelor of Arts from Iowa State University with a degree in Economics; SPHR', CAST( 0x75250B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CC9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   70, N'Pam', N'Eyer-Fitch', N'', N'PE', 0, 1, N'6302713338', N'', N'6302713369', N'', N'Administrative Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CC9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   71, N'Ken', N'Stanish', N'', N'KS', 0, 1, N'6302713335', N'', N'6302713369', N'', N'Financial Advisor', N'', CAST( 150.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CC9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   73, N'Jerry', N'Shannon', N'', N'JBS', 0, 2, N'6516978554', N'6127999435', N'6516978555', N'jshannon@ehlers-inc.com', N'Financial Advisor', N'', CAST( 185.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x02270B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CCA AS DateTime ), N'ccarson'  UNION ALL
    SELECT   74, N'Dave', N'Callister', N'', N'DC', 0, 2, N'6516978553', N'6512712854', N'6516978555', N'dcallister@ehlers-inc.com', N'Financial Advisor', N'Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x682A0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CCA AS DateTime ), N'ccarson'  UNION ALL
    SELECT   75, N'Lois', N'Bossert', N'', N'LB', 0, 2, N'6516978560', N'', N'6516978555', N'', N'Administrative Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'<p>
Ms. Bossert has been with Ehlers'' & Associates since June, 2004.  
Currently the Administrative Assistant in the Roseville office, she provides 
specialized administrative support to employees in the Minnesota office for 
a variety of the special products and services offered to our clients.  Her 
responsibilities include assistance in producing Key Financial Strategies 
and public participation materials, preparing Ehlers'' proposals, assisting 
with preparation of and comparisons of requests for lease purchase proposals, 
assists with compiling and mailing out marketing materials, assists in 
maintaining the Ehlers'' data base, and helps in preparing for Ehlers'' seminars. 
</p>', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CCA AS DateTime ), N'ccarson'  UNION ALL
    SELECT   76, N'Bruce', N'DeJong', N'', N'BMD', 0, 2, N'6516978548', N'', N'6516978555', N'', N'Financial Advisor', N'', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;
Ehlers &amp; Associates is pleased to announce that Bruce DeJong has joined 
the Ehlers Team as a Financial Advisor.  Bruce brings 20 years of local 
government financial experience to Ehler’s clients.  His experience in 
bonding, debt management, long-range capital expenditure planning, and tax 
increment financing ( TIF ) district strategies make him a valuable resource. 
He has been instrumental in upgrading bond ratings from Moody’s Investors 
Services and Standard and Poor’s, and acquiring state grants.
&lt;/p&gt;
&lt;p&gt;
Bruce is an active member of both the Minnesota and national Government 
Finance Officer’s Association.  His cities have been awarded the Certificate 
of Achievement from the Government Finance Officer’s Association in each of 
his 20 years.  He also was involved in creating a community investment fund, 
which was awarded the GFOA Award for Excellence in Cash Management. 
&lt;/p&gt;
&lt;p&gt;
Bruce received his Masters of Business Administration ( MBA ) from the Carlson 
School of Business at the University of Minnesota and a Bachelor of Arts in 
Economics with a minor in Accounting from St. Cloud State University.
&lt;/p&gt;
&lt;p&gt;
Bruce’s primary focus will be helping local governments to undertake long-range 
financial planning, create and manage TIF districts, finance capital projects 
and enterprise fund activities, and issue debt.
&lt;/p&gt;
&lt;p&gt;
Give Bruce a call to discuss your needs.
&lt;/p&gt;', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CCA AS DateTime ), N'ccarson'  UNION ALL
    SELECT   77, N'Dawn', N'Gunderson', N'', N'DG', 1, 3, N'2627966166', N'2629931443', N'2627851810', N'dgunderson@ehlers-inc.com', N'Financial Advisor', N'Vice President', CAST( 185.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x0D2B0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CCA AS DateTime ), N'ccarson'  UNION ALL
    SELECT   80, N'Angela', N'Connelly', N'', N'AC', 0, 2, N'6516978559', N'', NULL, N' ', N'Analyst Assisant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'<p>
Ms. Connelly has been with Ehlers & Associates since November, 2003.  Currently 
the Receptionist in the Roseville office, she provides general administrative 
support to employees in our Minnesota office.  Her responsibilities include 
sorting and distributing mail, answering phones, greeting clients and visitors, 
generating and mailing out monthly invoices, monitoring accounts receivable, 
posting bond sale results on our website, and making travel, meeting, and 
conference arrangements for employees.  She also orders office supplies and 
archives final bond issue and tax increment records into permanent electronic 
format.
</p>', N' ', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CCA AS DateTime ), N'ccarson'  UNION ALL
    SELECT   81, N'Patricia', N'Nolan', N'', N'PN', 0, 1, N'6302713343', N'', N'6302713369', N'', N'TIF Coordinator', N'', CAST( 100.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CCA AS DateTime ), N'ccarson'  UNION ALL
    SELECT   86, N'Briana', N'Isiminger', N'', N'BI', 0, 2, N'6516978556', N'', N'6516978555', N'', N'Analyst Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CCB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   89, N'Greg', N'Kioski', N'', N'GK', 0, 2, N'6516978529', N'6513564410', N'6516978555', N'gkioski@ehlers-inc.com', N'Information Technology', N'', CAST( 100.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'Greg Kioski joined Ehlers as the Director of Information Technology in August, 2007; he is retiring March of 2010.  He has more than forty years of experience in computer consulting and specializes in computational software development</p>', N'Bachelor of Science ( Physics ), Loyola Marymount University; Masters in Software Design & Development, University of St. Thomas', CAST( 0xEB2E0B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   91, N'Sue', N'Porter', N'', N'SP', 1, 3, N'2627966167', N'', N'2627851810', N'sporter@ehlers-inc.com', N'Senior Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Porter joined Ehlers in August of 2005 and works from our Brookfield office as an Analyst. Prior to joining Ehlers, Sue was employed with the City of Mayville, serving as City Clerk. Her main duties include gathering, analyzing and organizing data necessary to produce official statements; preparing post sale documentation following each assigned financing; preparation and submittal of annual disclosure reporting; assisting financial advisors in their preparatory work for their clients and monitoring outstanding debt for potential refundings. Sue also is responsible for facilitating the marketing efforts for the Wisconsin office. You will see her at various conferences throughout the year in the Ehlers'' booth.', N' ', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   95, N'Justin', N'Longley', N'', N'JL', 0, 3, N'2627966164', N'', N'2627857270', N'', N'', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;JUSTIN LONGLEY joined Ehlers and Associates in
September of 2005 as a member of the Wisconsin
Financial Advisory Team. Justin received his
bachelor&#039;s degree in accounting and finance from
Marquette University in 2002, and his Juris
Doctor from Marquette University Law School in
2005. Prior to joining Ehlers, Justin worked at
The Lynde and Harry Bradley Foundation on its finance staff and
at Artisan Partners on its international equity team.
&lt;/p&gt;
&lt;p&gt;
Justin works on a variety of financial advisory
projects, assisting other financial advisors in the preparation of
financing and TIF plans.
&lt;/p&gt;', N'', CAST( 0x02270B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CCB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   96, N'Greg', N'Johnson', N'', N'GJ', 1, 3, N'2627966168', N'2627199105', N'2627851810', N'gjohnson@ehlers-inc.com', N'Financial Advisor', N'', CAST( 185.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x3D2C0B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CCB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   97, N'Lisa M.', N'Lyon', N'', N'LML', 0, 1, N'6302713341', N'', N'6302713369', N'', N'Financial Advisor', N'', CAST( 150.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   100, N'Gary', N'Kawlewski', N'', N'GKa', 0, 2, N'6516978551', N'6513413316', N'6516978555', N'', N'Financial Advisor', N'', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCB AS DateTime ), N'ccarson'  UNION ALL
    SELECT   101, N'Karen', N'Smothers', N'', N'KDS', 0, 2, N'6516978549', N'', N'6516978555', N'ksmothers@ehlers-inc.com', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'Ms. Smothers joined Ehlers in 2006, and currently serves as an Office Assistant in the Minnesota office.  Ms. Smothers provides general administrative support to employees in all Ehlers’ offices.  Other responsibilities include duties related to the printing of Official Statements, monitoring office supplies, archiving documents into permanent electronic format, and coordinating general maintenance of office equipment.', N'Minneapolis Business College ( Legal Secretary ) Roseville, Minnesota', CAST( 0x02270B00 AS Date ), 0, 1, 0, CAST( 0x0000A14000B35CCC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   107, N'Lorraine', N'Swenson', N'', N'LS', 0, 2, N'6516978560', N'', N'6516978555', N'lswenson@ehlers-inc.com', N'Administrative Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'Ms. Swenson joined Ehlers in 2006, and currently serves as an Administrative Assistant in the Minnesota office.  Ms. Swenson''s main duties include general office support, answering phones, greeting clients, helping with seminar and travel arrangements, generating monthly invoices, and assembling, printing, binding, and distributing materials for conferences and client presentations.', N'Certificate, Minnesota School of Business - Minneapolis, MN', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   108, N'Jaime', N'Berglund', N'', N'JB', 0, 2, N'6516978559', N'', N'6516978555', N'', N'Analyst Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CCC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   111, N'Judieth', N'Morrison', N'', N'JM', 0, 1, N'6302713338', N'', N'6302713369', N'jmorrison@ehlers-inc.com', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Judy Morrison joined Ehlers &amp; Associates in September, 2006 and works out of the Lisle, Illinois office as an Office Assistant. Her main duties include general office support, answering phones, greeting clients, helping with seminar arrangements, helping to prepare proposals, compiling data for various projects, updating project lists weekly and assisting with the preparation of presentations.
&lt;/p&gt;', N'', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   112, N'Pia', N'Troy', N'', N'PT', 1, 2, N'6516978556', N'', N'6516978555', N'ptroy@ehlers-inc.com', N'Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Troy joined Ehlers in 2006, and currently serves as an Analyst in the Minnesota office and works with issuers in both Minnesota and Wisconsin.  As an Analyst, her main duties include gathering, analyzing and organizing data necessary to produce official statements and continuing disclosure reports.', N'Bachelor of Arts ( Spanish ), Minnesota State University - Moorhead, Minnesota', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCC AS DateTime ), N'ccarson'  UNION ALL
    SELECT   113, N'Brad', N'Townsend', N'', N'BT', 1, 1, N'6302713335', N'6303908800', N'6302713369', N'btownsend@ehlers-inc.com', N'Financial Advisor', N'Executive Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xCF2D0B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   114, N'Danica', N'Stith', N'', N'DS', 0, 2, N'6516978559', N'', N'6516978555', N'', N'Associate Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CCD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   115, N'Rebecca', N'Janicke', N'', N'RJ', 0, 2, N'6516978566', N'6512475394', N'6516978555', N'rjanicke@ehlers-inc.com', N'Marketing Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'As the Marketing Coordinator for the Minnesota office Ms. Janicke maintains Ehlers'' relationships with more than 25 professional associations that support school districts, cities, townships, and counties.  Meeting regularly with clients and their affiliated organizations she oversees advertising, sponsorships, and conference attendance in order to support client''s professional development and promote Ehlers services.  

 

She brings a wealth of knowledge from her professional background which includes positions in the Executive and Legislative branches of state government and corporate offices of Marshall Field''s, Neiman Marcus, and Target Corporation.', N'Bachelor of Arts ( Political Science and International Studies ) University of St. Thomas', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   116, N'Gail', N'Robertson', N'', N'GR', 1, 2, N'6516978567', N'6514703122', N'6516978555', N'grobertson@ehlers-inc.com', N'Senior Financial Specialist, Arbitrage', N'', CAST( 200.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x4E2E0B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   117, N'Robin', N'Broen', N'', N'RB', 1, 2, N'6516978518', N'', N'6516978555', N'rbroen@ehlers-inc.com', N'TIF Coordinator', N'', CAST( 170.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'&lt;p&gt;Ms. Broen works as a TIF Coordinator in the Minnesota office specifically with Minnesota cities and counties.  She helps clients achieve their redevelopment, housing and economic development goals through the use of tax increment financing.  Ms. Broen prepares TIF documents, resolutions, and official notices to establish and modify districts, and ensures clients meet statutory deadlines and procedural requirements. In addition to the work provided for TIF districts, Ms. Broen aids in the planning and coordination of the annual Public Finance Seminar hosted by Ehlers and assists Financial Advisors with completion of special projects. &lt;/p&gt;

Ms. Broen has been with Ehlers &amp; Associates since March of 2007. Before joining Ehlers, she worked as an intern for the City of Anoka Community Development Department.  While interning for the City, she coordinated the creation of a TIF District in the City&#039;s downtown and researched statistical data necessary for the Economic Development Commission to make future decisions about the growth of the City.', N'Bachelor of Science from St. Cloud State University with a major in Real Estate and a minor in Community Development.', CAST( 0x02270B00 AS Date ), 0, 1, 0, CAST( 0x0000A14000B35CCD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   118, N'Kathy', N'Kardell', N'', N'KK', 0, 2, N'6516978548', N'6514703122', N'6516978555', N'kkardell@ehlers-inc.com', N'Financial Advisor', N'', CAST( 185.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCD AS DateTime ), N'ccarson'  UNION ALL
    SELECT   119, N'Wendy', N'Asmann', N'', N'WA', 0, 3, N'2627966160', N'', N'2627851810', N'wasmann@ehlers-inc.com', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'Wendy Asmann joined Ehlers & Associates in June 2007 and currently serves as an Office Assistant in the Wisconsin Office. Her main duties include general office support, answering phones and greeting clients. Other duties include updating master client list and project lists weekly, assist with seminar arrangements, create lists and power point presentations, monitor office supplies within a budget, maintenance of office equipment, sending disclosure reports and assembling, printing, and binding client presentations.', N'Bachelor of Science ( Management in Technical Operations ) Embry Riddle Aeronautical University - Daytona Beach, FL; Associates of Science ( Business Management, Social Psychology ) Park University, Parkville, MO', CAST( 0x02270B00 AS Date ), 0, 1, 0, CAST( 0x0000A14000B35CCE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   120, N'Tom', N'Berge', N'', N'TB', 1, 2, N'6516978570', N'6513667524', N'6516978555', N'tberge@ehlers-inc.com', N'Financial Advisor', N'', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x912E0B00 AS Date ), 0, 1, 0, CAST( 0x0000A14000B35CCE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   121, N'Jonathan', N'North', N'', N'JN', 0, 2, N'6516978545', N'6514021907', N'6516978555', N'jnorth@ehlers-inc.com', N'Financial Advisor', N'', CAST( 190.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xB52E0B00 AS Date ), 0, 1, 0, CAST( 0x0000A14000B35CCE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   122, N'Rose', N'Price', N'', N'RP', 0, 2, N'6516978532', N'', N'6516978555', N'rprice@ehlers-inc.com', N'Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'Ms. Price joined Ehlers in 2007, and currently serves as an Associate Analyst in the Minnesota office and works with issuers in both Minnesota and Wisconsin.  As an Associate Analyst, her main duties include gathering, analyzing and organizing data necessary to produce official statements and continuing disclosure reports.', N'Liberal Arts Major, North Hennepin Community College - Brooklyn Park, MN', CAST( 0x02270B00 AS Date ), 0, 1, 0, CAST( 0x0000A14000B35CCE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   123, N'Maureen', N'Barry', N'', N'MB', 1, 1, N'6302713341', N'6303350784', N'6302713369', N'mbarry@ehlers-inc.com', N'Financial Advisor', N'', CAST( 180.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x4D300B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CCE AS DateTime ), N'ccarson'  UNION ALL
    SELECT   126, N'Nancy', N'Hill', N'', N'NH', 1, 1, N'6302713343', N'6303353530', N'6302713369', N'nhill@ehlers-inc.com', N'Financial Advisor', N'', CAST( 180.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x4D300B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CCF AS DateTime ), N'ccarson'  UNION ALL
    SELECT   127, N'Jeanne', N'Vogt', N'', N'JV', 1, 2, N'6516978571', N'', N'6516978555', N'jvogt@ehlers-inc.com', N'Financial Specialist', N'', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xFC2F0B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CCF AS DateTime ), N'ccarson'  UNION ALL
    SELECT   146, N'Bruce', N'Kimmel', N'', N'BKi', 1, 2, N'6516978572', N'6513413316', N'6516970281', N'bkimmel@ehlers-inc.com', N'Senior Financial Advisor', N'Vice President', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0x4D300B00 AS Date ), 0, 0, 1, CAST( 0x0000A14000B35CCF AS DateTime ), N'ccarson'  UNION ALL
    SELECT   148, N'Lisa', N'Kauls', N'', N'LK', 0, 2, N'6516978549', N'', N'6516978555', N'lkauls@ehlers-inc.com', N'Assoc Bond Sale Coordinator / Assoc Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x3D330B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CCF AS DateTime ), N'ccarson'  UNION ALL
    SELECT   149, N'Mike', N'Solomon', N'', N'MS', 0, 2, N'6516978542', N'', N'6516978555', N'msolomon@ehlers-inc.com', N'Associate Financial Analyst', N'', CAST( 150.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CCF AS DateTime ), N'ccarson'  UNION ALL
    SELECT   150, N'Kristina', N'Norquist', N'', N'KrN', 1, 2, N'6516978577', N'', N'6516978555', N'knorquist@ehlers-inc.com', N'Associate Financial Specialist', N'', CAST( 200.00 AS Decimal( 15, 2 ) ), CAST( 81.00 AS Decimal( 15, 2 ) ), N'Ms. Norquist joined Ehlers in 2008 as a Financial Analyst in Ehlers'' arbitrage practice supporting the Minnesota, Wisconsin, and Illinois offices.  Her role includes preparing arbitrage reports and assisting issuers with the implementation of post-issuance compliance policy and procedures.  She ensures timely and accurate arbitrage computations, as well as compliance with the requirements of the Internal Revenue Code and Treasury Regulations.

Prior to joining Ehlers, Ms. Miles held an accounting position in regulatory reporting with a nationally recognized insurance company.  She was responsible for analyzing general ledger accounts and business variances, preparing statutory financial statements and organizing information for external auditors.  Ehlers'' clients will benefit from Kristina''s accounting education and work experience.', N'Cum Laude graduate with a Bachelor of Science in Accounting from St. Cloud St. University, St. Cloud, Minnesota.', CAST( 0x02270B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CD0 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   151, N'Martin', N'Schultz', N'', N'MFS', 1, 2, N'6516978578', N'', N'6516978555', N'mschultz@ehlers-inc.com', N'Information Technology Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x10320B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD0 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   152, N'Jodie', N'Zesbaugh', N'', N'JZ', 1, 2, N'6516978526', N'', N'6516978555', N'jzesbaugh@ehlers-inc.com', N'Financial Advisor', N'', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xDC310B00 AS Date ), 0, 1, 0, CAST( 0x0000A14000B35CD0 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   153, N'Jeff', N'Seeley', N'', N'JSe', 1, 2, N'6516978585', N'6514026592', N'6516978555', N'jseeley@ehlers-inc.com', N'Financial Advisor', N'', CAST( 175.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'resume', N'', CAST( 0xDF310B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CD0 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   154, N'Deb', N'Rickard', N'', N'DR', 0, 2, N'6516978582', N'9522408918', N'6516978555', N'drickard@ehlers-inc.com', N'Director of Information Technology', N'', CAST( 100.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'Ms. Rickard became part of the Ehlers team in November of 2009.  She is responsible for all business applications, IT hardware and software, network availability, and telephony systems.

Ms. Rickard brings over twenty-five years of experience in Information Technology, with over ten years in leading IT teams and corporate-wide projects.', N'Bachelor of Music Education UW - Eau Claire, Associate Degree in Data Processing NCTI Wausau, WI', CAST( 0x6B320B00 AS Date ), 1, 1, 0, CAST( 0x0000A14000B35CD1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   155, N'Joseph', N'Gaouette', N'', N'JG', 0, 2, N'6516978586', N'', N'6516978555', N'jgaouette@ehlers-inc.com', N'Intern', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   157, N'Tim', N'Schram', N'', N'TS', 1, 2, N'6516978533', N'', N'6516978555', N'tschram@ehlers-inc.com', N'Marketing Communications Director', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0xFE320B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD1 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   158, N'Veronica', N'Rudychev', N'', N'VR', 0, 3, N'2627966169', N'', N'2627851810', N'vrudychev@ehlers-inc.com', N'TIF Supervisor', N'', CAST( 170.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x1A330B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD3 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   172, N'Tracy', N'Ringwell', N'', N'TR', 1, 3, N'2627966160', N'', N'2627851810', N'tringwell@ehlers-inc.com', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x21330B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD4 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   173, N'Sharon', N'Doyle', N'', N'SD', 1, 2, N'6516978530', N'', N'6516970281', N'sdoyle@ehlers-inc.com', N'Associate Financial Specialist', N'', CAST( 200.00 AS Decimal( 15, 2 ) ), CAST( 81.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x24330B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD5 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   183, N'Alicia', N'Gage', N'', N'AG', 1, 2, N'6516978551', N'', N'6516978555', N'agage@ehlers-inc.com', N'Senior Financial Analyst', N'', CAST( 190.00 AS Decimal( 15, 2 ) ), CAST( 81.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0xE6330B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD5 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   191, N'Clare', N'Naughton', N'', N'CN', 0, 2, N'6516978531', N'', N'6516978555', N'cnaughton@ehlers-inc.com', N'Utility Rate Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 48.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x72340B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD5 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   203, N'John', N'Miller', N'', N'JMi', 1, 1, N'6302713336', N'6303107039', N'6302713369', N'jmiller@ehlers-inc.com', N'Financial Advisor', N'', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 111.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0xCA340B00 AS Date ), 1, 0, 0, CAST( 0x0000A14000B35CD6 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   206, N'Brendan', N'Leonard', N'', N'BL', 1, 3, N'2627966169', N'', N'2627851810', N'bleonard@ehlers-inc.com', N'Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 75.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x0B350B00 AS Date ), 1, 1, 1, CAST( 0x0000A14000B35CD6 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   207, N'Ken', N'Herdeman', N'', N'KH', 1, 3, N'2627966164', N'', N'2627851810', N'kherdeman@ehlers-inc.com', N'Ehlers Investment Partners President', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x26350B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD6 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   211, N'Brian', N'Mann', N'', N'BM', 0, 2, N'6516978568', N'6082342738', N'6516978555', N'bmann@ehlers-inc.com', N'Municipal Asset Manager', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x26350B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD6 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   212, N'Dawn', N'Tracy', N'', N'DT', 1, 3, N'2627966174', N'', N'2627851810', N'dtracy@ehlers-inc.com', N'Investment Services Analyst/Administrator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x26350B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   214, N'Kara', N'Meverden', N'', N'KaM', 1, 2, N'6516978545', N'', N'6516978555', N'kmeverden@ehlers-inc.com', N'Senior Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x3C350B00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   215, N'Ginene', N'Schultz', N'', N'GS', 1, 2, N'6516978545', N'', N'6516978555', N'gschultz@ehlers-inc.com', N'Senior Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   216, N'Missy', N'Breiwick', N'', N'MBr', 1, 2, N'6516978525', N'', N'6516978555', N'mbreiwick@ehlers-inc.com', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   217, N'Cassie', N'Heinrich', N'', N'CH', 0, 2, N'6516978530', N'', N'6516978555', N'cheinrich@ehlers-inc.com', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   218, N'Kyle', N'Larson', N'', N'KL', 0, 2, N'6516978530', N'', N'6516978555', N'klarson@ehlers-inc.com', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   220, N'Jake', N'DeBower', N'', N'JD', 1, 3, N'', N'', NULL, N'jdebower@ehlers-inc.com', N'TIF Coordinator', N'', CAST( 170.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD7 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   221, N'Darin', N'Norman', N'', N'DN', 1, 3, N'6516978512', N'', NULL, N'dnorman@ehlers-inc.com', N'Financial Analyst', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   222, N'Nick', N'Anhut', N'', N'NA', 1, 3, N'', N'', NULL, N'nanhut@ehlers-inc.com', N'Financial Specialist', N'', CAST( 195.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   224, N'Jack', N'Fay', N'', N'JF', 1, 3, N'', N'', NULL, N'jfay@ehlers-inc.com', N'Municipal Investment Advisor', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   226, N'Tanysha', N'Scott', N'', N'TSc', 1, 3, N'', N'', NULL, N'tscott@ehlers-inc.com', N'', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD8 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   227, N'Jay', N'Willms', N'', N'JW', 1, 3, N'', N'', NULL, N'jwillms@ehlers-inc.com', N'Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   228, N'Shawn', N'Hafner', N'', N'SH', 1, 3, N'', N'', NULL, N'shafner@ehlers-inc.com', N'Office Assistant', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   229, N'Kristen', N'Polson', N'', N'KP', 1, 3, N'', N'', NULL, N'kpolson@ehlers-inc.com', N'Disclosure Coordinator', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   231, N'Greg', N'Crowe', N'', N'GC', 1, 3, N'', N'', NULL, N'gcrowe@ehlers-inc.com', N'Financial Advisor', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   232, N'David', N'Holleran', N'', N'DHo', 1, 3, N'', N'', NULL, N'dholleran@ehlers-inc.com', N'Business Operations Principal', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD9 AS DateTime ), N'ccarson'  UNION ALL
    SELECT   233, N'Maureen', N'Manning', N'', N'MM', 1, 3, N'', N'', NULL, N'mmanning@ehlers-inc.com', N'Financial Specialist I', N'', CAST( 0.00 AS Decimal( 15, 2 ) ), CAST( 0.00 AS Decimal( 15, 2 ) ), N'', N'', CAST( 0x5B950A00 AS Date ), 0, 0, 0, CAST( 0x0000A14000B35CD9 AS DateTime ), N'ccarson' ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.EhlersEmployee    = ' + STR( @count, 8 ) ; 


    SET IDENTITY_INSERT dbo.EhlersEmployee OFF
    SET IDENTITY_INSERT dbo.EhlersJobGroup ON ;

    INSERT  dbo.EhlersJobGroup ( EhlersJobGroupID, Value, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'BSC', 1, N'Bond Sale Coordinators', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Corp', 1, N'Corporate', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'FA', 1, N'Financial Advisors', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'FinA', 1, N'Financial Analysts', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'FS', 1, N'Financial Specialist', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'IT', 1, N'IT', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'DC', 1, N'Disclosure Coordinators', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  8, N'TIF', 1, N'TIF Coordinator', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  9, N'EIP', 1, N'Ehlers Investment Partners', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.EhlersJobGroup    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.EhlersJobGroup OFF ;
    SET IDENTITY_INSERT dbo.EhlersEmployeeJobGroups ON ;

    INSERT  dbo.EhlersEmployeeJobGroups ( EhlersEmployeeJobGroupsID, EhlersEmployeeID, EhlersJobGroupID, Active, ModifiedDate, ModifiedUser )  
    SELECT  217, 67, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  218, 4, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  219, 15, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  220, 59, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  221, 69, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  222, 216, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  224, 228, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  225, 157, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  226, 172, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  227, 232, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  228, 206, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  229, 12, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  230, 215, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  231, 227, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  232, 214, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  233, 35, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  234, 41, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  235, 112, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  237, 91, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  238, 64, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  239, 229, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  240, 212, 9, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  241, 224, 9, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  242, 207, 9, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  243, 58, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  244, 113, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  245, 65, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  246, 146, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  247, 5, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  248, 7, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  249, 77, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  250, 18, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  253, 19, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  254, 153, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  255, 60, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  256, 152, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  257, 20, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  258, 203, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  259, 37, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  260, 123, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  263, 32, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  265, 126, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  266, 42, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  267, 44, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  268, 53, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  269, 50, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  270, 47, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  271, 52, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  272, 48, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  273, 49, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  274, 54, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  275, 61, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  276, 120, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  277, 231, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  278, 233, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  279, 183, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  280, 1, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  281, 221, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  283, 30, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  284, 33, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  285, 17, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  286, 116, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  287, 127, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  288, 150, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  289, 222, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  290, 173, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  292, 151, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  295, 220, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  296, 34, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  297, 41, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  298, 117, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  299, 11, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  300, 96, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  301, 66, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  302, 22, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  303, 28, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  304, 148, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  305, 226, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  306, 24, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  307, 75, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  308, 107, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  309, 38, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  310, 115, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  311, 45, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  312, 56, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  313, 68, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  314, 80, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  315, 86, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  316, 154, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  317, 9, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  318, 13, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  319, 89, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  320, 111, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  321, 97, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  322, 119, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  323, 217, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  324, 114, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  325, 6, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  326, 14, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  327, 108, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  328, 95, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  329, 26, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  330, 29, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  331, 218, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  332, 31, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  333, 57, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  334, 122, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  335, 51, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  336, 63, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  337, 55, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  338, 211, 9, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  339, 149, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  340, 191, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  341, 155, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  342, 39, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  343, 81, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  344, 46, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  345, 158, 8, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  346, 76, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  347, 74, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  348, 8, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  349, 10, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  350, 16, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  351, 100, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  352, 73, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  353, 21, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  354, 62, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  355, 23, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  356, 121, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  357, 118, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  358, 71, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  359, 27, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  360, 70, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  361, 43, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  362, 25, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  363, 2, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  364, 101, 2, 1, GETDATE(), N'Conversion'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.EhlersEmployeeJobGroups    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.EhlersEmployeeJobGroups OFF ;
    SET IDENTITY_INSERT dbo.EhlersJobTeam ON ;

    INSERT  dbo.EhlersJobTeam ( EhlersJobTeamID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'MN City', 1, 1, NULL, GETDATE(), N'dholmes', N'MN City'
    UNION ALL SELECT  2, N'MN Education', 2, 1, NULL, GETDATE(), N'dholmes', N'MN Education'
    UNION ALL SELECT  3, N'Wisconsin', 3, 1, NULL, GETDATE(), N'dholmes', N'Wisconsin'
    UNION ALL SELECT  4, N'Illinois', 4, 1, NULL, GETDATE(), N'dholmes', N'Illinois'
    UNION ALL SELECT  5, N'Corporate', 5, 1, NULL, GETDATE(), N'dholmes', N'Corporate'
    UNION ALL SELECT  6, N'EIP', 6, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'Unassigned', 99, 0, NULL, GETDATE(), N'Conversion', N'U'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.EhlersJobTeam    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.EhlersJobTeam OFF ;
    SET IDENTITY_INSERT dbo.EhlersEmployeeJobTeams ON ;

    INSERT  dbo.EhlersEmployeeJobTeams ( EhlersEmployeeJobTeamsID, EhlersEmployeeID, EhlersJobTeamID, Active, ModifiedDate, ModifiedUser )  
    SELECT  79, 59, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  80, 11, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  81, 69, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  82, 151, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  83, 216, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  84, 48, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  85, 157, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  86, 232, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  87, 212, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  88, 224, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  89, 207, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  93, 113, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  94, 1, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  95, 203, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  96, 123, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  97, 35, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  98, 34, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  99, 126, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  100, 47, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  101, 49, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  102, 61, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  103, 183, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  104, 67, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  105, 65, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  106, 146, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  107, 5, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  108, 221, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  109, 15, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  110, 17, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  111, 116, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  112, 215, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  113, 220, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  114, 227, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  115, 127, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  116, 60, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  117, 214, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  118, 150, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  119, 37, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  120, 222, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  121, 44, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  122, 117, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  123, 53, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  124, 173, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  125, 228, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  126, 50, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  127, 52, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  128, 48, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  129, 54, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  130, 58, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  131, 1, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  132, 5, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  133, 15, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  134, 12, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  135, 18, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  136, 153, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  137, 152, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  138, 20, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  139, 112, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  140, 120, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  141, 64, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  142, 231, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  143, 206, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  144, 1, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  145, 65, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  146, 4, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  147, 7, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  148, 77, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  149, 96, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  151, 19, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  153, 30, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  154, 33, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  155, 32, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  156, 41, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  157, 42, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  158, 53, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  159, 91, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  160, 61, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  161, 172, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  162, 229, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  163, 233, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  164, 154, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  165, 9, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  166, 13, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  167, 89, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  168, 24, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  169, 97, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  170, 38, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  171, 115, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  172, 45, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  173, 56, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  174, 211, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  175, 10, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  176, 16, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  177, 62, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  178, 23, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  179, 81, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  180, 80, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  181, 66, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  182, 2, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  183, 86, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  184, 76, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  185, 217, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  186, 191, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  187, 114, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  188, 74, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  189, 14, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  190, 108, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  191, 22, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  192, 73, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  193, 21, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  194, 121, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  195, 155, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  196, 101, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  197, 118, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  198, 28, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  199, 26, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  200, 29, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  201, 218, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  202, 31, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  203, 148, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  204, 75, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  205, 107, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  206, 149, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  207, 39, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  208, 43, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  209, 122, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  210, 51, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  211, 63, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  212, 46, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  213, 226, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  214, 158, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  215, 100, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  216, 27, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  217, 57, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  218, 68, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  219, 6, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  220, 8, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  221, 111, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  222, 95, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  223, 71, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  224, 55, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  225, 119, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  226, 70, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  227, 25, 1, 1, GETDATE(), N'Conversion'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.EhlersEmployeeJobTeams    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.EhlersEmployeeJobTeams OFF ;
    SET IDENTITY_INSERT dbo.ProjectServiceJobTeams ON ;

    INSERT  dbo.ProjectServiceJobTeams ( ProjectServiceJobTeamsID, ProjectServiceID, EhlersJobTeamID, Active, ModifiedDate, ModifiedUser )  
    SELECT  1, 362, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  2, 362, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  3, 362, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  4, 362, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  5, 362, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  6, 362, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  7, 362, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  8, 361, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  9, 361, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  10, 361, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  11, 361, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  12, 361, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  13, 361, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  14, 361, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  15, 357, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  16, 357, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  17, 357, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  18, 357, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  19, 357, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  20, 357, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  21, 357, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  22, 358, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  23, 358, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  24, 358, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  25, 358, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  26, 358, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  27, 358, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  28, 358, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  29, 359, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  30, 359, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  31, 359, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  32, 359, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  33, 359, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  34, 359, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  35, 359, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  36, 369, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  37, 369, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  38, 369, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  39, 369, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  40, 369, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  41, 369, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  42, 369, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  43, 399, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  44, 399, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  45, 399, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  46, 399, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  47, 399, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  48, 399, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  49, 399, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  50, 392, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  51, 392, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  52, 392, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  53, 392, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  54, 392, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  55, 392, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  56, 392, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  57, 404, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  58, 404, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  59, 404, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  60, 404, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  61, 404, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  62, 404, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  63, 404, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  64, 356, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  65, 356, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  66, 356, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  67, 356, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  68, 356, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  69, 356, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  70, 356, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  78, 401, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  79, 411, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  80, 396, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  81, 383, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  82, 410, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  83, 382, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  84, 403, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  85, 407, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  86, 412, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  87, 385, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  88, 378, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  89, 364, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  90, 389, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  91, 389, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  92, 398, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  93, 398, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  94, 384, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  95, 384, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  96, 400, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  97, 400, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  98, 395, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  99, 395, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  100, 402, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  101, 402, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  102, 372, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  103, 372, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  104, 409, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  105, 409, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  106, 381, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  107, 381, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  108, 406, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  109, 406, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  110, 368, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  111, 365, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  112, 374, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  113, 370, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  114, 380, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  115, 379, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  116, 373, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  117, 377, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  118, 390, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  119, 405, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  122, 388, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  123, 388, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  124, 388, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  125, 397, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  126, 397, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  127, 397, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  128, 391, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  129, 391, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  130, 391, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  131, 366, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  132, 366, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  133, 366, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  134, 393, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  135, 393, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  136, 387, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  137, 387, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  138, 376, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  139, 376, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  140, 375, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  141, 375, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  142, 371, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  143, 371, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  144, 367, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  145, 386, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  146, 386, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  147, 394, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  148, 408, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  149, 408, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  150, 355, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  151, 355, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  152, 355, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  153, 355, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  154, 355, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  155, 355, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  156, 355, 3, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  157, 360, 5, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  158, 360, 6, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  159, 360, 4, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  160, 360, 1, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  161, 360, 2, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  162, 360, 7, 1, GETDATE(), N'Conversion'
    UNION ALL SELECT  163, 360, 3, 1, GETDATE(), N'Conversion'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ProjectServiceJobTeams    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ProjectServiceJobTeams OFF ;
    SET IDENTITY_INSERT dbo.ListCategory ON ;

    INSERT  dbo.ListCategory ( ListCategoryID, CategoryName, Information )  
    SELECT  220, N'AnticipationCertificate', N'Issue'
    UNION ALL SELECT  222, N'ArbitrageExceptionNotMet', N'Arbritrage'
    UNION ALL SELECT  229, N'ARRACreditRecipient', N'ARRABond'
    UNION ALL SELECT  230, N'ARRAReimbursementPercent', N'ARRABond'
    UNION ALL SELECT  232, N'AssessCalcMethod', N'FundingSource'
    UNION ALL SELECT  234, N'AwardBasis', N'BiddingParameter'
    UNION ALL SELECT  243, N'DebtServiceYear', N'Issue'
    UNION ALL SELECT  272, N'ProjectStatus', N'Project'
    UNION ALL SELECT  279, N'TaxStatus', N'Issue'
    UNION ALL SELECT  288, N'NamePrefix', N'Contact'
    UNION ALL SELECT  289, N'IssueRefundType', N'Refunding'
    UNION ALL SELECT  293, N'MayorVote', N'Client - Identification'
    UNION ALL SELECT  294, N'IssuanceLimitBasedOn', N'Issuance fee'
    UNION ALL SELECT  295, N'GoodFaithDestination', N'Issue'
    UNION ALL SELECT  296, N'ContractType', N'Client Disclosure'
    UNION ALL SELECT  297, N'ContractBillingType', N'Client Disclosure'
    UNION ALL SELECT  298, N'MaterialEventInvoicing', N'Client Disclosure'
    UNION ALL SELECT  299, N'ClientReportCharge', N'Client Disclosure'
    UNION ALL SELECT  300, N'ClientAuditReportType', N'Client Disclosure'
    UNION ALL SELECT  301, N'ClientAuditReportInvoicing', N'Client Disclosure'
    UNION ALL SELECT  302, N'BackingPayment', N'Purpose'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ListCategory    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ListCategory OFF ;
    SET IDENTITY_INSERT dbo.StaticList ON ;

    INSERT  dbo.StaticList ( StaticListID, ListCategoryID, DisplayValue, DisplaySequence, Description, Active, OldKey, OldListValue, ModifiedDate, ModifiedUser )  
    SELECT  7492, 220, N'AAC', 0, N'General Obligation Aid Anticipation Certificates of Indebtedness', 1, N'066-001', N'AAC', GETDATE(), N'Conversion'
    UNION ALL SELECT  7493, 220, N'TAC', 0, N'General Obligation Tax Anticipation Certificates of Indebtedness', 1, N'066-002', N'TAC', GETDATE(), N'Conversion'
    UNION ALL SELECT  7497, 222, N'Pay Rebate', 0, N'', 1, N'073-001', N'AR', GETDATE(), N'Conversion'
    UNION ALL SELECT  7498, 222, N'Pay Penalty', 0, N'', 1, N'073-002', N'AP', GETDATE(), N'Conversion'
    UNION ALL SELECT  7525, 229, N'Issuer', 0, N'', 1, N'072-001', N'IS', GETDATE(), N'Conversion'
    UNION ALL SELECT  7526, 229, N'Investor', 0, N'', 1, N'072-002', N'IN', GETDATE(), N'Conversion'
    UNION ALL SELECT  7527, 230, N'35', 0, N'', 1, N'076-001', N'35%', GETDATE(), N'Conversion'
    UNION ALL SELECT  7528, 230, N'45', 0, N'', 1, N'076-002', N'45%', GETDATE(), N'Conversion'
    UNION ALL SELECT  7532, 232, N'Equal Principal', 0, N'', 1, N'039-001', N'PRIN', GETDATE(), N'Conversion'
    UNION ALL SELECT  7533, 232, N'Equal Principal and Interest', 0, N'', 1, N'039-002', N'P&I', GETDATE(), N'Conversion'
    UNION ALL SELECT  7537, 234, N'TIC', 0, N'', 1, N'045-001', N'TIC', GETDATE(), N'Conversion'
    UNION ALL SELECT  7538, 234, N'NIC', 0, N'', 1, N'045-002', N'NIC', GETDATE(), N'Conversion'
    UNION ALL SELECT  7661, 243, N'Calendar Year', 0, N'Semi-annual debt payments are grouped within the same calendar year', 1, N'052-001', N'CY', GETDATE(), N'Conversion'
    UNION ALL SELECT  7662, 243, N'Spit year', 0, N'Semi-annual debt payments are grouped to cross over calendar years', 1, N'052-002', N'SY', GETDATE(), N'Conversion'
    UNION ALL SELECT  7956, 272, N'Open', 0, N'', 1, N'019-001', N'O', GETDATE(), N'Conversion'
    UNION ALL SELECT  7957, 272, N'Closed', 0, N'', 1, N'019-002', N'C', GETDATE(), N'Conversion'
    UNION ALL SELECT  8047, 279, N'Tax Exempt', 0, N'', 1, N'043-001', N'TE', GETDATE(), N'Conversion'
    UNION ALL SELECT  8048, 279, N'Taxable', 0, N'', 1, N'043-002', N'T', GETDATE(), N'Conversion'
    UNION ALL SELECT  8205, 288, N'Mr.', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8206, 288, N'Ms.', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8207, 288, N'Mrs.', 3, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8208, 288, N'Dr.', 4, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8209, 289, N'Full', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8210, 289, N'Partial Issue', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8211, 289, N'Partial Maturitues', 3, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8305, 293, N'On all Council Matters', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8306, 293, N'Only in Case of Tie', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8307, 294, N'Par', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8308, 294, N'Issue Price', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8309, 295, N'To Ehlers', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8310, 295, N'To Issue', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8311, 296, N'Full', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8312, 296, N'Limited', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8313, 297, N'Ehlers Fee Basis', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8314, 297, N'Ehlers Hourly', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8315, 297, N'Client', 3, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8316, 298, N'Invoice', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8317, 298, N'No Charge', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8318, 298, N'Invoice with Full Amount Report', 3, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8319, 299, N'Invoice', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8320, 299, N'No Charge', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8321, 300, N'Audit', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8322, 300, N'CAFR', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8323, 301, N'Invoice for Limited', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8324, 301, N'No Charge', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8325, 301, N'Invoice with Full Annual Report', 3, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8326, 302, N'Secured', 1, N'', 1, NULL, N'', GETDATE(), N'Conversion'
    UNION ALL SELECT  8327, 302, N'Unsecured', 2, N'', 1, NULL, N'', GETDATE(), N'Conversion'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.StaticList    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.StaticList OFF ;
    SET IDENTITY_INSERT dbo.ClientDocumentType ON ;

    INSERT  dbo.ClientDocumentType ( ClientDocumentTypeID, Value, DisplaySequence, Active, Description, MaxDocuments, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Contracts', 1, 1, NULL, 4, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Other Documents', 2, 1, NULL, 5, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Reports', 3, 1, NULL, 5, GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ClientDocumentType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ClientDocumentType OFF ;
    SET IDENTITY_INSERT dbo.ClientDocumentName ON ;

    INSERT  dbo.ClientDocumentName ( ClientDocumentNameID, Value, DisplaySequence, Active, Description, ClientDocumentTypeID, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Master Contract', 1, 1, NULL, 1, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Continuing Disclosure Contract', 2, 1, NULL, 1, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Charter', 1, 1, NULL, 2, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Reimbursement Resolution', 2, 1, NULL, 2, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'DTC Blanket Letter', 3, 1, NULL, 2, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Policy & Procedures for Arbitrage', 4, 1, NULL, 2, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'CIP Plan', 1, 1, NULL, 3, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  8, N'FMP', 2, 1, NULL, 3, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  9, N'Utility Rate Study', 3, 1, NULL, 3, GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ClientDocumentName    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ClientDocumentName OFF ;
    SET IDENTITY_INSERT dbo.AddressType ON ;

    INSERT  dbo.AddressType ( AddressTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Billing', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Mailing', 0, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.AddressType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.AddressType OFF ;
    SET IDENTITY_INSERT dbo.ArbitrageCategory ON ;

    INSERT  dbo.ArbitrageCategory ( ArbitrageCategoryID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Rebate', 1, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Small Issuer', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Not Subject To', 3, 1, NULL, GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ArbitrageCategory    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ArbitrageCategory OFF ;
    SET IDENTITY_INSERT dbo.ArbitrageComputationType ON ;

    INSERT  dbo.ArbitrageComputationType ( ArbitrageComputationTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Fifteen year', 4, 1, N'', GETDATE(), N'Conversion', N'Fifteen-year'
    UNION ALL SELECT  2, N'Final', 5, 1, N'', GETDATE(), N'Conversion', N'Final'
    UNION ALL SELECT  3, N'Five year', 2, 1, N'', GETDATE(), N'Conversion', N'Five-year'
    UNION ALL SELECT  4, N'Interim', 1, 1, N'', GETDATE(), N'Conversion', N'Interim'
    UNION ALL SELECT  5, N'Monitoring', 6, 1, N'', GETDATE(), N'Conversion', N'Monitoring'
    UNION ALL SELECT  6, N'Ten year', 3, 1, N'', GETDATE(), N'Conversion', N'Ten-year'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ArbitrageComputationType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ArbitrageComputationType OFF ;
    SET IDENTITY_INSERT dbo.ArbitrageException ON ;

    INSERT  dbo.ArbitrageException ( ArbitrageExceptionID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  2, N'18 month spend down', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'24 month spend down', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'6 month spend down', 0, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ArbitrageException    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ArbitrageException OFF ;
    SET IDENTITY_INSERT dbo.ArbitrageRecordStatus ON ;

    INSERT  dbo.ArbitrageRecordStatus ( ArbitrageRecordStatusID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Declined', 3, 1, N'', GETDATE(), N'Conversion', N'2'
    UNION ALL SELECT  2, N'Received', 2, 1, N'', GETDATE(), N'Conversion', N'1'
    UNION ALL SELECT  3, N'Sent', 1, 1, N'', GETDATE(), N'Conversion', N'0'
    UNION ALL SELECT  4, N'Unknown', 4, 1, N'', GETDATE(), N'Conversion', N'3'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ArbitrageRecordStatus    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ArbitrageRecordStatus OFF ;
    SET IDENTITY_INSERT dbo.ArbitrageRecordType ON ;

    INSERT  dbo.ArbitrageRecordType ( ArbitrageRecordTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Addendum Ehlers', 2, 1, N'', GETDATE(), N'Conversion', N'1'
    UNION ALL SELECT  2, N'Agreement non-Ehlers', 4, 1, N'', GETDATE(), N'Conversion', N'3'
    UNION ALL SELECT  3, N'Election Form', 3, 1, N'', GETDATE(), N'Conversion', N'2'
    UNION ALL SELECT  4, N'Master Agreement Ehlers', 1, 1, N'', GETDATE(), N'Conversion', N'0'
    UNION ALL SELECT  5, N'None', 5, 1, N'', GETDATE(), N'Conversion', N'4'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ArbitrageRecordType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ArbitrageRecordType OFF ;
    SET IDENTITY_INSERT dbo.ArbitrageStatus ON ;

    INSERT  dbo.ArbitrageStatus ( ArbitrageStatusID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Active', 1, 1, N'', GETDATE(), N'Conversion', N'Active'
    UNION ALL SELECT  2, N'Final', 4, 1, N'', GETDATE(), N'Conversion', N'Final'
    UNION ALL SELECT  3, N'Future', 3, 1, N'', GETDATE(), N'Conversion', N'Future'
    UNION ALL SELECT  4, N'Lost', 5, 1, N'', GETDATE(), N'Conversion', N'Lost'
    UNION ALL SELECT  5, N'Pending', 2, 1, N'', GETDATE(), N'Conversion', N'Pending'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ArbitrageStatus    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ArbitrageStatus OFF ;
    SET IDENTITY_INSERT dbo.ARRAType ON ;

    INSERT  dbo.ARRAType ( ARRATypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'BAB', 1, 1, N'Build America Bonds', GETDATE(), N'Conversion', N'B'
    UNION ALL SELECT  2, N'QZAB/QSCB', 2, 1, N'', GETDATE(), N'Conversion', N'Q'
    UNION ALL SELECT  3, N'Recovery Zone', 3, 1, N'', GETDATE(), N'Conversion', N'R'
    UNION ALL SELECT  4, N'N/A', 99, 0, N'VB6 conversion value', GETDATE(), N'Conversion', N'N'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ARRAType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ARRAType OFF ;
    SET IDENTITY_INSERT dbo.AuditorFeeType ON ;

    INSERT  dbo.AuditorFeeType ( AuditorFeeTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Full Fee', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Partial Fee', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Update Fee', 0, 1, NULL, GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.AuditorFeeType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.AuditorFeeType OFF ;
    SET IDENTITY_INSERT dbo.BidSource ON ;

    INSERT  dbo.BidSource ( BidSourceID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Parity', 1, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Fax/E-Mail', 2, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Mail', 3, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Muni Auction', 4, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Phone', 5, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'VB6 Conversion', 99, 0, NULL, GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.BidSource    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.BidSource OFF ;
    SET IDENTITY_INSERT dbo.BondFormType ON ;

    INSERT  dbo.BondFormType ( BondFormTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  2, N'BEO - Certificated', 3, 1, N'', GETDATE(), N'Conversion', N'BC'
    UNION ALL SELECT  4, N'Book Entry Only', 1, 1, N'', GETDATE(), N'Conversion', N'BT,C'
    UNION ALL SELECT  5, N'Certificated', 99, 0, N'VB6 conversion value', GETDATE(), N'Conversion', N'R'
    UNION ALL SELECT  6, N'Non-BEO - Certificated', 99, 0, N'VB6 conversion value', GETDATE(), N'Conversion', N'NC'
    UNION ALL SELECT  7, N'Non-Book Entry Only', 2, 1, N'', GETDATE(), N'Conversion', N'NT'
    UNION ALL SELECT  8, N'Not Applicable', 4, 1, N'', GETDATE(), N'Conversion', N'N'
    UNION ALL SELECT  9, N'Unknown', 5, 1, N'', GETDATE(), N'Conversion', N'U'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.BondFormType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.BondFormType OFF ;
    SET IDENTITY_INSERT dbo.CallFrequency ON ;

    INSERT  dbo.CallFrequency ( CallFrequencyID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Any date after call date', 1, 1, N'', GETDATE(), N'Conversion', N'A'
    UNION ALL SELECT  2, N'Any date after settlement date', 4, 1, N'', GETDATE(), N'Conversion', N'S'
    UNION ALL SELECT  3, N'Any interest adjustment date', 5, 1, N'', GETDATE(), N'Conversion', N'V'
    UNION ALL SELECT  4, N'Any interest payment date', 3, 1, N'', GETDATE(), N'Conversion', N'I'
    UNION ALL SELECT  5, N'Any payment date ', 10, 1, N'', GETDATE(), N'Conversion', N'AP'
    UNION ALL SELECT  6, N'Blended', 9, 1, N'', GETDATE(), N'Conversion', N'BL'
    UNION ALL SELECT  7, N'Monthly', 7, 1, N'', GETDATE(), N'Conversion', N'M'
    UNION ALL SELECT  8, N'Non-callable', 2, 1, N'', GETDATE(), N'Conversion', N'N'
    UNION ALL SELECT  9, N'On dates given', 6, 1, N'', GETDATE(), N'Conversion', N'O'
    UNION ALL SELECT  10, N'Unknown', 8, 1, N'', GETDATE(), N'Conversion', N'U'
    UNION ALL SELECT  11, N'Quarterly', 99, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.CallFrequency    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.CallFrequency OFF ;
    SET IDENTITY_INSERT dbo.CallType ON ;

    INSERT  dbo.CallType ( CallTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Extraordinary Call', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Mandatory Call', 3, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Optional Call', 1, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.CallType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.CallType OFF ;
    SET IDENTITY_INSERT dbo.ClientPrefix ON ;

    INSERT  dbo.ClientPrefix ( ClientPrefixID, Value, DisplaySequence, Active, Description, IsAll, IsMN, IsWI, IsIL, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  16, N'City of', 0, 1, N'', 1, 0, 0, 0, GETDATE(), N'Conversion', N'City of'
    UNION ALL SELECT  17, N'Community Development Authority of the City of', 0, 1, N'', 1, 0, 0, 0, GETDATE(), N'Conversion', N'Community Development Authority of the City of'
    UNION ALL SELECT  18, N'County of', 0, 1, N'', 1, 0, 0, 0, GETDATE(), N'Conversion', N'County of'
    UNION ALL SELECT  19, N'Public Utilities Commission of the City of', 0, 1, N'', 1, 0, 0, 0, GETDATE(), N'Conversion', N'Public Utilities Commission of the City of'
    UNION ALL SELECT  20, N'State of', 0, 1, N'', 1, 0, 0, 0, GETDATE(), N'Conversion', N'State of'
    UNION ALL SELECT  21, N'Town of', 0, 1, N'', 1, 0, 0, 0, GETDATE(), N'Conversion', N'Town of'
    UNION ALL SELECT  22, N'Village of', 0, 1, N'', 1, 0, 0, 0, GETDATE(), N'Conversion', N'Village of'
    UNION ALL SELECT  23, N'Community College District No.', 0, 1, N'', 0, 0, 0, 1, GETDATE(), N'Conversion', N'Community College District No.'
    UNION ALL SELECT  24, N'Community Consolidated School District No.', 0, 1, N'', 0, 0, 0, 1, GETDATE(), N'Conversion', N'Community Consolidated School District No. '
    UNION ALL SELECT  25, N'Community High School District No.', 0, 1, N'', 0, 0, 0, 1, GETDATE(), N'Conversion', N'Community High School District No.'
    UNION ALL SELECT  26, N'Community School District No.', 0, 1, N'', 0, 0, 0, 1, GETDATE(), N'Conversion', N'Community School District No.'
    UNION ALL SELECT  27, N'Community School District of', 0, 1, N'', 0, 0, 0, 1, GETDATE(), N'Conversion', N'Community School District of'
    UNION ALL SELECT  28, N'Community Unit School District No.', 0, 1, N'', 0, 0, 0, 1, GETDATE(), N'Conversion', N'Community Unit School District No.'
    UNION ALL SELECT  29, N'Park District of', 0, 1, N'', 0, 0, 0, 1, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  30, N'School District No.', 0, 1, N'', 0, 0, 0, 1, GETDATE(), N'Conversion', N'School District No.'
    UNION ALL SELECT  31, N'Board of Light and Power of the City of', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Board of Light and Power of the City of'
    UNION ALL SELECT  32, N'Economic Development Authority of the City of', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Economic Development Authority of the City of'
    UNION ALL SELECT  33, N'Economic Development Authority of the County of', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Economic Development Authority of the County of'
    UNION ALL SELECT  34, N'Housing and Redevelopment Authority of the City of', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Housing and Redevelopment Authority of the City of'
    UNION ALL SELECT  35, N'Housing and Redevelopment Authority of the County of', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Housing and Redevelopment Authority of the County of'
    UNION ALL SELECT  36, N'Independent School District No.', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Independent School District No.'
    UNION ALL SELECT  37, N'Port Authority of the City of', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Port Authority of the City of'
    UNION ALL SELECT  38, N'Public School District No.', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Public School District No.'
    UNION ALL SELECT  39, N'Special School District No.', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Special School District No.'
    UNION ALL SELECT  40, N'Water and Light Commission of the City of', 0, 1, N'', 0, 1, 0, 0, GETDATE(), N'Conversion', N'Water and Light Commission of the City of'
    UNION ALL SELECT  41, N'Community Development Authority of the Town of', 0, 1, N'', 0, 0, 1, 0, GETDATE(), N'Conversion', N'Community Development Authority of the Town of'
    UNION ALL SELECT  42, N'Community Development Authority of the Village of', 0, 1, N'', 0, 0, 1, 0, GETDATE(), N'Conversion', N'Community Development Authority of the Village of'
    UNION ALL SELECT  43, N'Housing and Community Development Authority of the Village of', 0, 1, N'', 0, 0, 1, 0, GETDATE(), N'Conversion', N'Housing and Community Development Authority of the Village of'
    UNION ALL SELECT  44, N'Redevelopment Authority of the City of', 0, 1, N'', 0, 0, 1, 0, GETDATE(), N'Conversion', N'Redevelopment Authority of the City of'
    UNION ALL SELECT  45, N'Sanitary Sewer District', 0, 1, N'', 0, 0, 1, 0, GETDATE(), N'Conversion', N'Sanitary Sewer District'
    UNION ALL SELECT  46, N'School District of', 0, 1, N'', 0, 0, 1, 0, GETDATE(), N'Conversion', N'School District of'
    UNION ALL SELECT  50, N'Public Building Commission', 0, 1, NULL, 1, 0, 0, 0, GETDATE(), N'Conversion', N'Public Building Commission'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ClientPrefix    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ClientPrefix OFF ;
    SET IDENTITY_INSERT dbo.ClientService ON ;

    INSERT  dbo.ClientService ( ClientServiceID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'DI: Debt Issuance Services', 1, 1, NULL, GETDATE(), N'Conversion', N'DI'
    UNION ALL SELECT  2, N'ED: Economic Developement/Redevelopment', 2, 1, NULL, GETDATE(), N'Conversion', N'ED'
    UNION ALL SELECT  3, N'FP: Financial Planning', 3, 1, NULL, GETDATE(), N'Conversion', N'FP'
    UNION ALL SELECT  4, N'SC: Strategic Planning', 7, 1, NULL, GETDATE(), N'Conversion', N'MC'
    UNION ALL SELECT  5, N'ARB: Arbitrage', 5, 1, NULL, GETDATE(), N'Conversion', N'ARB'
    UNION ALL SELECT  6, N'BTS: Bond Trust Service', 4, 1, NULL, GETDATE(), N'Conversion', N'BT'
    UNION ALL SELECT  7, N'EIP: Ehlers Investment Partners', 6, 1, NULL, GETDATE(), N'Conversion', N'CIP'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ClientService    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ClientService OFF ;
    SET IDENTITY_INSERT dbo.ClientStatus ON ;

    INSERT  dbo.ClientStatus ( ClientStatusID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Annexed', 8, 1, N'', GETDATE(), N'Conversion', N'Annexed'
    UNION ALL SELECT  2, N'Consolidated', 7, 1, N'', GETDATE(), N'Conversion', N'Consolidated'
    UNION ALL SELECT  3, N'Current Client', 1, 1, N'', GETDATE(), N'Conversion', N'Current client'
    UNION ALL SELECT  4, N'Dissolved', 6, 1, N'', GETDATE(), N'Conversion', N'Dissolved'
    UNION ALL SELECT  5, N'Non-Client', 2, 1, N'', GETDATE(), N'Conversion', N'Non-client'
    UNION ALL SELECT  6, N'Previous Client', 4, 1, N'', GETDATE(), N'Conversion', N'Previous'
    UNION ALL SELECT  7, N'Target', 5, 1, N'', GETDATE(), N'Conversion', N'Target'
    UNION ALL SELECT  8, N'BTSC Only', 3, 1, NULL, GETDATE(), N'Conversion', N'BTSC Only'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ClientStatus    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ClientStatus OFF ;
    SET IDENTITY_INSERT dbo.CreditEnhancementType ON ;

    INSERT  dbo.CreditEnhancementType ( CreditEnhancementTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Credit Enhanced w/Underlying', 1, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Credit Enhanced Only', 2, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Credit Enhanced', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.CreditEnhancementType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.CreditEnhancementType OFF ;
    SET IDENTITY_INSERT dbo.DeliveryMethod ON ;

    INSERT  dbo.DeliveryMethod ( DeliveryMethodID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Compact Disc', 0, 1, N'a', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Email', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Hard Copy - Paper', 0, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.DeliveryMethod    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.DeliveryMethod OFF ;
    SET IDENTITY_INSERT dbo.DisclosureReportType ON ;

    INSERT  dbo.DisclosureReportType ( DisclosureReportTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Annual', 1, 1, NULL, GETDATE(), N'jreuter', NULL
    UNION ALL SELECT  2, N'Semi-annual', 2, 1, NULL, GETDATE(), N'jreuter', NULL
    UNION ALL SELECT  3, N'Quarterly', 3, 1, NULL, GETDATE(), N'jreuter', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.DisclosureReportType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.DisclosureReportType OFF ;
    SET IDENTITY_INSERT dbo.DisclosureType ON ;

    INSERT  dbo.DisclosureType ( DisclosureTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'$100,000+', 6, 1, N'', GETDATE(), N'Conversion', N'D'
    UNION ALL SELECT  2, N'18 Month', 3, 1, N'', GETDATE(), N'Conversion', N'M'
    UNION ALL SELECT  3, N'Exempt from Disclosure', 4, 1, N'', GETDATE(), N'Conversion', N'E'
    UNION ALL SELECT  4, N'Full Disclosure', 1, 1, N'', GETDATE(), N'Conversion', N'F'
    UNION ALL SELECT  5, N'Limited Disclosure', 2, 1, N'', GETDATE(), N'Conversion', N'L'
    UNION ALL SELECT  6, N'Not Subject to Disclosure', 5, 1, N'', GETDATE(), N'Conversion', N'N'
    UNION ALL SELECT  7, N'Unknown', 7, 1, NULL, GETDATE(), N'Conversion', N'U'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.DisclosureType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.DisclosureType OFF ;
    SET IDENTITY_INSERT dbo.DocumentType ON ;

    INSERT  dbo.DocumentType ( DocumentTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Closing Memo', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'OS Mastoer', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'OS Sub', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Post Sale Report', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Pre Sale Report', 0, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.DocumentType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.DocumentType OFF ;
    SET IDENTITY_INSERT dbo.ElectionType ON ;

    INSERT  dbo.ElectionType ( ElectionTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Capital Projects Levy', 1, 1, N'', GETDATE(), N'Conversion', N'Capital Projects Levy'
    UNION ALL SELECT  2, N'GO Bonds', 2, 1, N'', GETDATE(), N'Conversion', N'GO Bonds'
    UNION ALL SELECT  3, N'One Day Bonds', 3, 1, N'', GETDATE(), N'Conversion', N'One-day Bonds'
    UNION ALL SELECT  4, N'Operating Referendum', 4, 1, N'', GETDATE(), N'Conversion', N'Operating Referendum'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.ElectionType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.ElectionType OFF ;
    SET IDENTITY_INSERT dbo.FeeBasis ON ;

    INSERT  dbo.FeeBasis ( FeeBasisID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Contract', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'GO Standard Schedule', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Multiple Issue Discount', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Quote', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Revenue Standard Schedule', 0, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.FeeBasis    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.FeeBasis OFF ;
    SET IDENTITY_INSERT dbo.FeeType ON ;

    INSERT  dbo.FeeType ( FeeTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Miscellaneous Expense', 23, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  8, N'Investment Agent', 18, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  11, N'Paying Agent - Crossover', 22, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  12, N'SLG Placement', 16, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  13, N'State Registration', 19, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  14, N'Surety Bond', 17, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  15, N'Bond Attorney', 1, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  16, N'Paying Agent - Initial', 2, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  17, N'Paying Agent - 1st Year - Prorated ', 3, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  18, N'Escrow Agent', 4, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  19, N'Escrow CPA', 5, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  20, N'Trustee - Initial', 6, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  21, N'Trustee - 1st Year Prorated', 7, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  22, N'Rating Agent - Moody', 8, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  23, N'Rating Agent - S & P', 9, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  24, N'Rating Agent  - Fitch', 10, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  25, N'Local Attorney', 11, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  26, N'Underwriting Firm', 12, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  27, N'Underwriting Counsel', 13, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  28, N'Bond Insurance', 14, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  29, N'Other FA Fee', 15, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  30, N'Open Market Securities Provider', 20, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  31, N'Open Market Bidding Agent', 21, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  33, N'Additional', 0, 1, N'Ehlers fee', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  34, N'Additional Discount', 0, 1, N'Ehlers fee', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  35, N'Advanced Refunding', 0, 1, N'Ehlers fee', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  36, N'Base', 0, 1, N'Ehlers fee', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  37, N'Bifurcated Issue', 0, 1, N'Ehlers fee', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  38, N'Continuing Disclosure Discount', 0, 1, N'Ehlers fee', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  39, N'Mandatory Term Redemption Notice', 0, 1, N'Ehlers fee', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  40, N'Multi-Issue Discount', 0, 1, N'Ehlers fee', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  41, N'Misc. Office Expense', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  42, N'Material Events Notice', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  43, N'Unique Revenue Source', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  44, N'Home County', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  45, N'County 1', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  46, N'County 2', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  47, N'County 3', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  48, N'County 4', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  49, N'County 5', 0, 1, NULL, GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.FeeType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.FeeType OFF ;
    SET IDENTITY_INSERT dbo.FinanceType ON ;

    INSERT  dbo.FinanceType ( FinanceTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Net Cash - Full', 8, 1, NULL, GETDATE(), N'Conversion', N'2'
    UNION ALL SELECT  2, N'New Money', 1, 1, NULL, GETDATE(), N'Conversion', N'5'
    UNION ALL SELECT  3, N'Unknown', 11, 1, NULL, GETDATE(), N'Conversion', N'U'
    UNION ALL SELECT  4, N'Current - Full', 2, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Current - Partial Issue', 3, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Current - Partial Maturities', 4, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'Net Cash - Partial Issue', 9, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  8, N'Net Cash - Partial Maturities', 10, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  9, N'Crossover - Full', 5, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  10, N'Crossover - Partial Issue', 6, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  11, N'Crossover - Partial Maturities', 7, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  12, N'Current Refunding', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', N'3'
    UNION ALL SELECT  13, N'Crossover Refunding', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', N'6'
    UNION ALL SELECT  14, N'Partial Net Cash Refunding', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', N'1'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.FinanceType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.FinanceType OFF ;
    SET IDENTITY_INSERT dbo.FirmCategory ON ;

    INSERT  dbo.FirmCategory ( FirmCategoryID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'8038-CP Filing Agent', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  2, N'Arbitrage Provider', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  3, N'Bond Counsel', 0, 1, N'', GETDATE(), N'Conversion', N'bc'
    UNION ALL SELECT  4, N'Bond Insurance Firm', 0, 1, N'', GETDATE(), N'Conversion', N'ins'
    UNION ALL SELECT  5, N'Client CPA', 0, 1, N'', GETDATE(), N'Conversion', N'CCPA'
    UNION ALL SELECT  6, N'Credit Enhancement Agent', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  7, N'Dissemination Agent', 0, 1, N'', GETDATE(), N'Conversion', N'DS'
    UNION ALL SELECT  8, N'Escrow Agent', 0, 1, N'', GETDATE(), N'Conversion', N'esa'
    UNION ALL SELECT  9, N'Escrow CPA', 0, 1, N'', GETDATE(), N'Conversion', N'esc'
    UNION ALL SELECT  10, N'FA Firm', 0, 1, N'', GETDATE(), N'Conversion', N'faf'
    UNION ALL SELECT  11, N'Investment Agent', 0, 1, N'', GETDATE(), N'Conversion', N'inv'
    UNION ALL SELECT  12, N'Local Attorney', 0, 1, N'', GETDATE(), N'Conversion', N'LATTY'
    UNION ALL SELECT  13, N'Local Bank', 0, 1, N'', GETDATE(), N'Conversion', N'LB'
    UNION ALL SELECT  14, N'Paying Agent', 0, 1, N'', GETDATE(), N'Conversion', N'pay'
    UNION ALL SELECT  15, N'Rating Agency', 0, 1, N'', GETDATE(), N'Conversion', N'rat'
    UNION ALL SELECT  17, N'Trustee', 0, 1, N'', GETDATE(), N'Conversion', N'tru'
    UNION ALL SELECT  18, N'Underwriter Counsel', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  19, N'Underwriting Firm', 0, 1, N'', GETDATE(), N'Conversion', N'und'
    UNION ALL SELECT  21, N'Architect', 0, 1, NULL, GETDATE(), N'Conversion', N'arc'
    UNION ALL SELECT  22, N'Engineer', 0, 1, NULL, GETDATE(), N'Conversion', N'eng'
    UNION ALL SELECT  23, N'Lease/Purchase/Financier', 0, 1, NULL, GETDATE(), N'Conversion', N'LPF'
    UNION ALL SELECT  24, N'Ehlers Vendor', 0, 1, NULL, GETDATE(), N'Conversion', N'VEN'
    UNION ALL SELECT  25, N'Client Association', 0, 1, NULL, GETDATE(), N'Conversion', N'ca'
    UNION ALL SELECT  26, N'Open Market Securities Provider', 0, 1, NULL, GETDATE(), N'Conversion', N'OMS'
    UNION ALL SELECT  27, N'Open Market Bidding Agent', 0, 1, NULL, GETDATE(), N'Conversion', N'OMBA'
    UNION ALL SELECT  28, N'TIF Attorney', 0, 1, NULL, GETDATE(), N'Conversion', N'TATTY'
    UNION ALL SELECT  29, N'TIF Inspectors', 0, 1, NULL, GETDATE(), N'Conversion', N'TIFIn'
    UNION ALL SELECT  30, N'Developer', 0, 1, NULL, GETDATE(), N'Conversion', N'DEV'
    UNION ALL SELECT  31, N'Developer - Commercial', 0, 1, NULL, GETDATE(), N'Conversion', N'DVC'
    UNION ALL SELECT  32, N'Developer - Industrial', 0, 1, NULL, GETDATE(), N'Conversion', N'DVI'
    UNION ALL SELECT  33, N'Developer - Hotel', 0, 1, NULL, GETDATE(), N'Conversion', N'DVH'
    UNION ALL SELECT  34, N'Developer - Residential General', 0, 1, NULL, GETDATE(), N'Conversion', N'DVRG'
    UNION ALL SELECT  35, N'Developer - Residential MultiFarmRental', 0, 1, NULL, GETDATE(), N'Conversion', N'DVRMR'
    UNION ALL SELECT  36, N'Developer - Residential Single Family', 0, 1, NULL, GETDATE(), N'Conversion', N'DVRSF'
    UNION ALL SELECT  37, N'Developer - Residential Senior Housing', 0, 1, NULL, GETDATE(), N'Conversion', N'DVRSH'
    UNION ALL SELECT  38, N'Developer - Residential Townhomes', 0, 1, NULL, GETDATE(), N'Conversion', N'DVRTH'
    UNION ALL SELECT  39, N'Developer - Residential SrCooperative', 0, 1, NULL, GETDATE(), N'Conversion', N'DVRSC'
    UNION ALL SELECT  40, N'Developer - Residential Condos', 0, 1, NULL, GETDATE(), N'Conversion', N'DVRC'
    UNION ALL SELECT  41, N'Developer - Residential School Conversion', 0, 1, NULL, GETDATE(), N'Conversion', N'DVSC'
    UNION ALL SELECT  42, N'Developer - Residential Mixed Use', 0, 1, NULL, GETDATE(), N'Conversion', N'DVRMU'
    UNION ALL SELECT  43, N'Relocation Consultant', 0, 1, NULL, GETDATE(), N'Conversion', N'RC'
    UNION ALL SELECT  44, N'Market Analysis', 0, 1, NULL, GETDATE(), N'Conversion', N'MA'
    UNION ALL SELECT  45, N'Leasing/Property Management', 0, 1, NULL, GETDATE(), N'Conversion', N'LPM'
    UNION ALL SELECT  46, N'Appraisers', 0, 1, NULL, GETDATE(), N'Conversion', N'AP'
    UNION ALL SELECT  47, N'Land Acquistion Mediators', 0, 1, NULL, GETDATE(), N'Conversion', N'LAM'
    UNION ALL SELECT  48, N'Grant Administrators', 0, 1, NULL, GETDATE(), N'Conversion', N'GRANT'
    UNION ALL SELECT  49, N'Construction Manager', 0, 1, NULL, GETDATE(), N'Conversion', N'cm'
    UNION ALL SELECT  50, N'Passthrough Vendor', 0, 1, NULL, GETDATE(), N'Conversion', N'PTV'
    UNION ALL SELECT  51, N'Real Estate Attorney', 0, 1, NULL, GETDATE(), N'Conversion', N'REA'
    UNION ALL SELECT  52, N'Marketing/Real Estate Consultant', 0, 1, NULL, GETDATE(), N'Conversion', N'REC'
    UNION ALL SELECT  53, N'Other', 0, 1, NULL, GETDATE(), N'Conversion', N'oth'
    UNION ALL SELECT  54, N'Utility/Cable TV', 0, 1, NULL, GETDATE(), N'Conversion', N'UC'
    UNION ALL SELECT  55, N'HR Consultant', 0, 1, NULL, GETDATE(), N'Conversion', N'HR'
    UNION ALL SELECT  56, N'Planners', 0, 1, NULL, GETDATE(), N'Conversion', N'pl'
    UNION ALL SELECT  57, N'Info Agency', 0, 1, NULL, GETDATE(), N'Conversion', N'inf'
    UNION ALL SELECT  58, N'Redemption Agent', 0, 1, NULL, GETDATE(), N'Conversion', N'red'
    UNION ALL SELECT  59, N'Non-Profit Development', 0, 1, NULL, GETDATE(), N'Conversion', N'NPD'
    UNION ALL SELECT  60, N'Escrow Agent - Lease Purchase', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', N'ESALP'
    UNION ALL SELECT  61, N'Internet Bidding Service', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', N'IBS'
    UNION ALL SELECT  62, N'Site Selection', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', N'SS'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.FirmCategory    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.FirmCategory OFF ;
    SET IDENTITY_INSERT dbo.FirmSpeciality ON ;

    INSERT  dbo.FirmSpeciality ( FirmSpecialityID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  12, N'BQ', 1, 1, N'BQ', GETDATE(), N'Conversion', N'1'
    UNION ALL SELECT  13, N'Non-BQ', 2, 1, N'Non-BQ', GETDATE(), N'Conversion', N'2'
    UNION ALL SELECT  14, N'Under $1 million', 3, 1, N'Under $1 million', GETDATE(), N'Conversion', N'3'
    UNION ALL SELECT  15, N'Over $1 million', 4, 1, N'Over $1 million', GETDATE(), N'Conversion', N'4'
    UNION ALL SELECT  16, N'Over $10 million', 5, 1, N'Over $10 million', GETDATE(), N'Conversion', N'5'
    UNION ALL SELECT  17, N'Non-Ess Pur Term Limit', 6, 1, N'Non-Ess.Pur.Term Limit', GETDATE(), N'Conversion', N'6'
    UNION ALL SELECT  18, N'Building or Land Purchase', 7, 1, N'Bldg.orLand Purchase', GETDATE(), N'Conversion', N'7'
    UNION ALL SELECT  19, N'Equipment', 8, 1, N'Equipment', GETDATE(), N'Conversion', N'8'
    UNION ALL SELECT  20, N'Negotiated', 9, 1, N'Negotiated', GETDATE(), N'Conversion', N'9'
    UNION ALL SELECT  21, N'Competitive', 10, 1, N'Competitive', GETDATE(), N'Conversion', N'10'
    UNION ALL SELECT  22, N'Taxable', 11, 1, N'Taxable', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  23, N'Other', 15, 1, N'Other', GETDATE(), N'Conversion', N'15'
    UNION ALL SELECT  24, N'Term Limit', 20, 1, N'Term Limit', GETDATE(), N'Conversion', N'20'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.FirmSpeciality    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.FirmSpeciality OFF ;
    SET IDENTITY_INSERT dbo.FormOfGovernment ON ;

    INSERT  dbo.FormOfGovernment ( FormOfGovernmentID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Home Rule', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Statutory City', 1, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Non Home Rule', 3, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.FormOfGovernment    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.FormOfGovernment OFF ;
    SET IDENTITY_INSERT dbo.FundingSourceType ON ;

    INSERT  dbo.FundingSourceType ( FundingSourceTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Ad Valorem Property Taxes ', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  2, N'Annual Appropriation', 0, 1, N'', GETDATE(), N'Conversion', N'AA'
    UNION ALL SELECT  3, N'Bond Fund', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  4, N'Cash on Hand', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  5, N'City Assessment', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  6, N'Closed Bond Fund', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  7, N'Electric Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'ER'
    UNION ALL SELECT  8, N'Gas Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'GR'
    UNION ALL SELECT  9, N'Golf Course Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'GCR'
    UNION ALL SELECT  10, N'Hospital Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'HpR'
    UNION ALL SELECT  11, N'Housing Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'HsR'
    UNION ALL SELECT  12, N'Ice Arena Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'IAR'
    UNION ALL SELECT  13, N'Installment Purchase Payments', 0, 1, N'', GETDATE(), N'Conversion', N'IPP'
    UNION ALL SELECT  15, N'Liquor Store Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'LSR'
    UNION ALL SELECT  16, N'Lodging Taxes', 0, 1, N'', GETDATE(), N'Conversion', N'LT'
    UNION ALL SELECT  18, N'Nursing Home Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'NHR'
    UNION ALL SELECT  19, N'Paid from Escrow', 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  20, N'Public Utilities Revenue', 0, 1, N'', GETDATE(), N'Conversion', N'PUR'
    UNION ALL SELECT  21, N'Sales Tax', 0, 1, N'', GETDATE(), N'Conversion', N'STR'
    UNION ALL SELECT  22, N'Sewer Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'SR'
    UNION ALL SELECT  25, N'Solid Waste Revenue', 0, 1, N'', GETDATE(), N'Conversion', N'SWR'
    UNION ALL SELECT  26, N'Special Assessment', 0, 1, N'', GETDATE(), N'Conversion', N'SpA'
    UNION ALL SELECT  27, N'State Aid', 0, 1, N'', GETDATE(), N'Conversion', N'StA'
    UNION ALL SELECT  28, N'Storm Sewer Revenues', 0, 1, N'', GETDATE(), N'Conversion', N'SSR'
    UNION ALL SELECT  30, N'Tax Abatement Revenue', 0, 1, N'', GETDATE(), N'Conversion', N'TAR'
    UNION ALL SELECT  31, N'Tax Increment Revenue', 0, 1, N'', GETDATE(), N'Conversion', N'TIR'
    UNION ALL SELECT  32, N'Tax Levy', 0, 1, N'', GETDATE(), N'Conversion', N'T'
    UNION ALL SELECT  33, N'Unlimited Tax Lease', 0, 1, N'', GETDATE(), N'Conversion', N'UTL'
    UNION ALL SELECT  34, N'User Fees', 0, 1, N'User Fees', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  37, N'** special', 99, 0, NULL, GETDATE(), N'Conversion', N'**'
    UNION ALL SELECT  38, N'Medical Facility Revenues', 0, 1, NULL, GETDATE(), N'Conversion', N'MFR'
    UNION ALL SELECT  39, N'Revenues', 0, 1, NULL, GETDATE(), N'Conversion', N'R'
    UNION ALL SELECT  40, N'Utility Revenue', 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  41, N'Stormwater Revenue', 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  42, N'Sewer and Water Revenue', 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  43, N'Electric and Water Revenue', 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  44, N'Electric, Sewer, and Water Revenue', 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  45, N'Business District Revenues', 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  46, N'Hotel/Motel Taxes', 0, 1, N' ', GETDATE(), N'Conversion', N' '
    UNION ALL SELECT  47, N'Utility Taxes', 0, 1, N' ', GETDATE(), N'Conversion', N' '
    UNION ALL SELECT  48, N'Special Service Area', 0, 1, N' ', GETDATE(), N'Conversion', N' '
    UNION ALL SELECT  49, N'Senior Housing Revenues', 0, 1, N' ', GETDATE(), N'Conversion', N' '
    UNION ALL SELECT  50, N'Facility Fees', 0, 1, N' ', GETDATE(), N'Conversion', N' '
    UNION ALL SELECT  51, N'Motor Fuel Tax Revenues', 0, 1, N' ', GETDATE(), N'Conversion', N' '
    UNION ALL SELECT  53, N'Income Tax Revenues', 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  54, N'Park District Fee Revenues', 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  55, N'Healthcare Facility Revenues', 0, 1, NULL, GETDATE(), N'Conversion', N'HCFR'
    UNION ALL SELECT  56, N'Water Revenues', 0, 1, NULL, GETDATE(), N'Conversion', N'WR'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.FundingSourceType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.FundingSourceType OFF ;
    SET IDENTITY_INSERT dbo.GoverningBoard ON ;

    INSERT  dbo.GoverningBoard ( GoverningBoardID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Board of Commissioners', 5, 1, N'', GETDATE(), N'Conversion', N'Board of Commissioners'
    UNION ALL SELECT  2, N'Board of Directors', 6, 1, N'', GETDATE(), N'Conversion', N'Board of Directors'
    UNION ALL SELECT  3, N'Board of Education', 7, 1, N'', GETDATE(), N'Conversion', N'Board of Education'
    UNION ALL SELECT  4, N'Board of Library Trustees', 8, 1, N'', GETDATE(), N'Conversion', N'Board of Library Trustees'
    UNION ALL SELECT  5, N'Board of Supervisors', 11, 1, N'', GETDATE(), N'Conversion', N'Board of Supervisors'
    UNION ALL SELECT  6, N'Board of Trustees', 12, 1, N'', GETDATE(), N'Conversion', N'Board of Trustees'
    UNION ALL SELECT  7, N'City Council', 1, 1, N'', GETDATE(), N'Conversion', N'City Council'
    UNION ALL SELECT  8, N'Common Council', 2, 1, N'', GETDATE(), N'Conversion', N'Common Council'
    UNION ALL SELECT  9, N'County Board', 13, 1, N'', GETDATE(), N'Conversion', N'County Board'
    UNION ALL SELECT  10, N'District Commission', 14, 1, N'', GETDATE(), N'Conversion', N'District Commission'
    UNION ALL SELECT  11, N'School Board', 15, 1, N'', GETDATE(), N'Conversion', N'School Board'
    UNION ALL SELECT  12, N'Village Board', 3, 1, N'', GETDATE(), N'Conversion', N'Village Board'
    UNION ALL SELECT  13, N'Town Board', 4, 1, N'', GETDATE(), N'dholmes', N'Town Board'
    UNION ALL SELECT  14, N'Board of Park Commissioners', 10, 1, N'', GETDATE(), N'dholmes', N'Board of Park Commissioners'
    UNION ALL SELECT  15, N'Board of Managers', 9, 1, N'', GETDATE(), N'dholmes', N'Board of Managers'
    UNION ALL SELECT  16, N'Hospital Board', 16, 1, N'', GETDATE(), N'dholmes', N'Hospital Board'
    UNION ALL SELECT  17, N'Board of Township Trustees', 17, 1, N'', GETDATE(), N'dholmes', N'Board of Township Trustees'
    UNION ALL SELECT  18, N'Village Council', 18, 1, N' ', GETDATE(), N'dholmes', N'Village Council'
    UNION ALL SELECT  19, N'Board of Fire Protection District Trustees', 19, 1, N' ', GETDATE(), N'dholmes', N'Board of Fire Protection District Trustees'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.GoverningBoard    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.GoverningBoard OFF ;
    SET IDENTITY_INSERT dbo.InitialOfferingDocument ON ;

    INSERT  dbo.InitialOfferingDocument ( InitialOfferingDocumentID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Bankers Forms', 5, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Full OS', 1, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'N/A', 6, 1, N'Either not available information or government pool', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Offering Memorandum/Statement', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Proposal Form Only', 4, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Terms & Conditions', 3, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'No OS', 99, 0, N'VB Conversion', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.InitialOfferingDocument    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.InitialOfferingDocument OFF ;
    SET IDENTITY_INSERT dbo.InterestCalcMethod ON ;

    INSERT  dbo.InterestCalcMethod ( InterestCalcMethodID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'30/360', 1, 1, N'', GETDATE(), N'Conversion', N'3'
    UNION ALL SELECT  2, N'Actual/360', 2, 1, N'', GETDATE(), N'Conversion', N'2'
    UNION ALL SELECT  3, N'Actual/365', 3, 1, N'', GETDATE(), N'Conversion', N'5'
    UNION ALL SELECT  4, N'Actual/Actual', 4, 1, N'', GETDATE(), N'Conversion', N'1'
    UNION ALL SELECT  5, N'None', 5, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Unknown', 6, 1, NULL, GETDATE(), N'Conversion', N'9'
    UNION ALL SELECT  7, N'30/Actual', 99, 0, N'VB6 conversion value', GETDATE(), N'Conversion', N'4'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.InterestCalcMethod    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.InterestCalcMethod OFF ;
    SET IDENTITY_INSERT dbo.InterestPaymentFreq ON ;

    INSERT  dbo.InterestPaymentFreq ( InterestPaymentFreqID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Annually', 2, 1, N'', GETDATE(), N'Conversion', N'A'
    UNION ALL SELECT  2, N'Interest at Maturity', 3, 1, N'', GETDATE(), N'Conversion', N'I'
    UNION ALL SELECT  3, N'Monthly', 4, 1, N'', GETDATE(), N'Conversion', N'M'
    UNION ALL SELECT  4, N'Quarterly', 5, 1, N'', GETDATE(), N'Conversion', N'Q'
    UNION ALL SELECT  5, N'Semi-annually', 1, 1, N'', GETDATE(), N'Conversion', N'S'
    UNION ALL SELECT  6, N'Unknown', 6, 1, NULL, GETDATE(), N'Conversion', N'U'
    UNION ALL SELECT  7, N'Other', 99, 0, N'VB6 conversion value', GETDATE(), N'Conversion', N'O'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.InterestPaymentFreq    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.InterestPaymentFreq OFF ;
    SET IDENTITY_INSERT dbo.InterestType ON ;

    INSERT  dbo.InterestType ( InterestTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Fixed', 1, 1, N'', GETDATE(), N'Conversion', N'X'
    UNION ALL SELECT  2, N'Unknown', 2, 1, N'', GETDATE(), N'Conversion', N'U'
    UNION ALL SELECT  3, N'Variable', 3, 1, N'', GETDATE(), N'Conversion', N'R'
    UNION ALL SELECT  4, N'Zero Interest', 4, 1, N'', GETDATE(), N'Conversion', N'C'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.InterestType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.InterestType OFF ;
    SET IDENTITY_INSERT dbo.InternetBiddingType ON ;

    INSERT  dbo.InternetBiddingType ( InternetBiddingTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Grant Street', 3, 1, N'', GETDATE(), N'Conversion', N'G'
    UNION ALL SELECT  2, N'None', 1, 1, N'', GETDATE(), N'Conversion', N'N'
    UNION ALL SELECT  3, N'Parity', 2, 1, N'', GETDATE(), N'Conversion', N'P'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.InternetBiddingType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.InternetBiddingType OFF ;
    SET IDENTITY_INSERT dbo.IssueShortName ON ;

    INSERT  dbo.IssueShortName ( IssueShortNameID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Bond', 0, 1, N'', GETDATE(), N'Conversion', N'Bond'
    UNION ALL SELECT  2, N'Certificate', 0, 1, N'', GETDATE(), N'Conversion', N'Certificate'
    UNION ALL SELECT  3, N'Note', 0, 1, N'', GETDATE(), N'Conversion', N'Note'
    UNION ALL SELECT  4, N'Warrant', 0, 1, N'', GETDATE(), N'Conversion', N'Warrant'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.IssueShortName    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.IssueShortName OFF ;
    SET IDENTITY_INSERT dbo.IssueStatus ON ;

    INSERT  dbo.IssueStatus ( IssueStatusID, Value, DisplaySequence, Active, Description, BusinessRuleActive, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Awarded', 1, 1, N'', 1, GETDATE(), N'Conversion', N'Awarded'
    UNION ALL SELECT  2, N'Bids Rejected', 2, 1, N'', 0, GETDATE(), N'Conversion', N'Bids Rejected'
    UNION ALL SELECT  3, N'Closed', 99, 0, N'VB6 Conversion value', 0, GETDATE(), N'Conversion', N'Closed'
    UNION ALL SELECT  4, N'Defeased  Partial', 3, 1, N'', 1, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Defeased to Call Date', 4, 1, N'', 0, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Defeased to Maturity', 5, 1, N'', 0, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'Matured', 6, 1, N'', 0, GETDATE(), N'Conversion', N'Matured'
    UNION ALL SELECT  8, N'Postponed', 7, 1, N'', 0, GETDATE(), N'Conversion', N'Postponed'
    UNION ALL SELECT  9, N'Refunded Advance - Full Crossover', 8, 1, N'', 0, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  10, N'Refunded Advance - Full Net Cash', 9, 1, N'', 0, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  11, N'Refunded Advance - Partial Crossover', 10, 1, N'', 1, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  12, N'Refunded Advance - Partial Net Cash', 11, 1, N'', 1, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  13, N'Refunded Current - Full', 12, 1, N'', 0, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  14, N'Refunded Current - Partial', 13, 1, N'', 1, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  15, N'Sale Set', 14, 1, N'', 1, GETDATE(), N'Conversion', N'Sale Set'
    UNION ALL SELECT  16, N'Sale Tentative', 15, 1, N'', 1, GETDATE(), N'Conversion', N'Sale Tentative'
    UNION ALL SELECT  17, N'Refunded', 99, 0, N'VB6 Conversion value', 0, GETDATE(), N'Conversion', N'Refunded'
    UNION ALL SELECT  18, N'Refunded - Advance', 99, 0, N'VB6 Conversion value', 0, GETDATE(), N'Conversion', N'Refunded - Advance'
    UNION ALL SELECT  19, N'Refunded - Partial', 99, 0, N'VB6 Conversion value', 0, GETDATE(), N'Conversion', N'Refunded - Partial'
    UNION ALL SELECT  20, N'Defeased', 99, 0, N'VB6 Conversion value', 0, GETDATE(), N'Conversion', N'Defeased'
    UNION ALL SELECT  21, N'Awarded - Not Closed', 16, 1, N'', 0, GETDATE(), N'dholmes', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.IssueStatus    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.IssueStatus OFF ;
    SET IDENTITY_INSERT dbo.IssueType ON ;

    INSERT  dbo.IssueType ( IssueTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Clean Water Fund Loan', 9, 1, N'', GETDATE(), N'Conversion', N'C'
    UNION ALL SELECT  2, N'Direct Lease', 3, 1, N'', GETDATE(), N'Conversion', N'L'
    UNION ALL SELECT  3, N'Individual Purchaser', 10, 1, N'An actual individual - not a firm', GETDATE(), N'Conversion', N'IP'
    UNION ALL SELECT  4, N'Industrial Development', 11, 1, N'', GETDATE(), N'Conversion', N'IDB'
    UNION ALL SELECT  5, N'One Day Bond', 5, 1, N'', GETDATE(), N'Conversion', N'O'
    UNION ALL SELECT  6, N'PAYGO', 6, 1, N'', GETDATE(), N'Conversion', N'PYG'
    UNION ALL SELECT  7, N'PFA Loan', 7, 1, N'', GETDATE(), N'Conversion', N'PFA'
    UNION ALL SELECT  8, N'Private Placement', 2, 1, N'Not traded on the Secondary Market.', GETDATE(), N'Conversion', N'B,LBL'
    UNION ALL SELECT  9, N'Public Offering', 1, 1, N'Traded on the secondary market.', GETDATE(), N'Conversion', N'P'
    UNION ALL SELECT  10, N'State Trust Fund Loan', 4, 1, N'', GETDATE(), N'Conversion', N'S'
    UNION ALL SELECT  11, N'USDA Rural Development Loan', 8, 1, N'', GETDATE(), N'Conversion', N'R'
    UNION ALL SELECT  13, N'Unknown', 99, 0, N'VB6 conversion value', GETDATE(), N'Conversion', N'U'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.IssueType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.IssueType OFF ;
    SET IDENTITY_INSERT dbo.JobFunction ON ;

    INSERT  dbo.JobFunction ( JobFunctionID, Value, IsClient, IsFirm, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Clerk', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'CL'
    UNION ALL SELECT  2, N'Head Administrator', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'HA'
    UNION ALL SELECT  3, N'Finance Person', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'FP'
    UNION ALL SELECT  6, N'Invoice Recipient', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'IR'
    UNION ALL SELECT  7, N'Invoice Recipient - Arbitrage', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'AIR'
    UNION ALL SELECT  8, N'TIF District Administrator', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'TA'
    UNION ALL SELECT  9, N'FA Contact', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  10, N'Disclosure Coordinator Contact', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'PC'
    UNION ALL SELECT  11, N'Arbitrage Contact', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'AC'
    UNION ALL SELECT  13, N'County Auditor', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  14, N'Paying Agent Contact 2', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'PA2'
    UNION ALL SELECT  15, N'County Certificate Preparer', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'CC'
    UNION ALL SELECT  16, N'Head Elected Official', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'HEO'
    UNION ALL SELECT  17, N'DTC Contact', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'DT'
    UNION ALL SELECT  19, N'Invoice Recipient - BTSC', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'IRB'
    UNION ALL SELECT  20, N'Elected Official', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  21, N'Appointed Official', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  23, N'TIF Contact Person', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N'TC'
    UNION ALL SELECT  24, N'Cashier', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'CASH'
    UNION ALL SELECT  25, N'Underwriter', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'UND'
    UNION ALL SELECT  26, N'Paying Agent', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'PAY'
    UNION ALL SELECT  27, N'Escrow Agent', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'ESA'
    UNION ALL SELECT  28, N'CPA', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'CPA'
    UNION ALL SELECT  29, N'Trustee', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'TRU'
    UNION ALL SELECT  30, N'Bond Attorney', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'BA'
    UNION ALL SELECT  31, N'Lease Purchase ', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'LPC'
    UNION ALL SELECT  33, N'Local Attorney', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'LA'
    UNION ALL SELECT  34, N'TIF Attorney', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'TA'
    UNION ALL SELECT  35, N'Arbitrage', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'ARB'
    UNION ALL SELECT  36, N'Rating Analyst - MN', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'ANLM'
    UNION ALL SELECT  37, N'Rating Analyst - WI', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'ANLW'
    UNION ALL SELECT  38, N'Rating Analyst - IL', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'ANLI'
    UNION ALL SELECT  39, N'Closing Coordinator', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'CLOS'
    UNION ALL SELECT  40, N'Fee Quote', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'ISEX'
    UNION ALL SELECT  41, N'Underwriter Attorney', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  42, N'Marketing ', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'MKTG'
    UNION ALL SELECT  44, N'Paralegal', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'PARA'
    UNION ALL SELECT  45, N'Chief Executive', 1, 0, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  46, N'Account Manager', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  47, N'Financial Advisor', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  50, N'8038-CP Filing Agent ', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  51, N'Insurance Agent', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N'I'
    UNION ALL SELECT  52, N'Rating Analyst', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  53, N'Recipient of Certificate of Purchaser', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  54, N'Rating Analyst - KS', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  55, N'Rating Analyst - MI', 0, 1, 0, 1, N'', GETDATE(), N'Conversion', N''
    UNION ALL SELECT  56, N'Bidder', 1, 1, 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  57, N'OMS Provider ', 0, 1, 0, 1, NULL, GETDATE(), N'Conversion', N'OMSP'
    UNION ALL SELECT  58, N'OMS Bidding ', 0, 1, 0, 1, NULL, GETDATE(), N'Conversion', N'OMSB'
    UNION ALL SELECT  59, N'Insurance Expense', 0, 1, 0, 1, NULL, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  60, N'Primary Contact', 0, 1, 0, 1, NULL, GETDATE(), N'Conversion', N'PRIM'
    UNION ALL SELECT  61, N'Developer', 0, 1, 0, 1, NULL, GETDATE(), N'Conversion', N'DC'
    UNION ALL SELECT  62, N'Architect', 0, 1, 0, 1, NULL, GETDATE(), N'Conversion', N'ARC'
    UNION ALL SELECT  63, N'Paying Agent Contact 1', 1, 0, 0, 1, NULL, GETDATE(), N'dholmes', N'PA1'
    UNION ALL SELECT  64, N'8038-CP Contact', 1, 0, 0, 1, NULL, GETDATE(), N'Conversion', N'CP'
    UNION ALL SELECT  65, N'Continuing Disclosure Contact', 1, 0, 0, 1, NULL, GETDATE(), N'Conversion', N'DC'
    UNION ALL SELECT  66, N'Economic Development Contact', 0, 0, 0, 1, NULL, GETDATE(), N'Conversion', N'EDC'
    UNION ALL SELECT  67, N'Marketing Contact', 1, 0, 0, 1, NULL, GETDATE(), N'Conversion', N'PMC'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.JobFunction    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.JobFunction OFF ;
    SET IDENTITY_INSERT dbo.JurisdictionType ON ;

    INSERT  dbo.JurisdictionType ( JurisdictionTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, DefaultOSValue, LegacyValue )  
    SELECT  1, N'Airport Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'Airport Authority'
    UNION ALL SELECT  2, N'Building Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'Building Authority'
    UNION ALL SELECT  3, N'City', 0, 1, N'', GETDATE(), N'Conversion', N'City', N'City'
    UNION ALL SELECT  4, N'Community Development Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'CDA'
    UNION ALL SELECT  5, N'Conduit Borrower ', 0, 1, N'', GETDATE(), N'Conversion', N'', N'Conduit Borrower'
    UNION ALL SELECT  6, N'County', 0, 1, N'', GETDATE(), N'Conversion', N'County', N'County'
    UNION ALL SELECT  7, N'Economic Development Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'EDA'
    UNION ALL SELECT  9, N'Fire Protection District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Fire Protection District'
    UNION ALL SELECT  10, N'Forest Preserve District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Forest Preserve District'
    UNION ALL SELECT  11, N'Higher Education', 0, 1, N'', GETDATE(), N'Conversion', N'Higher Education', N'Higher Education'
    UNION ALL SELECT  12, N'Hospital District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Hospital District'
    UNION ALL SELECT  13, N'Housing Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'Housing Authority'
    UNION ALL SELECT  14, N'Housing & Redevelopment Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'HRA'
    UNION ALL SELECT  16, N'Lake Protection and Rehabilitation District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Lake Protection and Rehabilitation District'
    UNION ALL SELECT  17, N'Library District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Library District'
    UNION ALL SELECT  18, N'Municipal Power Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'Municipal Power Authority'
    UNION ALL SELECT  19, N'Park District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Park District'
    UNION ALL SELECT  20, N'Port Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'Port Authority'
    UNION ALL SELECT  21, N'Private - Invoice Only', 0, 1, N'', GETDATE(), N'Conversion', N'', N'Private - Invoice Only'
    UNION ALL SELECT  22, N'Railroad Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'Railroad Authority'
    UNION ALL SELECT  23, N'Redevelopment Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'Redevelopment Authority'
    UNION ALL SELECT  24, N'Sanitary District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Sanitary District'
    UNION ALL SELECT  25, N'School District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'School District'
    UNION ALL SELECT  26, N'State', 0, 1, N'', GETDATE(), N'Conversion', N'State', N'State'
    UNION ALL SELECT  27, N'Town', 0, 1, N'', GETDATE(), N'Conversion', N'Town', N'Town'
    UNION ALL SELECT  28, N'Township', 0, 1, N'', GETDATE(), N'Conversion', N'Township', N'Township'
    UNION ALL SELECT  29, N'Unknown', 0, 1, N'', GETDATE(), N'Conversion', N'Unknown', N'Unknown'
    UNION ALL SELECT  30, N'Utility', 0, 1, N'', GETDATE(), N'Conversion', N'Utility', N'Utility'
    UNION ALL SELECT  31, N'Village', 0, 1, N'', GETDATE(), N'Conversion', N'Village', N'Village'
    UNION ALL SELECT  32, N'Water District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Water District'
    UNION ALL SELECT  33, N'Watershed / Storm Sewer District ', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Watershed/StormSew Dist'
    UNION ALL SELECT  34, N'Public Transit', 0, 1, N'', GETDATE(), N'Conversion', N'Public Transit', N'Public Transit'
    UNION ALL SELECT  35, N'Special Education District', 0, 1, N'', GETDATE(), N'Conversion', N'District', N'Special Education District'
    UNION ALL SELECT  36, N'Sporting Facilities Commission', 0, 1, N'', GETDATE(), N'Conversion', N'Commission', N'Sporting Facilities Commission'
    UNION ALL SELECT  37, N'State Loan Pool', 0, 1, N'', GETDATE(), N'Conversion', N'State Loan Pool', N'State Loan Pool'
    UNION ALL SELECT  38, N'Water Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', NULL
    UNION ALL SELECT  39, N'River Valley Development Authority', 0, 1, N'', GETDATE(), N'Conversion', N'Authority', N'Development Authority'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.JurisdictionType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.JurisdictionType OFF ;
    SET IDENTITY_INSERT dbo.MailingType ON ;

    INSERT  dbo.MailingType ( MailingTypeID, Value, DisplaySequence, Active, Description, IsClient, IsFirm, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  3, N'Christmas E-Card', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'Xmas'
    UNION ALL SELECT  4, N'Client Questionnaire', 0, 1, N'', 1, 0, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  5, N'Closing Document', 0, 1, N'', 1, 0, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  7, N'Ehlers Blog', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'EBLG'
    UNION ALL SELECT  8, N'E-mail Alert', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'EMA'
    UNION ALL SELECT  9, N'OS - Final ', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'OSM'
    UNION ALL SELECT  10, N'Invoice', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  11, N'Market Commentary', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'BWC'
    UNION ALL SELECT  12, N'Newsletter - IL', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'NI'
    UNION ALL SELECT  13, N'Newsletter - MN City', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'NM'
    UNION ALL SELECT  14, N'Newsletter - MN Education', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'NM'
    UNION ALL SELECT  15, N'Newsletter - WI', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'NW'
    UNION ALL SELECT  21, N'OS -  Preliminary', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'OSM'
    UNION ALL SELECT  23, N'Refunding Letter', 0, 1, N'', 1, 0, GETDATE(), N'Conversion', N'RL'
    UNION ALL SELECT  24, N'Seminar - MN City', 0, 1, N'', 1, 1, GETDATE(), N'Conversion', N'P'
    UNION ALL SELECT  28, N'Seminar - MN Education', 0, 1, NULL, 1, 1, GETDATE(), N'Conversion', N'S'
    UNION ALL SELECT  29, N'Seminar - WI', 0, 1, NULL, 1, 1, GETDATE(), N'Conversion', N'WS'
    UNION ALL SELECT  30, N'Seminar - IL', 0, 1, NULL, 1, 1, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  31, N'County Auditor Certificate', 0, 1, NULL, 1, 0, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  32, N'County Auditor Certificate of Registration', 0, 1, NULL, 1, 0, GETDATE(), N'Conversion', N''
    UNION ALL SELECT  33, N'TIF Blog', 99, 0, NULL, 0, 0, GETDATE(), N'Conversion', N'TBLG'
    UNION ALL SELECT  34, N'Datebook', 99, 0, NULL, 0, 0, GETDATE(), N'Conversion', N'D'
    UNION ALL SELECT  35, N'State Trust Fund Mailing', 99, 0, NULL, 0, 0, GETDATE(), N'Conversion', N'STF'
    UNION ALL SELECT  36, N'Calendar- IL', 99, 0, NULL, 0, 0, GETDATE(), N'Conversion', N'CI'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.MailingType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.MailingType OFF ;
    SET IDENTITY_INSERT dbo.MaterialEventType ON ;

    INSERT  dbo.MaterialEventType ( MaterialEventTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Bond call', 1, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Defeasance', 2, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Rating change', 3, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Principal and interest payment delinquency', 4, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Non payment default', 5, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Unscheduled draws on debt service reserves reflecting financial difficulties', 6, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'Unscheduled draws on credit enhancements reflecting financial difficulties', 7, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  8, N'Substitution of credit or liquidity providers or their failure to perform', 8, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  9, N'Adverse tax opinions, IRS notices or material events affecting the tax status of the security', 9, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  10, N'Modifications to rights of security holders', 10, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  11, N'Release, substitution or sale of property securing repayment of the securities', 11, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  12, N'Tender offer', 12, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  13, N'Bankruptcy, insolvency, receivership or similar event of the obligated person', 13, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  14, N'Merger, consolidation, or acquisition of the obligated person', 14, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  15, N'Appointment of a successor or additional trustee, or the change of name of a trustee', 15, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  16, N'Failure to file', 16, 1, NULL, GETDATE(), N'dholmes', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.MaterialEventType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.MaterialEventType OFF ;
    SET IDENTITY_INSERT dbo.MeetingPurpose ON ;

    INSERT  dbo.MeetingPurpose ( MeetingPurposeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'501C-3 Hearing', 10, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Authorization of Sale', 3, 1, N'for Joint Client Meetings', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Award Sale', 1, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'BINA Hearing', 11, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Canvassed by County', 12, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Credit Enhancement', 8, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'Election', 5, 0, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  8, N'Initial Resolution adoption', 4, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  9, N'Pre-Sale', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  10, N'Ratify Parameters', 7, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  11, N'Set Parameters', 6, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  12, N'TIF Pledge Agreement', 9, 1, N'for Joint Client Meetings', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.MeetingPurpose    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.MeetingPurpose OFF ;
    SET IDENTITY_INSERT dbo.MeetingType ON ;

    INSERT  dbo.MeetingType ( MeetingTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Regular', 1, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Special', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Staff Authorization', 3, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.MeetingType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.MeetingType OFF ;
    SET IDENTITY_INSERT dbo.MethodOfSale ON ;

    INSERT  dbo.MethodOfSale ( MethodOfSaleID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Competitive - Full Distribution List', 1, 1, N'', GETDATE(), N'Conversion', N'C'
    UNION ALL SELECT  2, N'Competitive - Limited Distribution List', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Negotiated - RFP Process for underwriter', 3, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Negotiated - 1 purchaser/underwriter', 4, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'N/A', 5, 1, N'', GETDATE(), N'Conversion', N'NA'
    UNION ALL SELECT  7, N'Negotatied', 99, 0, NULL, GETDATE(), N'Conversion', N'N'
    UNION ALL SELECT  8, N'Negotiated No OS', 99, 0, NULL, GETDATE(), N'Conversion', N'NN'
    UNION ALL SELECT  9, N'Negotiated Partial OS', 99, 0, NULL, GETDATE(), N'Conversion', N'NP'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.MethodOfSale    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.MethodOfSale OFF ;
    SET IDENTITY_INSERT dbo.OverlapType ON ;

    INSERT  dbo.OverlapType ( OverlapTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Counties', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Cities, Towns or Villages', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'School Districts', 0, 1, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Other', 0, 1, NULL, GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.OverlapType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.OverlapType OFF ;
    SET IDENTITY_INSERT dbo.PaymentMethod ON ;

    INSERT  dbo.PaymentMethod ( PaymentMethodID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Invoice to Client', 3, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Invoice with Disclosure', 4, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Paid Through Escrow', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Purchaser Paid ', 5, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Through Kline Bank', 1, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.PaymentMethod    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.PaymentMethod OFF ;
    SET IDENTITY_INSERT dbo.PaymentType ON ;

    INSERT  dbo.PaymentType ( PaymentTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Assessment Calculation', 1, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Multiple Equal Payments', 2, 1, N'An equal payment is made over multiple years, ex: $10,000 for 4 years', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Multiple Payment Amounts', 3, 1, N'Multiple payments that may have a different amounts', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'P & I Calculation', 4, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'Single payment', 5, 1, N'A lump sum is paid once during the bond term.', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.PaymentType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.PaymentType OFF ;
    SET IDENTITY_INSERT dbo.PotentialRefundType ON ;

    INSERT  dbo.PotentialRefundType ( PotentialRefundTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Net cash / Full net cash', 1, 1, NULL, GETDATE(), N'Conversion', N'Net cash'
    UNION ALL SELECT  2, N'Full net cash', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', N'Full net cash'
    UNION ALL SELECT  3, N'Crossover', 2, 1, NULL, GETDATE(), N'Conversion', N'Crossover'
    UNION ALL SELECT  4, N'Current', 3, 1, NULL, GETDATE(), N'Conversion', N'Current'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.PotentialRefundType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.PotentialRefundType OFF ;
    SET IDENTITY_INSERT dbo.Rating ON ;

    INSERT  dbo.Rating ( RatingID, RatingAgency, Value, DisplaySequence, Active, IssueUseOnly )  
    SELECT  56, N'Moody', N'AAA', 1, 1, 0
    UNION ALL SELECT  57, N'Moody', N'AA', 2, 1, 0
    UNION ALL SELECT  58, N'Moody', N'Aa1', 3, 1, 0
    UNION ALL SELECT  59, N'Moody', N'Aa2', 4, 1, 0
    UNION ALL SELECT  60, N'Moody', N'Aa3', 5, 1, 0
    UNION ALL SELECT  61, N'Moody', N'A', 6, 1, 0
    UNION ALL SELECT  62, N'Moody', N'A1', 7, 1, 0
    UNION ALL SELECT  63, N'Moody', N'A2', 8, 1, 0
    UNION ALL SELECT  64, N'Moody', N'A3', 9, 1, 0
    UNION ALL SELECT  65, N'Moody', N'Baa', 10, 1, 0
    UNION ALL SELECT  66, N'Moody', N'Baa1', 11, 1, 0
    UNION ALL SELECT  67, N'Moody', N'Baa2', 12, 1, 0
    UNION ALL SELECT  68, N'Moody', N'Baa3', 13, 1, 0
    UNION ALL SELECT  69, N'Moody', N'Ba', 14, 1, 0
    UNION ALL SELECT  70, N'Moody', N'Ba1', 15, 1, 0
    UNION ALL SELECT  71, N'Moody', N'Ba2', 16, 1, 0
    UNION ALL SELECT  72, N'Moody', N'Ba3', 17, 1, 0
    UNION ALL SELECT  73, N'Moody', N'B', 18, 1, 0
    UNION ALL SELECT  74, N'Moody', N'B1', 19, 1, 0
    UNION ALL SELECT  75, N'Moody', N'B2', 20, 1, 0
    UNION ALL SELECT  76, N'Moody', N'B3', 21, 1, 0
    UNION ALL SELECT  77, N'Moody', N'Caa', 22, 1, 0
    UNION ALL SELECT  78, N'Moody', N'Ca', 23, 1, 0
    UNION ALL SELECT  79, N'Moody', N'C', 24, 1, 0
    UNION ALL SELECT  80, N'Moody', N'S', 26, 1, 1
    UNION ALL SELECT  81, N'Moody', N'UR', 27, 1, 1
    UNION ALL SELECT  82, N'Moody', N'MIG1', 28, 1, 1
    UNION ALL SELECT  83, N'Moody', N'MIG2', 29, 1, 1
    UNION ALL SELECT  84, N'Moody', N'MIG3', 30, 1, 1
    UNION ALL SELECT  85, N'StandardPoor', N'AAA', 1, 1, 0
    UNION ALL SELECT  86, N'StandardPoor', N'AA+', 3, 1, 0
    UNION ALL SELECT  87, N'StandardPoor', N'AA', 4, 1, 0
    UNION ALL SELECT  88, N'StandardPoor', N'AA-', 5, 1, 0
    UNION ALL SELECT  89, N'StandardPoor', N'A+', 6, 1, 0
    UNION ALL SELECT  90, N'StandardPoor', N'A', 7, 1, 0
    UNION ALL SELECT  91, N'StandardPoor', N'A-', 8, 1, 0
    UNION ALL SELECT  92, N'StandardPoor', N'BBB+', 9, 1, 0
    UNION ALL SELECT  93, N'StandardPoor', N'BBB', 10, 1, 0
    UNION ALL SELECT  94, N'StandardPoor', N'BBB-', 11, 1, 0
    UNION ALL SELECT  95, N'StandardPoor', N'BB+', 12, 1, 0
    UNION ALL SELECT  96, N'StandardPoor', N'BB', 13, 1, 0
    UNION ALL SELECT  97, N'StandardPoor', N'BB-', 14, 1, 0
    UNION ALL SELECT  98, N'StandardPoor', N'B+', 15, 1, 0
    UNION ALL SELECT  99, N'StandardPoor', N'B', 16, 1, 0
    UNION ALL SELECT  100, N'StandardPoor', N'B-', 17, 1, 0
    UNION ALL SELECT  101, N'StandardPoor', N'CCC+', 18, 1, 0
    UNION ALL SELECT  102, N'StandardPoor', N'CCC', 19, 1, 0
    UNION ALL SELECT  103, N'StandardPoor', N'CCC-', 20, 1, 0
    UNION ALL SELECT  104, N'StandardPoor', N'CC+', 21, 1, 0
    UNION ALL SELECT  105, N'StandardPoor', N'CC', 22, 1, 0
    UNION ALL SELECT  106, N'StandardPoor', N'CC-', 23, 1, 0
    UNION ALL SELECT  107, N'StandardPoor', N'C+', 24, 1, 0
    UNION ALL SELECT  108, N'StandardPoor', N'C', 25, 1, 0
    UNION ALL SELECT  109, N'StandardPoor', N'C-', 26, 1, 0
    UNION ALL SELECT  110, N'StandardPoor', N'D', 27, 1, 0
    UNION ALL SELECT  111, N'StandardPoor', N'S', 29, 1, 1
    UNION ALL SELECT  112, N'StandardPoor', N'UR', 30, 1, 1
    UNION ALL SELECT  113, N'StandardPoor', N'SP1+', 31, 1, 1
    UNION ALL SELECT  114, N'Fitch', N'AAA', 1, 1, 0
    UNION ALL SELECT  115, N'Fitch', N'AA+', 2, 1, 0
    UNION ALL SELECT  116, N'Fitch', N'AA', 3, 1, 0
    UNION ALL SELECT  117, N'Fitch', N'AA-', 4, 1, 0
    UNION ALL SELECT  118, N'Fitch', N'A+', 5, 1, 0
    UNION ALL SELECT  119, N'Fitch', N'A', 6, 1, 0
    UNION ALL SELECT  120, N'Fitch', N'A-', 7, 1, 0
    UNION ALL SELECT  121, N'Fitch', N'BBB+', 8, 1, 0
    UNION ALL SELECT  122, N'Fitch', N'BBB', 9, 1, 0
    UNION ALL SELECT  123, N'Fitch', N'BBB-', 10, 1, 0
    UNION ALL SELECT  124, N'Fitch', N'BB+', 11, 1, 0
    UNION ALL SELECT  125, N'Fitch', N'BB', 12, 1, 0
    UNION ALL SELECT  126, N'Fitch', N'BB-', 13, 1, 0
    UNION ALL SELECT  127, N'Fitch', N'B+', 14, 1, 0
    UNION ALL SELECT  128, N'Fitch', N'B', 15, 1, 0
    UNION ALL SELECT  129, N'Fitch', N'B-', 16, 1, 0
    UNION ALL SELECT  130, N'Fitch', N'CCC+', 17, 1, 0
    UNION ALL SELECT  131, N'Fitch', N'CCC', 18, 1, 0
    UNION ALL SELECT  132, N'Fitch', N'CCC-', 19, 1, 0
    UNION ALL SELECT  133, N'Fitch', N'CC+', 20, 1, 0
    UNION ALL SELECT  134, N'Fitch', N'CC', 21, 1, 0
    UNION ALL SELECT  135, N'Fitch', N'CC-', 22, 1, 0
    UNION ALL SELECT  136, N'Fitch', N'C+', 23, 1, 0
    UNION ALL SELECT  137, N'Fitch', N'C', 24, 1, 0
    UNION ALL SELECT  138, N'Fitch', N'C-', 25, 1, 0
    UNION ALL SELECT  139, N'Fitch', N'DDD', 26, 1, 0
    UNION ALL SELECT  140, N'Fitch', N'DD', 27, 1, 0
    UNION ALL SELECT  141, N'Fitch', N'D', 28, 1, 0
    UNION ALL SELECT  142, N'Fitch', N'S', 31, 1, 1
    UNION ALL SELECT  143, N'Fitch', N'UR', 32, 1, 1
    UNION ALL SELECT  144, N'Fitch', N'WE', 33, 1, 1  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.Rating    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.Rating OFF ;
    SET IDENTITY_INSERT dbo.RatingType ON ;

    INSERT  dbo.RatingType ( RatingTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Annual Appropriation', 10, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  2, N'Credit Enhancement - Long Term', 10, 1, N'Credit Enhancement Rating', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Credit Enhancement - Short Term', 10, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Electric Revenue', 10, 1, N'Electric Revenue Rating', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  5, N'General Obligation', 1, 1, N'Underlying General Obligation Rating ', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  6, N'Sewer Revenue', 10, 1, N'Sewer Revenue Rating', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  7, N'Short Term', 10, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  8, N'Utility Revenue', 10, 1, N'All Utilities Revenue Rating', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  9, N'Water Revenue', 10, 1, N'Water Revenue Rating', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  10, N'Limited Obligation', 99, 0, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  11, N'Revenue', 99, 0, NULL, GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  12, N'Special Obligation', 99, 0, NULL, GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.RatingType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.RatingType OFF ;
    SET IDENTITY_INSERT dbo.RefundType ON ;

    INSERT  dbo.RefundType ( RefundTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Current - Full', 1, 1, NULL, GETDATE(), N'Conversion', N'Current Refunding'
    UNION ALL SELECT  2, N'Current - Partial Issue', 2, 1, NULL, GETDATE(), N'Conversion', N'Current Refunding'
    UNION ALL SELECT  3, N'Current - Partial Maturities', 3, 1, NULL, GETDATE(), N'Conversion', N'Current Refunding'
    UNION ALL SELECT  4, N'Net Cash - Partial Issue', 5, 1, NULL, GETDATE(), N'Conversion', N'Partial Net Cash'
    UNION ALL SELECT  5, N'Net Cash - Partial Maturities', 6, 1, NULL, GETDATE(), N'Conversion', N'Partial Net Cash'
    UNION ALL SELECT  6, N'Net Cash - Full', 4, 1, NULL, GETDATE(), N'Conversion', N'Partial Net Cash'
    UNION ALL SELECT  7, N'Crossover - Full', 7, 1, NULL, GETDATE(), N'Conversion', N'Cross-over Refunded'
    UNION ALL SELECT  8, N'Crossover - Partial Issue', 8, 1, NULL, GETDATE(), N'Conversion', N'Cross-over Refunded'
    UNION ALL SELECT  9, N'Crossover - Partial Maturties', 9, 1, NULL, GETDATE(), N'Conversion', N'Cross-over Refunded'
    UNION ALL SELECT  10, N'Cash - Current - Full', 10, 1, NULL, GETDATE(), N'Conversion', N'Current Refunded with Cash'
    UNION ALL SELECT  11, N'Cash - Current - Partial Issue', 11, 1, NULL, GETDATE(), N'Conversion', N'Current Refunded with Cash'
    UNION ALL SELECT  12, N'Cash - Current - Partial Maturities', 12, 1, NULL, GETDATE(), N'Conversion', N'Current Refunded with Cash'
    UNION ALL SELECT  13, N'Cash Defeasance - Escrow to Maturity - Full', 13, 1, NULL, GETDATE(), N'Conversion', N'Cash Defeas. Escrow to Maturity'
    UNION ALL SELECT  14, N'Cash Defeasance - Escrow to Maturity - Partial', 14, 1, NULL, GETDATE(), N'Conversion', N'Cash Defeas. Escrow to Maturity'
    UNION ALL SELECT  15, N'Cash Defeasance - Escrow to Call - Full', 15, 1, NULL, GETDATE(), N'Conversion', N'Cash Defeas. Escrow to Call'
    UNION ALL SELECT  16, N'Cash Defeasance - Escrow to Call - Partial', 16, 1, NULL, GETDATE(), N'Conversion', N'Cash Defeas. Escrow to Call'
    UNION ALL SELECT  17, N'Called Due to Default', 17, 1, NULL, GETDATE(), N'Conversion', N'Called due to Default'
    UNION ALL SELECT  18, N'Called', 18, 1, NULL, GETDATE(), N'Conversion', N'Called'
    UNION ALL SELECT  19, N'Partially Refinanced, see new numbers', 99, 0, NULL, GETDATE(), N'Conversion', N'Partially Refinanced, see new numbers'
    UNION ALL SELECT  20, N'Esc to Conv Date', 99, 0, NULL, GETDATE(), N'Conversion', N'Esc to Conv Date'
    UNION ALL SELECT  21, N'Rmktg', 99, 0, NULL, GETDATE(), N'Conversion', N'Rmktg'
    UNION ALL SELECT  22, N'Pre-Refunded', 99, 0, NULL, GETDATE(), N'Conversion', N'Pre-Refunded'
    UNION ALL SELECT  23, N'Esc to Maty', 99, 0, NULL, GETDATE(), N'Conversion', N'Esc to Maty'
    UNION ALL SELECT  24, N'Cross-over refunding-Escrowed TLL', 99, 0, NULL, GETDATE(), N'Conversion', N'Cross-over refunding-Escrowed TLL'
    UNION ALL SELECT  25, N'Advance Refunding', 99, 0, NULL, GETDATE(), N'Conversion', N'Advance Refunding'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.RefundType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.RefundType OFF ;
    SET IDENTITY_INSERT dbo.SecurityType ON ;

    INSERT  dbo.SecurityType ( SecurityTypeID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Annual Appropriation', 0, 1, N'', GETDATE(), N'Conversion', N'P'
    UNION ALL SELECT  2, N'General Obligation', 0, 1, N'', GETDATE(), N'Conversion', N'A'
    UNION ALL SELECT  3, N'Limited Obligation', 0, 1, N'', GETDATE(), N'Conversion', N'L'
    UNION ALL SELECT  4, N'Revenue', 0, 1, N'', GETDATE(), N'Conversion', N'R'
    UNION ALL SELECT  5, N'Special Obligation', 0, 1, N'', GETDATE(), N'Conversion', N'S'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.SecurityType    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.SecurityType OFF ;
    SET IDENTITY_INSERT dbo.UnusedChoice ON ;

    INSERT  dbo.UnusedChoice ( UnusedChoiceID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Debt Service Fund', 2, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  3, N'Project Fund', 1, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  4, N'Reduce Issue Size', 3, 1, N'', GETDATE(), N'Conversion', NULL  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.UnusedChoice    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.UnusedChoice OFF ;
    SET IDENTITY_INSERT dbo.UseProceed ON ;

    INSERT  dbo.UseProceed ( UseProceedID, Value, DisplaySequence, Active, Description, ModifiedDate, ModifiedUser, LegacyValue )  
    SELECT  1, N'Airport or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'AIR'
    UNION ALL SELECT  2, N'Alleys or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'ALL'
    UNION ALL SELECT  3, N'Assisted Living Facility or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'ALF'
    UNION ALL SELECT  4, N'Bridges or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'BDG'
    UNION ALL SELECT  5, N'Cable Television', 0, 1, N'', GETDATE(), N'Conversion', N'TV'
    UNION ALL SELECT  6, N'Cashflow', 0, 1, N'', GETDATE(), N'Conversion', N'CF'
    UNION ALL SELECT  7, N'City Hall or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'CH'
    UNION ALL SELECT  8, N'Civic/Convention Centers or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'CC'
    UNION ALL SELECT  9, N'Community Center or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'CC'
    UNION ALL SELECT  10, N'Courthouse or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'COU'
    UNION ALL SELECT  11, N'Curb and Gutter', 0, 1, N'', GETDATE(), N'Conversion', N'CG'
    UNION ALL SELECT  12, N'Economic Development', 0, 1, N'', GETDATE(), N'Conversion', N'ECON'
    UNION ALL SELECT  13, N'Electricity/Public Power Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'ELC'
    UNION ALL SELECT  14, N'Energy Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'EI'
    UNION ALL SELECT  15, N'Environmental Remediation', 0, 1, N'', GETDATE(), N'Conversion', N'ER'
    UNION ALL SELECT  16, N'Equipment', 0, 1, N'', GETDATE(), N'Conversion', N'EQ'
    UNION ALL SELECT  17, N'Fire Station or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'FIR'
    UNION ALL SELECT  18, N'Gas Utility or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'GAS'
    UNION ALL SELECT  19, N'General Purpose/Public Improvement', 0, 1, N'', GETDATE(), N'Conversion', N'GEN'
    UNION ALL SELECT  20, N'Golf Course or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'GOLF'
    UNION ALL SELECT  21, N'Hopital or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'HOS'
    UNION ALL SELECT  22, N'Housing Improvement Area', 0, 1, N'', GETDATE(), N'Conversion', N'HIA'
    UNION ALL SELECT  23, N'Ice Arena or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'IA'
    UNION ALL SELECT  24, N'Industrial Development', 0, 1, N'', GETDATE(), N'Conversion', N'IND'
    UNION ALL SELECT  25, N'Industrial Park Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'IPI'
    UNION ALL SELECT  26, N'Jail or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'JAIL'
    UNION ALL SELECT  27, N'Judgement Bonds', 0, 1, N'', GETDATE(), N'Conversion', N'JB'
    UNION ALL SELECT  28, N'Land and/or Building Acquisition', 0, 1, N'', GETDATE(), N'Conversion', N'LAND'
    UNION ALL SELECT  29, N'Land Clearance', 0, 1, N'', GETDATE(), N'Conversion', N'LC'
    UNION ALL SELECT  30, N'Land Preservation', 0, 1, N'', GETDATE(), N'Conversion', N'LF'
    UNION ALL SELECT  31, N'Landfill', 0, 1, N'', GETDATE(), N'Conversion', N'LP'
    UNION ALL SELECT  32, N'Library or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'LIB'
    UNION ALL SELECT  33, N'Liquor Store or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'LS'
    UNION ALL SELECT  34, N'Maintenance Facility or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'MAIN'
    UNION ALL SELECT  35, N'Mall/Shopping Center', 0, 1, N'', GETDATE(), N'Conversion', N'MALL'
    UNION ALL SELECT  36, N'Marina/Marine Terminals', 0, 1, N'', GETDATE(), N'Conversion', N'MAR'
    UNION ALL SELECT  37, N'Mass/Rapid Transit', 0, 1, N'', GETDATE(), N'Conversion', N'TRAN'
    UNION ALL SELECT  38, N'Miscellaneous Subdivision Improvement', 0, 1, N'', GETDATE(), N'Conversion', N'SI'
    UNION ALL SELECT  39, N'Multi-family Housing', 0, 1, N'', GETDATE(), N'Conversion', N'MUL'
    UNION ALL SELECT  40, N'New School Building or Addition', 0, 1, N'', GETDATE(), N'Conversion', N'SCH'
    UNION ALL SELECT  41, N'Nursing Home or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'NH'
    UNION ALL SELECT  42, N'Office Building or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'OFF'
    UNION ALL SELECT  43, N'Other Health Care', 0, 1, N'', GETDATE(), N'Conversion', N'OHC'
    UNION ALL SELECT  44, N'Other Housing', 0, 1, N'', GETDATE(), N'Conversion', N'OHS'
    UNION ALL SELECT  45, N'Other Industrial Development', 0, 1, N'', GETDATE(), N'Conversion', N'OID'
    UNION ALL SELECT  46, N'Other Recreational', 0, 1, N'', GETDATE(), N'Conversion', N'OREC'
    UNION ALL SELECT  47, N'Other Transportation', 0, 1, N'', GETDATE(), N'Conversion', N'OTRN'
    UNION ALL SELECT  48, N'Parking Facilities or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'PF'
    UNION ALL SELECT  49, N'Parks or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'PRK'
    UNION ALL SELECT  50, N'Permanent Improvements Revolving Fund', 0, 1, N'', GETDATE(), N'Conversion', N'PIR'
    UNION ALL SELECT  51, N'Planning Expenses', 0, 1, N'', GETDATE(), N'Conversion', N'PE'
    UNION ALL SELECT  52, N'Police Station or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'POL'
    UNION ALL SELECT  53, N'Pollution Control', 0, 1, N'', GETDATE(), N'Conversion', N'PC'
    UNION ALL SELECT  54, N'Public Works Building', 0, 1, N'', GETDATE(), N'Conversion', N'PWB'
    UNION ALL SELECT  55, N'Redevelopment', 0, 1, N'', GETDATE(), N'Conversion', N'RD'
    UNION ALL SELECT  56, N'Refunding Crossover', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  57, N'Refunding Current', 0, 1, N'', GETDATE(), N'Conversion', N'CR'
    UNION ALL SELECT  58, N'Refunding Net Cash - Full', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  59, N'Refunding Net Cash - Partial', 0, 1, N'', GETDATE(), N'Conversion', NULL
    UNION ALL SELECT  60, N'Roofing Improvement', 0, 1, N'', GETDATE(), N'Conversion', N'RFI'
    UNION ALL SELECT  61, N'Sanitary Sewer Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'SAN'
    UNION ALL SELECT  62, N'School Addition', 0, 1, N'', GETDATE(), N'Conversion', N'SA'
    UNION ALL SELECT  63, N'School Renovation and Remodeling', 0, 1, N'', GETDATE(), N'Conversion', N'SR'
    UNION ALL SELECT  64, N'Senior Center', 0, 1, N'', GETDATE(), N'Conversion', N'SC'
    UNION ALL SELECT  65, N'Sidewalks or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'SID'
    UNION ALL SELECT  66, N'Solid Waste or Resource Recovery', 0, 1, N'', GETDATE(), N'Conversion', N'SOL'
    UNION ALL SELECT  68, N'Stadium/Sports Complex or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'STAD'
    UNION ALL SELECT  69, N'State Aid Streets ', 0, 1, N'', GETDATE(), N'Conversion', N'SAS'
    UNION ALL SELECT  70, N'Storm Sewer/Drainage', 0, 1, N'', GETDATE(), N'Conversion', N'STRM'
    UNION ALL SELECT  71, N'Streets or Improvements ', 0, 1, N'', GETDATE(), N'Conversion', N'ST'
    UNION ALL SELECT  72, N'Streetscape', 0, 1, N'', GETDATE(), N'Conversion', N'SS'
    UNION ALL SELECT  73, N'Swimming Pool or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'POOL'
    UNION ALL SELECT  74, N'Take Out Temp Bonds', 0, 1, N'', GETDATE(), N'Conversion', N'TTB'
    UNION ALL SELECT  75, N'Tax Increment Projects', 0, 1, N'', GETDATE(), N'Conversion', N'TIF'
    UNION ALL SELECT  76, N'Technology', 0, 1, N'', GETDATE(), N'Conversion', N'TEC'
    UNION ALL SELECT  77, N'Telecommunications', 0, 1, N'', GETDATE(), N'Conversion', N'TC'
    UNION ALL SELECT  78, N'Telephone Utility or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'TELE'
    UNION ALL SELECT  79, N'Theater', 0, 1, N'', GETDATE(), N'Conversion', N'THE'
    UNION ALL SELECT  80, N'Unfunded Pension Liability', 0, 1, N'', GETDATE(), N'Conversion', N'UL'
    UNION ALL SELECT  81, N'Wastewater Treatment Facility or Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'WTF'
    UNION ALL SELECT  82, N'Water Improvements', 0, 1, N'', GETDATE(), N'Conversion', N'WAT'
    UNION ALL SELECT  83, N'Tennis Courts', 0, 1, NULL, GETDATE(), N'Conversion', N'TN'
    UNION ALL SELECT  84, N'Advance Refunding', 99, 0, N'VB6 Conversion', GETDATE(), N'Conversion', N'AR'  ;
    SELECT  @count = @@ROWCOUNT ;
    PRINT   'Rows inserted to dbo.UseProceed    = ' + STR( @count, 8 ) ; 
    
    SET IDENTITY_INSERT dbo.UseProceed OFF ;

END TRY
BEGIN CATCH

    EXECUTE dbo.processEhlersError ;

END CATCH
