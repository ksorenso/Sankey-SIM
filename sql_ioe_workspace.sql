USE [ioeDs]
GO

/*
 *	Requires JSON.sql
 *    https://www.simple-talk.com/sql/t-sql-programming/producing-json-documents-from-sql-server-queries-via-tsql/
 *
 *	1. Run this script
 *	2. Take the output @MyHierarchy
 *	3. Validate here http://jsonlint.com/
 *  4. Incorporate into: F:\Data\www\books\d3-tips-n-tricks\simple-tree-from-flat-kls.html
 *  5. Start Python on F:\Data
 *  6. > python -m SimpleHTTPServer 8888 &.
 *  7. http://localhost:8888/
 */

DECLARE @links TABLE ( 
	[source] NVARCHAR(100),
	[target] NVARCHAR(100),
	[value] NVARCHAR(25)
)

DECLARE @nodes TABLE (
	[name] NVARCHAR(100)
)

INSERT INTO @links
        ( [source], [target], [value] )
SELECT 'PSS Pipeline', 'Qlikview Pipeline', '2.0'
UNION
SELECT 'PSS Pipeline', 'Forecast', '1.0'
UNION
SELECT 'Judgment', 'Forecast', '1.0'
UNION
SELECT 'TMS Bookings',	'Plan Bookings', '6' 
UNION
SELECT 'Plan Bookings',	'Compensation', '6' 
UNION
SELECT 'Plans Scrubbed', 'Compensation', '0.2'  
UNION
SELECT 'Plan Elements', 'Compensation', '0.2'  
UNION
SELECT 'TMS Nodes', 'Compensation', '0.2' 
UNION
SELECT 'Share Nodes', 'Compensation', '0.2' 
UNION
SELECT 'Compensation', 'Fcst Bookings', '1.0'
UNION
SELECT 'Fcst Bookings', 'Forecast', '1.0'
UNION
SELECT 'Forecast', 'IoE Results', '1.0'
UNION
SELECT 'Fcst Bookings', 'Qlikview Bookings', '1.0'
UNION
SELECT 'Compensation', 'Qlikview Bookings', '1.0'
UNION
SELECT 'Compensation',	'Stack Ranking', '1.0'
UNION
SELECT 'Service Bookings', 'Plan Bookings', '1.0'
UNION
SELECT 'ASR Bookings', 'Plan Bookings', '1.0'
UNION
SELECT 'S+CC & S&E', 'Plan Bookings', '1.0'
UNION
SELECT 'Fcst Bookings', 'Forecast', '1.0'
UNION
SELECT 'Hierarchy', 'Qlikview Pipeline', '0.2'
UNION
SELECT 'Hierarchy', 'Compensation', '0.2'



INSERT INTO @nodes
        ( name )
SELECT DISTINCT [name]
FROM (
SELECT [source] [name] FROM @links
UNION SELECT [target] FROM @links
)X

DECLARE @SankeyNodes NVARCHAR(MAX)
DECLARE @SankeyLinks NVARCHAR(MAX)
DECLARE @MyNodes Hierarchy
INSERT  INTO @MyNodes
        SELECT  *
        FROM    dbo.PARSEXML(
--your SQL Goes here --->
                             ( SELECT  name
                               FROM    @nodes
--you add this magic spell, making it XML, and giving a name for the 'list' of rows and the root
                             FOR
                               XML PATH('nodes') ,
                                   ROOT('nodes')
-- end of SQL	 
                             ))


SELECT @SankeyNodes = dbo.ToJSON(@MyNodes)
SELECT @SankeyNodes = RIGHT(@SankeyNodes, LEN(@SankeyNodes) - 4)


DECLARE @MyLinks Hierarchy
INSERT  INTO @MyLinks
        SELECT  *
        FROM    dbo.PARSEXML(
--your SQL Goes here --->
                             ( SELECT   
                                        [source],
     [target],
     [value]
                               FROM     @links
--you add this magic spell, making it XML, and giving a name for the 'list' of rows and the root
                             FOR
                               XML PATH('links') ,
                                   ROOT('links')
-- end of SQL	 
                             ))
SELECT @SankeyLinks = dbo.ToJSON(@MyLinks)
SELECT @SankeyLinks = LEFT(@SankeyLinks, LEN(@SankeyLinks) - 4) 

SELECT  @SankeyLinks  + ', ' + @SankeyNodes
