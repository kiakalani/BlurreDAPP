import 'dart:io';
import 'dart:html' as html;
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
import 'package:ui/auth.dart';

import 'login.dart';
import 'signup.dart';

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

  bool loggedIn() {
    String cookie = html.document.cookie.toString();
    developer.log(cookie);
    return cookie.contains("session");
  }

  Future<Response> postRequest(String url, Map<String, dynamic> data) async {
    return _dio.post(url, data: data);
  }
}

var net = NetworkService();

void main() {
  Authorization("http://localhost:3001");
  Authorization().isLoggedIn().then((value) => {
        developer.log("Logged In is " + value.toString()),
      });
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
