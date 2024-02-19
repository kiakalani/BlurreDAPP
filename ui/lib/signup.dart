import 'dart:io';
import 'package:dio/browser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'login.dart';

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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
              SizedBox(
                width: fieldWidth, // Control the width here
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.name,
                ),
              ),
              const SizedBox(height: 20),
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
              SizedBox(
                width: fieldWidth, // Control the width here
                child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                      const SignupSuccessfullyPage()));
                  /*net.postRequest("http://localhost:3001/auth/signup/", {
                    "username": _usernameController,
                    "email": _emailController,
                    "password": _passwordController.text
                  }).then(
                    (value) => {
                      if (value.statusCode == 200)
                        {
                          developer.log(value.headers.toString()),
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const SignupSuccessfullyPage()))
                        }
                    },
                  );*/
                  // http
                  //     .post(Uri.parse("http://localhost:3001/auth/signup/"),
                  //         headers: {"Content-Type": "application/json"},
                  //         body: jsonEncode({
                  //            "username": _usernameController,
                  //            "email": _emailController,
                  //            "password": _passwordController.text
                  //         }))
                  //     .then((value) => {
                  //           print(value.body),
                  //           if (value.statusCode == 200)
                  //             {
                  //               developer.log(value.body),
                  //               Navigator.of(context).push(MaterialPageRoute(
                  //                   builder: (context) =>
                  //                       const SignupSuccessfullyPage()))
                  //             }
                  //         });
                  developer.log(
                    'Username: ${_usernameController.text}, Email: ${_emailController.text}, Password: ${_passwordController.text}',
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