import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ui/profile_details.dart';

class SwipePage extends StatelessWidget {
  final String picture1;
  final String name;
  final int age;
  final String bio;

  const SwipePage({
    required this.picture1,
    required this.name,
    required this.age,
    required this.bio,
  });

  // Convert the base64 string to a Uint8List
  Uint8List _imageFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _imageFromBase64String(picture1);
    return Card(
      elevation: 4,
      child: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileDetailsPage()));
              },
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$name, $age',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              bio,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    // Handle dislike action
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    // Handle like action
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
