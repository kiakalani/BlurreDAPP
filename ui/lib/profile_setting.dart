import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  // For storing up to 4 images
  final List<Uint8List?> _imageBytesList = List.filled(4, null);
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
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize profile details 
    _fetchProfileSettings();
  }

  void _fetchProfileSettings() {
    Authorization().getRequest("/profile/").then((value) {
      print(value);
      final responseBody = json.decode(value.toString());
      if (responseBody['profile'] != null) {
            final String picture1 = responseBody['profile']['picture1'] ?? '';
            final String picture2 = responseBody['profile']['picture2'] ?? '';
            final String picture3 = responseBody['profile']['picture3'] ?? '';
            final String picture4 = responseBody['profile']['picture4'] ?? '';
            final String? bio = responseBody['profile']['bio'];
            String height = '';
            if (responseBody['profile']['height'] != null) {
              height = responseBody['profile']['height'].toString();
            }
            final String? gender = responseBody['profile']['gender'];
            final String? sexOrientation = responseBody['profile']['orientation'];
            final String? lookingFor = responseBody['profile']['looking_for'];
            final String? exercise = responseBody['profile']['exercise'];
            final String? starSign = responseBody['profile']['star_sign'];
            final String? drinking = responseBody['profile']['drinking'];
            final String? smoking = responseBody['profile']['smoking'];
            final String? religion = responseBody['profile']['religion'];
            setState(() {
              _imageBytesList[0] = picture1 == '' ? null : base64Decode(picture1);
              _imageBytesList[1] = picture2 == '' ? null : base64Decode(picture2);
              _imageBytesList[2] = picture3 == '' ? null : base64Decode(picture3);
              _imageBytesList[3] = picture4 == '' ? null : base64Decode(picture4);
              _bioController.text = bio!;
              _heightController.text = height;
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

  // pick image from gallery
  Future<void> _pickImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytesList[index] = imageBytes; // Update the specific image in the list
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
    double gridSpacing = 10; 
    // the size for each square
    double squareSize = (fieldWidth - gridSpacing) / 2;
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
                  SizedBox(
                    width: fieldWidth,
                    child: GridView.builder(
                      shrinkWrap: true,
                      // disable GridView's own scrolling
                      physics: const NeverScrollableScrollPhysics(), 
                      itemCount: 4,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 squares in a row
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        childAspectRatio: 1,                      
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => _pickImage(index),
                            child: Container(
                              width: squareSize,
                              height: squareSize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _imageBytesList[index] == null ? Colors.grey : null,
                                image: _imageBytesList[index] != null
                                    ? DecorationImage(
                                        image: MemoryImage(_imageBytesList[index]!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
        
                              ),
                              child: _imageBytesList[index] == null
                                ? const Icon(Icons.add, color: Colors.white)
                                : null,
                            ),
                          );
                        },
                      ),
                    ),

                  // Bio field
                  SizedBox(
                    width: fieldWidth,
                    child: TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      maxLines: null, // Allows the input to expand as much as needed
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Height field
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
                      value: _gender,
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
                      value: _sexOrientation,
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
                      value: _lookingFor,
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
                      value: _exercise,
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
                      value: _starSign,
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
                      value: _drinking,
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
                      value: _smoking,
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
                      value: _religion,
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
                          'bio': _bioController.text,
                          'star_sign': _starSign,
                          'exercise': _exercise,
                          'drinking': _drinking,
                          'smoking': _smoking,
                          'religion': _religion,
                          'picture1': _imageBytesList[0] != null ? base64.encode(_imageBytesList[0]!) : null,
                          'picture2': _imageBytesList[1] != null ? base64.encode(_imageBytesList[1]!) : null,
                          'picture3': _imageBytesList[2] != null ? base64.encode(_imageBytesList[2]!) : null,
                          'picture4': _imageBytesList[3] != null ? base64.encode(_imageBytesList[3]!) : null,
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
