import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui/auth.dart';
import 'package:ui/main.dart';
import 'login.dart';
import 'package:image_picker/image_picker.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();  
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  // Date selection variables
  bool isDateSelected = false; 
  DateTime birthDate = DateTime.now(); 
  String birthDateString = ""; 

  // Password visibility
  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;

  // Password validation
  bool _isPasswordValid = true;

  bool _displayErrorMessage = false;

  // pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double fieldWidth = MyApp.getFieldWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Upload photo field
              if (_imageBytes != null) 
                _setPhotoField(fieldWidth),
                const SizedBox(height: 10),
              _setUploadPhotoButton(fieldWidth),
              const SizedBox(height: 20),
                
              // Name field 
              _setNameField(fieldWidth),
              const SizedBox(height: 20),

              // Birthday field 
              _setBirthdayField(fieldWidth),
              const SizedBox(height: 20),         

              // Email field 
              setEmailField(fieldWidth, _emailController),
              const SizedBox(height: 20),

              // Password field 
              setPasswordField(fieldWidth, _passwordController, _passwordVisible, "Password", false),
              const SizedBox(height: 20),

              // Repeat Password field 
              setPasswordField(fieldWidth, _repeatPasswordController, _repeatPasswordVisible, "Repeat Password", true),
              const SizedBox(height: 20),

              // Error message display
              if (_displayErrorMessage) 
                setErrorMessage('You must upload your profile picture to register.'),
                const SizedBox(height: 20),

              // Sign up button
              _setSignupButton(fieldWidth)
            ],
          ),
        ),
      ),
    );
  }

  // Upload photo field
  Widget _setPhotoField(double fieldWidth) {
    return 
      SizedBox(
        width: 100,
        height: 100,
        child: Image.memory(_imageBytes!),
      );
  }

  // Upload photo field
  Widget _setUploadPhotoButton(double fieldWidth) {
    return 
      ElevatedButton(
        onPressed: _pickImage,
        child: const Text('Upload Photo'),
      );
  }

  // Name field 
  Widget _setNameField(double fieldWidth) {
    return 
      SizedBox(
        width: fieldWidth, 
        child: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.name,
        ),
      );
  }

  // Birthday field 
  Widget _setBirthdayField(double fieldWidth) {
    return
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(                     
            width: fieldWidth,
            child: TextFormField(
              controller: _birthdayController,
              decoration: const InputDecoration(
                labelText: 'Birthday',
                hintText: 'MM-DD-YYYY', // Hint for the expected format
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                // Open DatePicker
                final DateTime? datePick = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (datePick != null && datePick != birthDate) {
                  setState(() {
                    birthDate = datePick;
                    isDateSelected = true;
                    // Update the TextField and the birthDateString
                    birthDateString = "${birthDate.month}-${birthDate.day}-${birthDate.year}"; 
                    _birthdayController.text = birthDateString; // Display in TextField
                  });
                }
              },
            ),
          ),
        ],
      ); 
  }

  // Password field 
  Widget setPasswordField(double fieldWidth, TextEditingController passwordController, bool passwordVisible, String displayText, bool isRepeatPassword) {
    return 
      SizedBox(
        width: fieldWidth, 
        child: TextFormField(
          controller: passwordController,
          obscureText: !passwordVisible, 
          decoration: InputDecoration(
            labelText: displayText,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  isRepeatPassword ?_repeatPasswordVisible = !passwordVisible : _passwordVisible = !passwordVisible;
                });
              },
            ),
          ),
          onChanged: isRepeatPassword ?
            (value) {
              if (value.length < 6 && _isPasswordValid) {
                setState(() => _isPasswordValid = false);
              } else if (value.length >= 6 && !_isPasswordValid) {
                setState(() => _isPasswordValid = true);
              }
            } : null
        ),
      );
  }

  // Error message field 
  Widget setErrorMessage(String message) {
    return 
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          message,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
  }

  // Sign up button
  Widget _setSignupButton(double fieldWidth) {
    return 
      ElevatedButton(
        onPressed: () {
          Authorization().postRequest("/auth/signup/", {
            "picture1": _imageBytes != null ? base64.encode(_imageBytes!) : null,
            "email": _emailController.text,
            "name": _nameController.text,
            "birthday": birthDateString,
            "password": _passwordController.text,
            "repeat_password": _repeatPasswordController.text
          }).then((value) => {
            if (value.statusCode == 200) {              
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const HomePage()))
            }
            else {
              setState(() {
                _displayErrorMessage = true;
              })                        
            }
          });
        },
        child: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      );
  }
}
