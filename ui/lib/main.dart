import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:ui/auth.dart';
import 'package:ui/messages.dart';
import 'package:ui/profile_setting.dart';
import 'swipe.dart';
import 'login.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: const Text('Log In', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: const Center(child: SwipePage()),
    );
  }
}
