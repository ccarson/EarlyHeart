CREATE VIEW dbo.vw_EducationTeamContactList
AS
SELECT     TOP 100 percent 
            c1.FirstName, c1.LastName, c1.Email, c.ClientName, c.SchoolDistrictNumber
FROM         dbo.Client AS c INNER JOIN
                      dbo.ClientContacts AS cc ON c.ClientID = cc.ClientID INNER JOIN
                      dbo.Contact AS c1 ON cc.ContactID = c1.ContactID
WHERE     (c1.LastName <> '') AND (c1.FirstName <> '') AND (c.EhlersJobTeamID = 2)
ORDER BY c1.LastName, c1.FirstName ;

