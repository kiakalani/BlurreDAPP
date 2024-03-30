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
    for (var key in validSettings.keys) {
      settings[key] = null;
    }
    super.initState();
    // Initialize profile details 
    _fetchProfileSettings();
  }

  void _fetchProfileSettings() {
    Authorization().getRequest("/profile/").then((value) {
      final responseBody = json.decode(value.toString());
      if (responseBody['profile'] != null) {
            setState(() {
              for (var key in settings.keys) {
                if (responseBody['profile'][key] != null) {
                  settings[key] = responseBody['profile'][key].toString();
                }
              }
              if (responseBody['profile']['bio'] != null) {
                _bioController.text = responseBody['profile']['bio'];
              }
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

  @override
  Widget build(BuildContext context) {
    Authorization().checkLogin(context);
    double fieldWidth = MyApp.getFieldWidth(context);
    double gridSpacing = 10; 
    // the size for each square

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
                  ...getSettingItems(fieldWidth),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        print(_bioController.text + ' is the text!');
                        Authorization().postRequest('/profile/', {
                          'bio': _bioController.text,
                          ...settings,
                          'picture1': _imageBytesList[0] != null ? base64.encode(_imageBytesList[0]!) : null,
                          'picture2': _imageBytesList[1] != null ? base64.encode(_imageBytesList[1]!) : null,
                          'picture3': _imageBytesList[2] != null ? base64.encode(_imageBytesList[2]!) : null,
                          'picture4': _imageBytesList[3] != null ? base64.encode(_imageBytesList[3]!) : null,
                          
                        }).then((resp) => {
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
