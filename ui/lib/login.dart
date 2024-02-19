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

import 'signup.dart';
import 'profile_setting.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
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
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
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
                width: fieldWidth,
                child: TextField(
                  controller: _emailController, // This is now explicitly for the email
                  decoration: const InputDecoration(
                    labelText: 'Email', // Clearly mark it as Email
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
                        const LoginSuccessfullyPage()));
                  /*net.postRequest('http://localhost:3001/auth/signin/', {                
                    "username": _usernameController,
                    "email": _emailController,
                    "password": _passwordController.text
                  }).then((resp) => {
                        if (resp.statusCode == 200)
                          {
                            print(resp.headers.map.toString()),
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const LoginSuccessfullyPage()))
                          }
                      });*/
                  // client.post(
                  //   Uri.parse('http://localhost:3001/auth/signin/',),
                  //   body: jsonEncode({
                  //    "username": _usernameController,
                  //    "email": _emailController,
                  //    "password": _passwordController.text
                  //   }),
                  //   headers: {"Content-Type": "application/json"},
                  // ).then((response) => {
                  //     if (response.statusCode == 200) {
                  //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginSuccessfullyPage()))
                  //     }
                  //   // print(response.),
                  //   // print(response.headers.map['set-cookie'].toString())
                  // });
                  // http.post(
                  //   Uri.parse('http://127.0.0.1:5000/auth/signin/'),
                  //   headers: {"Content-Type": "application/json"},
                  //   body: jsonEncode({
                  //     "username": _usernameController,
                  //     "email": _emailController,
                  //     "password": _passwordController.text,
                  //   }),
                  // ).then(
                  //   (value) => {
                  //     if (value.statusCode == 200) {
                  //       developer.log(value.headers.toString())
                  //       // storage.write(key: 'session', value: 'your_session_token_or_cookie').then((_) => {
                  //       //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginSuccessfullyPage()))
                  //       // })
                  //     }
                  //   }
                  // );
                  developer.log(
                      'Username: ${_usernameController.text}, Email: ${_emailController.text}, Password: ${_passwordController.text}',
                      name: 'LoginPage');
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SignupPage())),
                child: const Text('Create your account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginSuccessfullyPage extends StatelessWidget {
  const LoginSuccessfullyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Successfully Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const LoginPage())),
                child: const Text('Log Out', style: TextStyle(color: Colors.white))
                /*net.postRequest('http://localhost:3001/auth/signout/', {}).then(
                (resp) => {
                      if (resp.statusCode == 200)
                        {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()))
                        }
                    })
            // client.post(
            //   Uri.parse('http://localhost:3001/auth/signout/'),
            //   headers: {"Content-Type": "application/json"},
            // ).then((response) => {
            //   if (response.statusCode == 200) {
            //     print(response.body),
            //     Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()))
            //   } else {
            //     print(response.body)
            //   }
            // })
            // http.post(Uri.parse('http://127.0.0.1:5000/auth/signout/')).then((value) => {
            //   if (value.statusCode == 200) {
            //     Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()))
            //   } else {
            //     developer.log(value.body)
            //   }
            // }),*/
          ),
        ],
      ),
      body: Center(
        child: TextButton(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileSettingsPage()))
          },
          child: const Text('Profile Setting'),
        ),
      ),
    );
  }
}