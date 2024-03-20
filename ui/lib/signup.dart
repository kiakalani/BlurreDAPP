import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:ui/auth.dart';
import 'package:ui/main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupSuccessfullyPage extends StatelessWidget {
  const SignupSuccessfullyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup successfully Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('You\'ve signed up successfully.'),
      ),
    );
  }
}

class SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();  
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  // Date selection variables
  bool isDateSelected = false; 
  DateTime birthDate = DateTime.now(); 
  String birthDateString = ""; 

  // Password visibility
  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;

  // Password validation
  bool _isPasswordValid = true;

  @override
  Widget build(BuildContext context) {
    double fieldWidth =
      MediaQuery.of(context).size.width * 0.3; // 30% of screen width
    if (kIsWeb) {
      fieldWidth = MediaQuery.of(context).size.width * 0.3;
    } else if (Platform.isIOS || Platform.isAndroid) {
      fieldWidth = MediaQuery.of(context).size.width * 0.8;
    }
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
              // Name field 
              SizedBox(
                width: fieldWidth, // Control the width here
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.name,
                ),
              ),
              const SizedBox(height: 20),

              // Birthday field 
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
              ), 
              const SizedBox(height: 20),         

              // Email field 
              SizedBox(
                width: fieldWidth, // Control the width here
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20),

              // Password field 
              SizedBox(
                width: fieldWidth, // Control the width here
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible, 
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length < 6 && _isPasswordValid) {
                      setState(() => _isPasswordValid = false);
                    } else if (value.length >= 6 && !_isPasswordValid) {
                      setState(() => _isPasswordValid = true);
                    }
                  },
                ),
              ),

              // Error message display
              if (! _isPasswordValid) 
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Password must consist of least 6 characters.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              // Repeat Password field 
              SizedBox(
                width: fieldWidth, // Control the width here
                child: TextField(
                  controller: _repeatPasswordController,
                  obscureText: !_repeatPasswordVisible, 
                  decoration: InputDecoration(
                    labelText: 'Repeat Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _repeatPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _repeatPasswordVisible = !_repeatPasswordVisible;
                        });
                      },
                    ),    
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Authorization().postRequest("/auth/signup/", {
                    "email": _emailController.text,
                    "name": _nameController.text,
                    "birthday": birthDateString,
                    "password": _passwordController.text,
                    "repeat_password": _repeatPasswordController.text
                  }).then((value) => {
                        if (value.statusCode == 200)
                          {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const HomePage()))
                          }
                      });

                  developer.log(
                      'Name: ${_nameController.text}, Email: ${_emailController.text}, Birthday: $birthDateString, Password: ${_passwordController.text}, Repeat Password: ${_repeatPasswordController.text}',
                      name: 'SignupPage');
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
