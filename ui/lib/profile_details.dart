import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/auth.dart';
import 'dart:convert';

class ProfileDetailsPage extends StatefulWidget {
  final String currentUserId;

  const ProfileDetailsPage({
    required this.currentUserId,
  });

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

 class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  Uint8List? _profilePicture;
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

  @override
  void initState() {
    super.initState();
    // Initialize profile details 
    _fetchProfileDetails();
  }

  void _fetchProfileDetails() {
    Authorization().postRequest("/profile/details/", {
      "user_id": widget.currentUserId
    }).then((value) {
      final responseBody = json.decode(value.toString()); 
      if (responseBody['profile'] != null && 
          responseBody['profile']['picture1'] != null &&
          responseBody['profile']['name'] != null &&
          responseBody['profile']['age'] != null &&
          responseBody['profile']['bio'] != null &&
          responseBody['profile']['height'] != null &&
          responseBody['profile']['gender'] != null &&
          responseBody['profile']['orientation'] != null &&
          responseBody['profile']['looking_for'] != null &&
          responseBody['profile']['exercise'] != null &&
          responseBody['profile']['star_sign'] != null &&
          responseBody['profile']['drinking'] != null &&
          responseBody['profile']['smoking'] != null &&
          responseBody['profile']['religion'] != null 
          ) {
            final String base64Image = responseBody['profile']['picture1'];
            final String name = responseBody['profile']['name'];
            final int age = responseBody['profile']['age'];
            final String bio = responseBody['profile']['bio'];
            final int height = responseBody['profile']['height'];
            final String gender = responseBody['profile']['gender'];
            final String sexOrientation = responseBody['profile']['orientation'];
            final String lookingFor = responseBody['profile']['looking_for'];
            final String exercise = responseBody['profile']['exercise'];
            final String starSign = responseBody['profile']['star_sign'];
            final String drinking = responseBody['profile']['drinking'];
            final String smoking = responseBody['profile']['smoking'];
            final String religion = responseBody['profile']['religion'];
            setState(() {
              _profilePicture = base64Decode(base64Image);
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
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
      ),
      body: SingleChildScrollView( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: <Widget>[
            if (_profilePicture != null)
                Container(
                  width: MediaQuery.of(context).size.width * 0.8, 
                  height: MediaQuery.of(context).size.height * 0.4, 
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(_profilePicture!),
                      fit: BoxFit.contain, 
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            Center( 
              child: Text(
                '${_name ?? 'N/A'}, ${_age?.toString() ?? 'N/A'}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
                _bio ?? 'N/A',
                style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 35, 11, 220)),
                textAlign: TextAlign.center,
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