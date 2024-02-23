import 'package:flutter/material.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override 
  ProfileSettingsPageState createState() => ProfileSettingsPageState();
}

class ProfileSettingsPageState extends State<ProfileSettingsPage> {
  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Settings'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
         child: Text('Profile Settings'),
        ),
      );
  }
}

