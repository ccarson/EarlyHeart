CREATE VIEW dbo.vw_DropDownListValues
AS
SELECT  'AddressType'                      AS Category, Value, DisplaySequence, Active FROM AddressType UNION ALL
SELECT  'ArbitrageCategory'                AS Category, Value, DisplaySequence, Active FROM ArbitrageCategory UNION ALL
SELECT  'ArbitrageComputationType'         AS Category, Value, DisplaySequence, Active FROM ArbitrageComputationType UNION ALL
SELECT  'ArbitrageException'               AS Category, Value, DisplaySequence, Active FROM ArbitrageException UNION ALL
SELECT  'ArbitrageRecordStatus'            AS Category, Value, DisplaySequence, Active FROM ArbitrageRecordStatus UNION ALL
SELECT  'ArbitrageRecordType'              AS Category, Value, DisplaySequence, Active FROM ArbitrageRecordType UNION ALL
SELECT  'ArbitrageStatus'                  AS Category, Value, DisplaySequence, Active FROM ArbitrageStatus UNION ALL
SELECT  'ARRAType'                         AS Category, Value, DisplaySequence, Active FROM ARRAType UNION ALL
SELECT  'AuditorFeeType'                   AS Category, Value, DisplaySequence, Active FROM AuditorFeeType UNION ALL
SELECT  'BidSource'                        AS Category, Value, DisplaySequence, Active FROM BidSource UNION ALL
SELECT  'BondFormType'                     AS Category, Value, DisplaySequence, Active FROM BondFormType UNION ALL
SELECT  'CallFrequency'                    AS Category, Value, DisplaySequence, Active FROM CallFrequency UNION ALL
SELECT  'CallType'                         AS Category, Value, DisplaySequence, Active FROM CallType UNION ALL
SELECT  'ClientStatus'                     AS Category, Value, DisplaySequence, Active FROM ClientStatus UNION ALL
SELECT  'CommissionType'                   AS Category, Value, DisplaySequence, Active FROM CommissionType UNION ALL
SELECT  'ContractStatus'                   AS Category, Value, DisplaySequence, Active FROM ContractStatus UNION ALL
SELECT  'DeliveryMethod'                   AS Category, Value, DisplaySequence, Active FROM DeliveryMethod UNION ALL
SELECT  'DisclosureType'                   AS Category, Value, DisplaySequence, Active FROM DisclosureType UNION ALL
SELECT  'DocumentType'                     AS Category, Value, DisplaySequence, Active FROM DocumentType UNION ALL
SELECT  'EhlersJobGroup'                   AS Category, Value, 0 AS DisplaySequence, Active FROM EhlersJobGroup UNION ALL
SELECT  'ElectionType'                     AS Category, Value, DisplaySequence, Active FROM ElectionType UNION ALL
SELECT  'FeeBasis'                         AS Category, Value, DisplaySequence, Active FROM FeeBasis UNION ALL
SELECT  'FeeType'                          AS Category, Value, DisplaySequence, Active FROM FeeType UNION ALL
SELECT  'FirmCategory'                     AS Category, Value, DisplaySequence, Active FROM FirmCategory UNION ALL
SELECT  'FormOfGovernment'                 AS Category, Value, DisplaySequence, Active FROM FormOfGovernment UNION ALL
SELECT  'FundingSourceType'                AS Category, Value, DisplaySequence, Active FROM FundingSourceType UNION ALL
SELECT  'GoverningBoard'                   AS Category, Value, DisplaySequence, Active FROM GoverningBoard UNION ALL
SELECT  'InitialOfferingDocument'          AS Category, Value, DisplaySequence, Active FROM InitialOfferingDocument UNION ALL
SELECT  'InterestCalcMethod'               AS Category, Value, DisplaySequence, Active FROM InterestCalcMethod UNION ALL
SELECT  'InterestPaymentFreq'              AS Category, Value, DisplaySequence, Active FROM InterestPaymentFreq UNION ALL
SELECT  'InterestType'                     AS Category, Value, DisplaySequence, Active FROM InterestType UNION ALL
SELECT  'InternetBiddingType'              AS Category, Value, DisplaySequence, Active FROM InternetBiddingType UNION ALL
SELECT  'IssueShortName'                   AS Category, Value, DisplaySequence, Active FROM IssueShortName UNION ALL
SELECT  'IssueStatus'                      AS Category, Value, DisplaySequence, Active FROM IssueStatus UNION ALL
SELECT  'IssueType'                        AS Category, Value, DisplaySequence, Active FROM IssueType UNION ALL
SELECT  'JobFunction'                      AS Category, Value, DisplaySequence, Active FROM JobFunction UNION ALL
SELECT  'MailingType'                      AS Category, Value, DisplaySequence, Active FROM MailingType UNION ALL
SELECT  'MeetingPurpose'                   AS Category, Value, DisplaySequence, Active FROM MeetingPurpose UNION ALL
SELECT  'MeetingType'                      AS Category, Value, DisplaySequence, Active FROM MeetingType UNION ALL
SELECT  'MethodOfSale'                     AS Category, Value, DisplaySequence, Active FROM MethodOfSale UNION ALL
SELECT  'MSA'                              AS Category, Value, DisplaySequence, Active FROM MSA UNION ALL
SELECT  'PaymentMethod'                    AS Category, Value, DisplaySequence, Active FROM PaymentMethod UNION ALL
SELECT  'PaymentType'                      AS Category, Value, DisplaySequence, Active FROM PaymentType UNION ALL
SELECT  'RatingType'                       AS Category, Value, DisplaySequence, Active FROM RatingType UNION ALL
SELECT  'RefundType'                       AS Category, Value, DisplaySequence, Active FROM RefundType UNION ALL
SELECT  'SecurityType'                     AS Category, Value, DisplaySequence, Active FROM SecurityType UNION ALL
SELECT  'ServiceCategory'                  AS Category, Value, DisplaySequence, Active FROM ServiceCategory UNION ALL
SELECT  'UnusedChoice'                     AS Category, Value, DisplaySequence, Active FROM UnusedChoice UNION ALL 
SELECT  'StaticList -> ' + lc.CategoryName AS Category, DisplayValue AS Value, DisplaySequence, sl.Active
  FROM  dbo.StaticList sl 
  JOIN  dbo.ListCategory lc on lc.ListCategoryID = sl.ListCategoryID ;
