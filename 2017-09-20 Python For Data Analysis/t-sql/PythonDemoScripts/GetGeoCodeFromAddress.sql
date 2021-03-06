USE [PythonDemo]
GO


CREATE PROCEDURE [dbo].[GetGeoCodeFromAddress]
(
	@Address varchar(1000) = NULL
)
AS
BEGIN

execute sp_execute_external_script 
@language = N'Python',
@script = N'
from urllib import parse, request
import json

googleGeocodeUrl = "http://maps.googleapis.com/maps/api/geocode/json?"

def get_coordinates(query, from_sensor=False):
	query = query.encode("utf-8")
	params = {
		"address": query,
		"sensor": "true" if from_sensor else "false"
	}
	url = googleGeocodeUrl + parse.urlencode(params)
	with request.urlopen(url) as json_response:
		response = json.loads(json_response.read().decode())
	if response["results"]:
		location = response["results"][0]["geometry"]["location"]
		latitude, longitude = location["lat"], location["lng"]
		print (query, latitude, longitude)
	else:
		latitude, longitude = None, None
		print (query, "<no results>")
	return query, latitude, longitude

result = get_coordinates(address)
OutputDataSet = pandas.DataFrame([result],columns=["address","lat","lon"])
', 
@params = N'@address varchar(1000)',
@address=@Address
with result sets (("address" varchar(1000),"lat" decimal(9,6) null, "lon" decimal(9,6) null))

END
GO

/*
EXEC [dbo].[GetGeoCodeFromAddress] N'WALKERVALE'
*/


CREATE PROCEDURE dbo.spRefreshStoreCoord
AS
BEGIN


DECLARE @temp TABLE(StoreName varchar(50) null, lat decimal(9,6) null, lon decimal(9,6) null)

DECLARE store_coord_cur CURSOR
READ_ONLY
FOR SELECT [StoreName] FROM [dbo].[Stores]

DECLARE @name varchar(40)
OPEN store_coord_cur

FETCH NEXT FROM store_coord_cur INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		INSERT @temp
		EXEC [dbo].[GetGeoCodeFromAddress] @name
	END
	FETCH NEXT FROM store_coord_cur INTO @name
END

CLOSE store_coord_cur
DEALLOCATE store_coord_cur

UPDATE s
SET lat = t.lat, lon = t.lon
FROM [dbo].[Stores] s
JOIN @temp t ON s.StoreName=t.StoreName
	
END
GO


/*
EXEC dbo.spRefreshStoreCoord
SELECT * FROM [dbo].[Stores]
*/