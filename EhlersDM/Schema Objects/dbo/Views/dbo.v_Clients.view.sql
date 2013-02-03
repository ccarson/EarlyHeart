/*
CREATE VIEW [dbo].[v_Clients]
AS
SELECT
    cl.*,
    ClientName + ' | ' + isnull(sl4.DisplayValue,'') + ' | ' + ClientState as ClientDescriptiveName , -- sl4.DisplayValue + ClientState as ClientDescriptiveName,
    ISNULL(OriginatingFA1,-1) as Originating_FA1,
    ISNULL(OriginatingFA2,-1) as Originating_FA2,
    ISNULL(ClientFA1,-1) as Client_FA1,
    ISNULL(ClientFA2,-1) as Client_FA2,
    ISNULL(ClientFA3,-1) as Client_FA3,
    sla.DisplayValue AS ClientStatusExpand,
    sl3.DisplayValue as AcctClassExpand,
    sl2.DisplayValue AS TypeJurisdictionExpand
    --sla.*
  FROM Clients cl
    INNER JOIN staticlists sl on sl.ListCategory = 'EntityType'
        AND (sl.ListValue = 'C' or sl.DisplayValue = 'Client')
    Left JOIN staticlists sla on sla.ListCategory = 'ClientStatus'
        AND sla.ListID = cl.ClientStatus
    Left JOIN staticlists sl2 on sl2.ListCategory = 'TypeJurisdiction'
        AND sl2.ListID = cl.TypeJurisdiction
    Left JOIN staticlists sl3 on sl3.ListCategory = 'AcctClass'
        AND sl3.ListID = cl.AcctngClass
    Left JOIN staticlists sl4 on sl4.ListCategory = 'ClientPrefix'
        AND sl4.ListID = cl.ClientPrefix

    --LEFT JOIN addresstocontact a2c on a2c.entityID = cl.ClientID
    --    AND a2c.entitytype = sl.ListID
    --    AND getdate() between a2c.AddressLinkEffDate AND a2c.AddressLinkEndDate
    --    AND a2c.AddressLinkStatus = 'A'
*/
