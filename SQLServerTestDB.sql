USE [TestDB]
GO

INSERT INTO location 
(PersonId, Location) VALUES 
(101,geography::Point(43.649210, -72.318590, 4326));

SELECT TOP (10) [LocatonId]
      ,[PersonId]
      ,[Location].ToString()
  FROM [TestDB].[dbo].[location];

SELECT TOP (10) [LocatonId]
      ,[PersonId]
      ,[Location].Long as Longitude
      ,[Location].Lat as Latitude
	  ,[Location].STDistance(geography::Point(43.649210, -72.318590, 4326)) as Distance_From_WRJ
  FROM location
  ORDER BY Distance_From_WRJ;

UPDATE location
SET Location = geography::Point(43.461490, -72.426830, 4326)
WHERE PersonId = 101;

SELECT [LocatonId]
      ,[PersonId]
      ,[Location].Long as Longitude
      ,[Location].Lat as Latitude
	  ,[Location].STDistance(geography::Point(43.649210, -72.318590, 4326)) as Distance_From_WRJ
	  ,unit_of_measure as Distance_Unit
  FROM location, sys.spatial_reference_systems
  WHERE authorized_spatial_reference_id = [Location].STSrid
  ORDER BY Distance_From_WRJ;
