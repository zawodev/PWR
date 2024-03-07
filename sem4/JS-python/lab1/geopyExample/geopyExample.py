# from geopy.geocoders import Nominatim
from geopy.geocoders import Photon
from geopy.distance import geodesic


geolocator = Photon(user_agent="geoapiExercises")


# Geokodowanie
location = geolocator.geocode("Curie-Skłodowskiej 51, Wrocław")
print((location.latitude, location.longitude))


# Odwrotne geokodowanie
location = geolocator.reverse("51.109934, 17.0564494")
print(location.address)


# Obliczanie odległości
start = (52.2296756, 21.0122287)
end = (50.0646501, 19.9449799)
start_address = geolocator.reverse(start)
end_address = geolocator.reverse(end)
distance = geodesic(start, end).kilometers
print(f"Distance from {start_address} to {end_address}: {distance} km")

