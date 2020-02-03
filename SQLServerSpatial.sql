SELECT * FROM sys.spatial_reference_systems;
GO

SELECT spatial_reference_id as SRID, unit_of_measure, well_known_text
FROM sys.spatial_reference_systems ORDER BY SRID;
GO

select geometry::Parse('POINT(90 100)');
select geometry::Parse('POINT(90 100)').ToString();
GO

select geometry::Point(90, 100, 0);  -- For the geometry type, SRID = 0 declares these coordinates to have no relation to any spatial reference system...
select geography::Point(90, 100, 0); -- ... but for geography, this is an error:
-- A .NET Framework error occurred during execution of user-defined routine or aggregate "geography": 
-- System.ArgumentException: 24204: The spatial reference identifier (SRID) is not valid. The specified SRID must match one of the supported SRIDs displayed in the sys.spatial_reference_systems catalog view.
-- System.ArgumentException: 
--    at Microsoft.SqlServer.Types.SqlGeography.set_Srid(Int32 value)
--    at Microsoft.SqlServer.Types.SqlGeography..ctor(GeoData g, Int32 srid)
--    at Microsoft.SqlServer.Types.SqlGeography.Point(Double latitude, Double longitude, Int32 srid)
select geometry::Point(90, 100, 0).ToString();
GO

select geography::Point(51, 1, 4326);
select geography::Point(51, 1, 4326).ToString();
GO

USE [SQLR]
GO

--create table geopoints (
--	location geography
--);
--insert into geopoints values
--	(geography::Point(51, 1, 4326));
--GO

select * from geopoints;
GO

select location.ToString() from geopoints;
GO

select location.Lat, location.Long from geopoints;
GO

update geopoints set location.Lat = 50; -- Error:
-- Could not assign to property 'Lat' for type 'Microsoft.SqlServer.Types.SqlGeography' in assembly 'Microsoft.SqlServer.Types' because it is read only
GO

update geopoints set location.STSrid = 0; -- Error:
-- A .NET Framework error occurred during execution of user-defined routine or aggregate "geography": 
-- System.ArgumentException: 24204: The spatial reference identifier (SRID) is not valid. The specified SRID must match one of the supported SRIDs displayed in the sys.spatial_reference_systems catalog view.
-- System.ArgumentException: 
--    at Microsoft.SqlServer.Types.SqlGeography.set_Srid(Int32 value)
--    at Microsoft.SqlServer.Types.SqlGeography.set_STSrid(SqlInt32 value)
GO

update geopoints set location.STSrid = 4269;
GO

select 
	location.Lat as Latitude, 
	location.Long as Longitude, 
	location.STSrid as SRID, 
	location.ToString() as WKT 
	from geopoints;
GO

DECLARE @point geography = geography::Point(43.649210, -72.318590, 4326); -- SQL Server Point() takes LAT, then LONG (then SRID)... reverse of OGC WKT spec
SELECT @point.ToString(); -- ToString() displays WKT_TYPE(LONG LAT [,...])
SELECT @point.STAsText(); -- OGC Methods display WKT_TYPE(LONG LAT [,...])
SELECT @point.Lat as Latitude, @point.Long as Longitude;
SELECT @point.STBuffer(5).ToString();
SELECT @point.STBuffer(5).STArea();
SELECT unit_of_measure
	FROM sys.spatial_reference_systems
	WHERE authorized_spatial_reference_id = @point.STSrid;
GO
