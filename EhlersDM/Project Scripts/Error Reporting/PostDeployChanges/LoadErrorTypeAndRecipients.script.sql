/*
************************************************************************************************************************************
     Script:    LoadErrorTypeAndRecipients.script.sql
    Purpose:    Applies ContactID to the UpdatedBy field from Contacts

************************************************************************************************************************************
*/


    INSERT  Meta.ErrorType ( ErrorTypeID, Value, DisplaySequence, ModifiedDate, ModifiedUser )
    SELECT  1, 'SQL Server Error'       , 1, GETDATE(), 'conversion'    UNION ALL
    SELECT  2, 'Exception Report Error' , 2, GETDATE(), 'conversion' ;

    INSERT  Meta.ErrorTypeRecipient ( ErrorTypeID, RecipientEMail, ModifiedDate, ModifiedUser )
    SELECT  1, 'ccarson@ehlers-inc.com',  GETDATE(), 'conversion'    UNION ALL
    SELECT  1, 'MSchultz@ehlers-inc.com', GETDATE(), 'conversion'    UNION ALL
    SELECT  1, 'MKiemen@ehlers-inc.com',  GETDATE(), 'conversion'    UNION ALL
    SELECT  1, 'JReuter@ehlers-inc.com',  GETDATE(), 'conversion'    UNION ALL
    SELECT  2, 'ccarson@ehlers-inc.com',  GETDATE(), 'conversion'    UNION ALL
    SELECT  2, 'MSchultz@ehlers-inc.com', GETDATE(), 'conversion'    UNION ALL
    SELECT  2, 'MKiemen@ehlers-inc.com',  GETDATE(), 'conversion'    UNION ALL
    SELECT  2, 'dholmes@ehlers-inc.com',  GETDATE(), 'conversion' ;
