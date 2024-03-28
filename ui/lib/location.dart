import 'package:location/location.dart';
import 'package:ui/auth.dart';

class LocationService {
  Location location = Location();
  static LocationService? _loc;

  LocationService._internal();
  factory LocationService() {
    _loc ??= LocationService._internal();
    return _loc!;
  }

  Future<bool> request_permission() async {
    return (await location.requestPermission()) == PermissionStatus.granted;
  }

  Future<LocationData> get_location() async {
    return await location.getLocation();
  }

  void update_location() {
    request_permission().then((value) => {
          if (value)
            {
              get_location().then((loc) => {
                    Authorization().postRequest('/profile/location/',
                        {'latitude': loc.latitude, 'longitude': loc.longitude})
                  })
            }
        });
  }
}