import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:ui/auth.dart';
import 'package:ui/location.dart';
import 'package:ui/messages.dart';
import 'package:ui/profile_setting.dart';
import 'swipe.dart';
import 'login.dart';
import 'preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ui/sock.dart';

Future<String> readBase64Image(String assetPath) async {
  return await rootBundle.loadString(assetPath);
}

void main() {
  Authorization("http://localhost:3001");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlurreDAPP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 244, 53, 158)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    Authorization().isLoggedIn().then((logged_in) => {
          if (logged_in) {_isLoggedIn = true}
        });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MessagesPage())),
            child:
                const Text('Messages', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileSettingsPage())),
            child: const Text('Profile Settings',
                style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PreferencePage())),
            child: const Text('Preferences',
                style: TextStyle(color: Colors.black)),
          ),
          TextButton(
              onPressed: () {
                // Log out users
                if (_isLoggedIn) {
                  Authorization()
                      .postRequest("/auth/signout/", {}).then((value) => {
                            if (value.statusCode == 200)
                              {
                                SocketIO('http://localhost:3001'),
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const HomePage()))
                              }
                          });
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginPage()));
                }
              },
              child: Text(_isLoggedIn ? 'Log Out' : 'Log In',
                  style: const TextStyle(color: Colors.black))),
        ],
      ),
      body: const Center(child: SwipePage()),
    );
  }
}
