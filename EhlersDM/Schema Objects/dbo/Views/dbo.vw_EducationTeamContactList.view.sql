CREATE VIEW dbo.vw_EducationTeamContactList
AS

    SELECT  TOP (10000000) c1.FirstName, c1.LastName, c1.Email, c.ClientName, c.SchoolDistrictNumber, a.State, ISNULL(ee.FirstName + ' ' + ee.LastName,'') AS FA
      FROM  dbo.Client          AS c
INNER JOIN  dbo.ClientContacts  AS cc ON c.ClientID = cc.ClientID
INNER JOIN  dbo.Contact         AS c1 ON cc.ContactID = c1.ContactID
 LEFT JOIN  dbo.ClientAddresses ca ON c.ClientID = ca.ClientID AND ca.AddressTypeID = 3
 LEFT JOIN  dbo.Address a ON ca.AddressID = a.AddressID 
 LEFT JOIN  dbo.ClientAnalysts ca1 ON c.ClientID = ca1.ClientID AND ca1.Ordinal = 1 
 LEFT JOIN  dbo.EhlersEmployeeJobGroups eejg ON ca1.EhlersEmployeeJobGroupsID = eejg.EhlersEmployeeJobGroupsID AND eejg.EhlersJobGroupID = 3
 LEFT JOIN  dbo.EhlersEmployee ee ON eejg.EhlersEmployeeID = ee.EhlersEmployeeID
     WHERE  c1.LastName <> '' AND c1.FirstName <> '' AND c.EhlersJobTeamID = 2
     ORDER  BY c1.LastName, c1.FirstName ;
