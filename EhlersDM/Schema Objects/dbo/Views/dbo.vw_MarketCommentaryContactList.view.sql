CREATE VIEW [dbo].[vw_MarketCommentaryContactList]
AS
SELECT     TOP 100 percent c1.FirstName, c1.LastName, c1.Email, c.ClientName
FROM         dbo.Client AS c INNER JOIN
                      dbo.ClientContacts AS cc ON c.ClientID = cc.ClientID INNER JOIN
                      dbo.Contact AS c1 ON cc.ContactID = c1.ContactID INNER JOIN
                      dbo.ContactMailings AS cm ON c1.ContactID = cm.ContactID
WHERE     (cm.MailingTypeID = 11) AND (cm.OptOut = 0) AND (c1.LastName <> '') AND (c1.FirstName <> '')
ORDER BY c1.LastName, c1.FirstName ;
