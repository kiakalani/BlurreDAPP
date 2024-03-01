import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class SwipeableCard extends StatelessWidget {
  final String picture1;
  final String name;
  final String birthday;
  final String bio;

  const SwipeableCard({
    required this.picture1,
    required this.name,
    required this.birthday,
    required this.bio,
  });

  // calculate age
  int calculateAge(String birthday) {
    final birthdayDate = DateTime.parse(convertBirthdayFormat(birthday));
    final today = DateTime.now();
    int age = today.year - birthdayDate.year;
    if (today.month < birthdayDate.month ||
        (today.month == birthdayDate.month && today.day < birthdayDate.day)) {
      age--;
    }
    return age;
  }

  // Rearranging birthday format from MM-DD-YYYY to YYYY-MM-DD
  String convertBirthdayFormat(String date) {
    final parts = date.split('-');
    if (parts.length != 3) {
      throw const FormatException("Invalid date format. Expected MM-DD-YYYY.");
    }
    return '${parts[2]}-${parts[0]}-${parts[1]}'; 
  }

  // Convert the base64 string to a Uint8List
  Uint8List _imageFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    final age = calculateAge(birthday);
    final imageBytes = _imageFromBase64String(picture1);
    return Card(
      elevation: 4,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Image.memory(imageBytes, fit: BoxFit.cover),
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
                  onPressed: () {
                    // Handle dislike action
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                FloatingActionButton(
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
