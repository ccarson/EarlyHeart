CREATE FUNCTION dbo.tvf_TableCounts ()
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    dbo.tvf_TableCounts
Implemented:    Chris Carson ( not the author, see ABSTRACT )
    Purpose:    returns counts for all tables in database


    revisor     date            description
    --------    -----------     ----------------------
    ccarson     2012-10-19      Implemented

    query system catalogs for counts on all user tables in database

    Reference:
    http://blog.sqlauthority.com/2010/09/08/sql-server-find-row-count-in-table-find-largest-table-in-database-part-2/

************************************************************************************************************************************
*/
RETURN
  WITH  counts AS (
        SELECT  TOP 100 PERCENT
                TableName = sc.name +'.'+ ta.name
              , RowCnt    = SUM(pa.rows)
              , N         = ROW_NUMBER() OVER ( ORDER BY SUM(pa.rows) DESC )
          FROM  sys.tables      AS ta
    INNER JOIN  sys.partitions  AS pa
            ON  pa.OBJECT_ID = ta.OBJECT_ID
    INNER JOIN  sys.schemas     AS sc
            ON  ta.schema_ID = sc.schema_id
         WHERE  ta.is_ms_shipped = 0
                AND pa.index_ID IN (1,0)
      GROUP BY  sc.name,ta.name
      ORDER BY  3 )

SELECT  TableName, RowCnt, N FROM counts ;
