import 'dart:io';
//import 'dart:html' as html;
//import 'package:dio/browser.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
//import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ui/auth.dart';
import 'package:ui/messages.dart';
import 'package:ui/profile_setting.dart';
import 'package:flutter/material.dart';
import 'swipe.dart';
import 'login.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<String> readBase64Image(String assetPath) async {
  return await rootBundle.loadString(assetPath);
}

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
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MessagesPage())),
            child: const Text('Messages', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfileSettingsPage())),
            child: const Text('Profile Settings', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: const Text('Log In', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: readBase64Image('assets/images/lovely.txt'), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              print("Error loading image: ${snapshot.error}");
              return const Center(child: Text('Error loading image'));            }
            if (snapshot.hasData) {
              return Center(
                child: SwipePage(
                  picture1: snapshot.data!,
                  name: 'Banana',
                  birthday: '04-17-2000',
                  bio: 'Loves hiking, swimming, and reading.',
                ),
              );
            }
          }
          // While loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
