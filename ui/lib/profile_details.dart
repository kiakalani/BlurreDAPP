import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/auth.dart';
import 'dart:convert';
import 'package:ui/main.dart';


class ProfileDetailsPage extends StatefulWidget {
  final String currentUserId;

  const ProfileDetailsPage({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final List<Uint8List?> _imageBytesList = List.filled(4, null);

  // keys for profile details
  final List<String> _settingsKeys = [
    'name', 'age', 'bio', 'height', 'gender', 'orientation', 'looking_for',
    'exercise', 'star_sign', 'drinking', 'smoking', 'religion', 'distance'
  ];

  // map for profile deatils
  final Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    // Initialize settings keys
    _initSettings();
    // Initialize profile details
    _fetchProfileDetails();
  }

  // Initialize settings key to null
  void _initSettings() {
    for (var key in _settingsKeys) {
      _settings[key] = null;
    }
  }

  // fetch profile details from server
  void _fetchProfileDetails() {
    Authorization().postRequest(
        "/profile/details/", {"user_id": widget.currentUserId}).then((value) {
      final responseBody = json.decode(value.toString());

      if (responseBody['profile'] != null) {
        setState(() {
          // store fetched pictures to imageBytesList
          for (int i = 0; i < _imageBytesList.length; i++) {
            String? pic = responseBody['profile']['picture${i+1}'];
            if (pic != null) {
              _imageBytesList[i] = base64Decode(pic);
            }
          }
          // store fetched profile details to settings
          for (var key in _settings.keys) {
            if (responseBody['profile'][key] != null) {
              _settings[key] = responseBody['profile'][key].toString();
            }
          }
        });
      }
    });
  }

  // convert km to miles based on user's preference
  int _convertKmToMiles(int km) {
    const double milesPerKilometer = 0.621371;
    return km * milesPerKilometer.toInt();
  }

  // add profile details text field to list
  List<Widget> setSettingItems(){
    List<Widget> itemTextList = [];
    for (var key in _settings.keys) {
      if (key != 'name' && key != 'age' && key != 'distance' && key != 'bio') {
        itemTextList.add(
          Text(
            '${(key[0]).toUpperCase() + key.substring(1).replaceAll('_', ' ')}: ${_settings[key]?.toString() ?? 'N/A'}',
            style: const TextStyle(fontSize: 16),
          )
        );
      }
    }
    return itemTextList;
  }

  @override
  Widget build(BuildContext context) {
    Authorization().checkLogin(context);
    double fieldWidth = MyApp.getFieldWidth(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Details'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Profile picture field
              SizedBox(
                height: 300, 
                child: PageView.builder(
                  itemCount: _imageBytesList.length,
                  itemBuilder: (context, index) {
                    if (_imageBytesList[index] != null) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(_imageBytesList[index]!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    }
                    return null;
                  }
                ),
              ),
              const SizedBox(height: 20),

              // Name and age field
              Text(
                '${_settings['name'] ?? 'N/A'}, ${_settings['age']?.toString() ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
              ),

              // Distance field
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.location_on,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${_settings['distance']?.toString() ?? 'N/A'} km away',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              
              // Bio field
              SizedBox(
                width: fieldWidth,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _settings['bio'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18, color: Color.fromARGB(255, 35, 11, 220)),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),         
              const SizedBox(height: 10),

              // Profile details field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: setSettingItems(),
              ),
            ],
          ),
        ),
      );
  }
}
