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

class NetworkService {
  late Dio _dio;
  late BrowserHttpClientAdapter _adapter;

  NetworkService() {
    _dio = Dio();
    if (!kIsWeb) {
      // For platforms other than web, use dio_cookie_manager to manage cookies
      _dio.interceptors.add(CookieManager(CookieJar()));
    } else {
      _adapter = BrowserHttpClientAdapter();
      _adapter.withCredentials = true;
      _dio.httpClientAdapter = _adapter;
    }
    // On the web, cookies are automatically managed by the browser
  }

  Future<Response> getRequest(String url) async {
    return _dio.get(url);
  }

  Future<Response> postRequest(String url, Map<String, dynamic> data) async {
    return _dio.post(url, data: data);
  }
}

var net = NetworkService();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 244, 53, 158)),
        useMaterial3: true,
      ),
      //home: const LoginPage(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: const Text('Log In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Dating App!'),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class LoginSuccessfullyPage extends StatelessWidget {
  const LoginSuccessfullyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Successfully Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: TextButton(
          onPressed: () => {
            net.postRequest('http://localhost:3001/auth/signout/', {}).then(
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
            // })
          },
          child: const Text('Log out'),
        ),
      ),
    );
  }
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
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
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
                  net.postRequest("http://localhost:3001/auth/signup/", {
                    "username": _emailController.text,
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
                  );
                  // http
                  //     .post(Uri.parse("http://localhost:3001/auth/signup/"),
                  //         headers: {"Content-Type": "application/json"},
                  //         body: jsonEncode({
                  //           "username": _emailController.text,
                  //           "password": _passwordController.text
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
                      'Username: ${_emailController.text}, Password: ${_passwordController.text}',
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

class LoginPageState extends State<LoginPage> {
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
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
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
                  net.postRequest('http://localhost:3001/auth/signin/', {
                    "username": _emailController.text,
                    "password": _passwordController.text,
                  }).then((resp) => {
                        if (resp.statusCode == 200)
                          {
                            print(resp.headers.map.toString()),
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const LoginSuccessfullyPage()))
                          }
                      });
                  // client.post(
                  //   Uri.parse('http://localhost:3001/auth/signin/',),
                  //   body: jsonEncode({
                  //   "username": _emailController.text,
                  //   "password": _passwordController.text,
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
                  //     "username": _emailController.text,
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
                      'Username: ${_emailController.text}, Password: ${_passwordController.text}',
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
