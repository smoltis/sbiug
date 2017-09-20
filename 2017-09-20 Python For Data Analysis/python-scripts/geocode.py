'''
Written by Stan Smoltis for Sydney Business Intelligence User Group
'''
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

get_coordinates("Australia, Sydney")

