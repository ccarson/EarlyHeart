/*
CREATE VIEW [v_Projects]
AS
SELECT
    ProjectID,
    ClientID,
    ProjectName,
    convert(varchar, prj.ProjectStatusEffDate, 101) AS StatusEffectiveDate,
    prj.LastUpdateDate,
    prj.LastUpdateID,
    sl.DisplayValue                  AS ServiceCategory,
    sla.DisplayValue                 AS ProjectStatus,
    prj.ServiceID,
    svcs.ServiceCategory             AS ServiceTableCategory,
    svcs.ServiceName                 AS ServiceName,
    isnull(prj.PrimaryFA, 0)         as PrimaryFA,
    isnull(prj.SecondaryFA, 0)       as SecondaryFA,
    ee.FirstName + ' ' + ee.LastName AS PrimaryFA_Name,
    ee2.FirstName + ' ' + ee2.LastName AS SecondaryFA_Name

  From Projects prj
    Left JOIN staticlists sl on sl.ListCategory = 'ServiceCategory'
        AND sl.ListID = prj.ServiceCategoryID
    Left JOIN staticlists sla on sla.ListCategory = 'ProjectStatus'
        AND sla.ListID = prj.ProjectStatus
    Left JOIN edata..[Services] svcs on svcs.serviceID = prj.ServiceID
    Left JOIN edata..Ehlers ee on ee.ID = prj.PrimaryFA
    Left JOIN edata..Ehlers ee2 on ee2.ID = prj.SecondaryFA
*/
