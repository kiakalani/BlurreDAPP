import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:ui/main.dart';


class ProfileDetailsPage extends StatefulWidget {
  final String currentUserId;

  const ProfileDetailsPage({
    required this.currentUserId,
  });

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final List<Uint8List?> _imageBytesList = List.filled(4, null);
  String? _name;
  int? _age;
  String? _bio;
  int? _height;
  String? _gender;
  String? _sexOrientation;
  String? _lookingFor;
  String? _exercise;
  String? _starSign;
  String? _drinking;
  String? _smoking;
  String? _religion;
  int? _distance;

  @override
  void initState() {
    super.initState();
    // Initialize profile details
    _fetchProfileDetails();
  }

  void _fetchProfileDetails() {
    Authorization().postRequest(
        "/profile/details/", {"user_id": widget.currentUserId}).then((value) {
      final responseBody = json.decode(value.toString());
      if (responseBody['profile'] != null) {
        print(responseBody);
        final String picture1 = responseBody['profile']['picture1'] ?? '';
        final String picture2 = responseBody['profile']['picture2'] ?? '';
        final String picture3 = responseBody['profile']['picture3'] ?? '';
        final String picture4 = responseBody['profile']['picture4'] ?? '';
        final String? name = responseBody['profile']['name'];
        final int? age = responseBody['profile']['age'];
        final String? bio = responseBody['profile']['bio'];
        final int? height = responseBody['profile']['height'];
        final String? gender = responseBody['profile']['gender'];
        final String? sexOrientation = responseBody['profile']['orientation'];
        final String? lookingFor = responseBody['profile']['looking_for'];
        final String? exercise = responseBody['profile']['exercise'];
        final String? starSign = responseBody['profile']['star_sign'];
        final String? drinking = responseBody['profile']['drinking'];
        final String? smoking = responseBody['profile']['smoking'];
        final String? religion = responseBody['profile']['religion'];
        final int? distance = responseBody['profile']['distance'];
        setState(() {
          _imageBytesList[0] = picture1 == '' ? null : base64Decode(picture1);
          _imageBytesList[1] = picture2 == '' ? null : base64Decode(picture2);
          _imageBytesList[2] = picture3 == '' ? null : base64Decode(picture3);
          _imageBytesList[3] = picture4 == '' ? null : base64Decode(picture4);
          _name = name;
          _age = age;
          _bio = bio;
          _height = height;
          _gender = gender;
          _sexOrientation = sexOrientation;
          _lookingFor = lookingFor;
          _exercise = exercise;
          _starSign = starSign;
          _drinking = drinking;
          _smoking = smoking;
          _religion = religion;
          _distance = distance;
        });
      }
    });
  }

  int _convertKmToMiles(int km) {
    const double milesPerKilometer = 0.621371;
    double miles = km * milesPerKilometer;
    return miles.toInt();
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
                }),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        '${_name ?? 'N/A'}, ${_age?.toString() ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.location_on,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${_distance?.toString() ?? 'N/A'} km away',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  )
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _bio ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18, color: Color.fromARGB(255, 35, 11, 220)),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),         
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Height: ${_height?.toString() ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Gender: ${_gender ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Sexual Orientation: ${_sexOrientation ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Looking for: ${_lookingFor ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Exercise: ${_exercise ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Star Sign: ${_starSign ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Drinks: ${_drinking ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Smokes: ${_smoking ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Religion: ${_religion ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
