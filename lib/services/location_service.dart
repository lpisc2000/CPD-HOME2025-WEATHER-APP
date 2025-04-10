import 'package:geolocator/geolocator.dart';

//a service class to get the user current GPS location using the Geolocator package
class LocationService {
  //returns the current position (latitude and longitude) of the user
  Future<Position> getCurrentLocation() async {
    //check if location services are enabled and if permission is granted
    //if not, request permission from the user
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    //check the app current permission status to access location
    LocationPermission permission = await Geolocator.checkPermission();

    //if location services are not enabled or permission is denied, request permission
    if (!serviceEnabled || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    //fetch the current position of the user
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
