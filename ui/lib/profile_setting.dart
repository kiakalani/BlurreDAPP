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
  // Valid dropdown optoins for profile settings
  final Map<String, List<String>> validSettings = {
    'gender': ['Male', 'Female', 'Other'],
    'orientation': ['Straight', 'Gay', 'Lesbian', 'Bisexual', 'Asexual', 'Other'],
    'looking_for': ['A relationship', 'Something casual', 'New friends', 'Not sure yet', 'Prefer not to say'],
    'exercise': ['Everyday', 'Often', 'Sometimes', 'Never'],
    'star_sign': ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'],
    'drinking': ['Frequently', 'Socially', 'Rarely', 'Never'],
    'smoking': ['Socially', 'Never', 'Regularly', 'Trying to quit'],
    'religion': ['None', 'Agnostic', 'Atheist', 'Buddhist', 'Catholic', 'Christian', 'Hindu', 'Jain', 'Jewish', 'Mormon', 'Latter-day Saint', 'Muslim', 'Zoroastrian', 'Sikh', 'Spiritual', 'Other', 'Prefer not to say'],
    'height': [for (int i = 110; i < 221; i++) i.toString()]
  };
  // Selected option for profile settings
  Map<String, String?> settings = {};
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize settings keys
    _initSettings();
    // Initialize profile details 
    _fetchProfileSettings();
  }

  // Initialize settings key to null
  void _initSettings() {
    for (var key in validSettings.keys) {
      settings[key] = null;
    }
  }

  // fetch profile settings from server
  void _fetchProfileSettings() {
    Authorization().getRequest("/profile/").then((value) {
      final responseBody = json.decode(value.toString());
      if (responseBody['profile'] != null) {
        setState(() {
          // store fetched profile settings to settings
          for (var key in settings.keys) {
            if (responseBody['profile'][key] != null) {
              settings[key] = responseBody['profile'][key].toString();
            }
          }
          // set bio field text
          if (responseBody['profile']['bio'] != null) {
            _bioController.text = responseBody['profile']['bio'];
          }
          // store fetched pictures to imageBytesList
          for (int i = 1; i < 5; ++i) {
            String? pic = responseBody['profile']['picture$i'];
            if (pic != null) {
              _imageBytesList[i - 1] = base64Decode(pic);
            }
          }
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
        // Update the specific image in the list
        _imageBytesList[index] = imageBytes; 
      });
    }
  }

  // set dropdown options for all dropdown profile settings
  List<SetDropdownMenu<String>> getSettingItems(double fieldWidth) {
    List<SetDropdownMenu<String>> retList = [];
    for (var key in validSettings.keys) {
      retList.add(
        SetDropdownMenu<String>(
          selectedValue: settings[key] ?? validSettings[key]![0],
          items: validSettings[key]!,
          fieldWidth: fieldWidth,
          labelText: ((key[0]).toUpperCase() + key.substring(1)).replaceAll('_', ' '),
          onChanged: (String? newValue) => {
            setState(() => {
              if (newValue != null) {
                settings[key] = newValue
              }
            })
          },
        )
      );
    }
    return retList;
  }

  // get selected profile setting values
  Map<String, dynamic> getProfileData() {
    Map<String, dynamic> profileData = {
      'bio': _bioController.text,
      ...settings,
      // add profile pictures to profileData
      for (int i = 0; i < _imageBytesList.length; i++) 
        if (_imageBytesList[i] != null) 
          'picture${i+1}': base64.encode(_imageBytesList[i]!)
    };
    return profileData;
  }

  @override
  Widget build(BuildContext context) {
    Authorization().checkLogin(context);
    double fieldWidth = MyApp.getFieldWidth(context);
    double gridSpacing = 10; 

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
                      maxLines: null, 
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // set profile settings dropdown options
                  ...getSettingItems(fieldWidth),

                  // save button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Authorization().postRequest('/profile/', getProfileData()).then((resp) => {
                          if (resp.statusCode == 200) {
                            // Successfully modified
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const HomePage()))
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

class SetDropdownMenu<T> extends StatelessWidget {
  final T? selectedValue;
  final List<T> items;
  final String labelText;
  final double fieldWidth;
  final void Function(T? newValue)? onChanged;

  const SetDropdownMenu({
    Key? key,
    this.selectedValue,
    required this.items,
    required this.labelText,
    required this.fieldWidth,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: fieldWidth,
          child: DropdownButtonFormField<T>(
            value: selectedValue,
            decoration: InputDecoration(labelText: labelText),
            items: items.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
