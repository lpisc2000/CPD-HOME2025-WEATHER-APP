import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  static const _weatherApiKey =
      'A2E5ZLW6SQ5S9868M6EKYJV9X'; // Visual Crossing key
  static const _googleApiKey =
      'AIzaSyBIdpvrhZcwEo9C6FLc_KSTN47LQLXVwyE'; // Google API key
  static const _weatherBaseUrl =
      'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline';

  // Get 10-day forecast by coordinates
  Future<Map<String, dynamic>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final now = DateTime.now();
    final tenDaysLater = now.add(const Duration(days: 9));
    final startDate = DateFormat('yyyy-MM-dd').format(now);
    final endDate = DateFormat('yyyy-MM-dd').format(tenDaysLater);

    final url =
        '$_weatherBaseUrl/$lat,$lon/$startDate/$endDate?unitGroup=metric&key=$_weatherApiKey';

    print('Fetching weather for coordinates: $lat, $lon');
    print('Weather API URL: $url');

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final cityName = await getCityNameFromCoordinates(lat, lon);
    print('📍 Location resolved as: $cityName');

    data['resolvedAddress'] = cityName;
    return data;
  }

  // Get 10-day forecast by city name
  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final now = DateTime.now();
    final tenDaysLater = now.add(const Duration(days: 9));
    final startDate = DateFormat('yyyy-MM-dd').format(now);
    final endDate = DateFormat('yyyy-MM-dd').format(tenDaysLater);

    final url =
        '$_weatherBaseUrl/$city/$startDate/$endDate?unitGroup=metric&key=$_weatherApiKey';

    print('Fetching weather for city: $city');
    print('Weather API URL: $url');

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    data['resolvedAddress'] = city;
    return data;
  }

  // Use Google Geocoding to get "City, Country" from lat/lon
  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$_googleApiKey';

    print('Google Geocoding URL: $url');

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    print('Google Geocoding Response: ${jsonEncode(data)}');

    if (data['status'] == 'OK') {
      final results = data['results'];
      String? city;
      String? area;
      String? country;

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

      final finalName = area ?? city ?? results.first['formatted_address'];
      return country != null ? '$finalName, $country' : finalName;
    } else {
      print('Google Geocoding failed: ${data['status']}');
      return 'Unknown Location';
    }
  }
}
