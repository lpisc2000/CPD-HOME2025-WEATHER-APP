import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  //API key for visual corssing weather API
  static const _weatherApiKey = 'A2E5ZLW6SQ5S9868M6EKYJV9X';
  //API key for Google Geocoding API
  static const _googleApiKey = 'AIzaSyBIdpvrhZcwEo9C6FLc_KSTN47LQLXVwyE';
  //API base URL for visual crossing weather API
  static const _weatherBaseUrl =
      'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline';

  // fetches the 10-day weather forecast for a given location (latitude and longitude)
  Future<Map<String, dynamic>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final now = DateTime.now();
    final tenDaysLater = now.add(const Duration(days: 9));
    final startDate = DateFormat('yyyy-MM-dd').format(now);
    final endDate = DateFormat('yyyy-MM-dd').format(tenDaysLater);

    //construct the API URL using the provided latitude and longitude
    final url =
        '$_weatherBaseUrl/$lat,$lon/$startDate/$endDate?unitGroup=metric&key=$_weatherApiKey';

    //make the HTTP GET request to the weather API
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body); //parse the respone JSON

    //get the human readable city name from the coordinates using Google Geocoding API
    final cityName = await getCityNameFromCoordinates(lat, lon);

    //overwrite the default resolved address with the proper city name
    data['resolvedAddress'] = cityName;
    return data;
  }

  // fetched the 10-day weather forecast for a given city name
  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final now = DateTime.now();
    final tenDaysLater = now.add(const Duration(days: 9));
    final startDate = DateFormat('yyyy-MM-dd').format(now);
    final endDate = DateFormat('yyyy-MM-dd').format(tenDaysLater);

    //construct the API URL using the provided city name
    final url =
        '$_weatherBaseUrl/$city/$startDate/$endDate?unitGroup=metric&key=$_weatherApiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    //directly use the input city name as the resolved address
    data['resolvedAddress'] = city;
    return data;
  }

  // converts coordinates (latitude and longitude) to a human-readable city name using Google Geocoding API
  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    // construct the google geocoding API URL using the provided latitude and longitude
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$_googleApiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      final results = data['results'];
      String? city;
      String? area;
      String? country;

      //loop through the address components to find the city, area, and country names
      for (var result in results) {
        for (var component in result['address_components']) {
          final types = List<String>.from(component['types']);

          if (types.contains('sublocality') && area == null) {
            area = component['long_name'];
          }
          if (types.contains('locality') && city == null) {
            city = component['long_name'];
          }
          if (types.contains('country') && country == null) {
            country = component['long_name'];
          }
        }
      }

      //prioritize the area, city, and country names for display
      final finalName = area ?? city ?? results.first['formatted_address'];
      return country != null ? '$finalName, $country' : finalName;
    } else {
      print('Google Geocoding failed: ${data['status']}');
      return 'Unknown Location';
    }
  }
}
