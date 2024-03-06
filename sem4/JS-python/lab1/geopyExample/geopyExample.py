from geopy.geocoders import Nominatim

geolocator = Nominatim(user_agent="geoapiExercises")
location = geolocator.geocode("Curie-Skłodowskiej 51, Wrocław")
print((location.latitude, location.longitude))

location = geolocator.reverse("51.109934, 17.0564494")
print(location.address)

