import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/find_locale.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui/main.dart';
import 'dart:convert';
import 'auth.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  ProfileSettingsPageState createState() => ProfileSettingsPageState();
}

class ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  // Selected option for profile settings
  String? _gender, _sexOrientation, _lookingFor, _exercise, _starSign, _drinking, _smoking, _religion;
  // Dropdown options for profile settings
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _orientations = ['Straight', 'Gay', 'Lesbian', 'Bisexual', 'Asexual', 'Other'];
  final List<String> _lookingFors = ['A relationship', 'Something casual', 'New friends', 'Not sure yet', 'Prefer not to say'];
  final List<String> _exercises = ['Everyday', 'Often', 'Sometimes', 'Never'];
  final List<String> _starSigns = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
  final List<String> _drinkings = ['Frequently', 'Socially', 'Rarely', 'Never'];
  final List<String> _smokings = ['Socially', 'Never', 'Regularly', 'Trying to quit']; 
  final List<String> _religions = ['None', 'Agnostic', 'Atheist', 'Buddhist', 'Catholic', 'Christian', 'Hindu', 'Jain', 'Jewish', 'Mormon', 'Latter-day Saint', 'Muslim', 'Zoroastrian', 'Sikh', 'Spiritual', 'Other', 'Prefer not to say'];
  final _heightController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      //String base64Encode(List<int> bytes) => base64.encode(bytes);
      print(base64.encode(imageBytes));
      setState(() {
        _imageBytes = imageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     Authorization().isLoggedIn().then((logged_in) => {
          if (!logged_in)
            {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HomePage()))
            }
        });
    double fieldWidth =
        MediaQuery.of(context).size.width * 0.3; // 30% of screen width
    if (kIsWeb) {
      fieldWidth = MediaQuery.of(context).size.width * 0.3;
    } else if (Platform.isIOS || Platform.isAndroid) {
      fieldWidth = MediaQuery.of(context).size.width * 0.8;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Upload photo field
                  if (_imageBytes != null)
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.memory(_imageBytes!),
                    ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Upload Photo'),
                  ),

                  // Height field
                  const SizedBox(height: 20),
                  SizedBox(
                    width: fieldWidth,
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Height (cm)'),
                      keyboardType: TextInputType.number, // Ensures numeric keyboard
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gender field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: _genders.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _gender = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sex Orientation field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Sex Orientation'),
                      items: _orientations.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _sexOrientation = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Looking for field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Looking for'),
                      items: _lookingFors.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _lookingFor = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Exercise field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Exercise'),
                      items: _exercises.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _exercise = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Star sign field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Star sign'),
                      items: _starSigns.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _starSign = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Drinking field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Drinking'),
                      items: _drinkings.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _drinking = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Smoking field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Smoking'),
                      items: _smokings.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _smoking = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Religion field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'Religion'),
                      items: _religions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _religion = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Authorization().postRequest('/profile/', {
                          'gender': _gender,
                          'orientation': _sexOrientation,
                          'looking_for': _lookingFor,
                          'height': _heightController.text,
                          'star_sign': _starSign,
                          'exercise': _exercise,
                          'drinking': _drinking,
                          'smoking': _smoking,
                          'religion': _religion,
                          'picture1': _imageBytes != null ? base64.encode(_imageBytes!) : null,
                        }).then((resp) => {
                          if (resp.statusCode == 200) {
                            // Successfully modified
                          }
                        });
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
