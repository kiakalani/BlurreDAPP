import 'package:location/location.dart';

class LocationService {
  Location location = Location();
  Future<bool> request_permission() async {
    return (await location.requestPermission()) == PermissionStatus.granted;
  }

  Future<LocationData> get_location() async {
    return await location.getLocation();
  }
}
