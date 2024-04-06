import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/main.dart';
import 'auth.dart';
import 'dart:convert';

class PreferencePage extends StatefulWidget {
  const PreferencePage({Key? key}) : super(key: key);

  @override
  PreferencePageState createState() => PreferencePageState();
}

class PreferencePageState extends State<PreferencePage> {
  final _formKey = GlobalKey<FormState>();
  // Options available for preferences
  final List<String> _genders = ['Male', 'Female', 'Other', 'Everyone'];
  final List<String> _orientations = ['Straight', 'Gay', 'Lesbian', 'Bisexual', 'Asexual', 'Other', 'Everyone'];

  // Selected options for preferences
  String? _gender, _orientation;
  int? _maxDistnace = 100;
  RangeValues _ageRange = const RangeValues(18, 100);

  @override
  void initState() {
    super.initState();
    // Initialize preferences
    _fetchPreferences();
  }

  void _fetchPreferences() {
    Authorization().getRequest("/profile/preference/").then((value) {
      final responseBody = json.decode(value.toString());
      print(responseBody);
      if (responseBody['preferences'] != null) {
        final String? gender = responseBody['preferences']['gender'];
        final String? orientation = responseBody['preferences']['orientation'];
        final int? maxDistance = responseBody['preferences']['distance'];
        final int? minAge = responseBody['preferences']['min_age'];
        final int? maxAge = responseBody['preferences']['age'];
        setState(() {
          _gender = gender;
          _orientation = orientation;
          _maxDistnace = maxDistance;
          _ageRange = RangeValues(minAge!.toDouble(), maxAge!.toDouble());
        });  
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Authorization().checkLogin(context);
    double fieldWidth = MyApp.getFieldWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gender preference field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: _genders.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _gender = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sex Orientation field
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField(
                      value: _orientation,
                      decoration: const InputDecoration(labelText: 'Sex Orientation'),
                      items: _orientations.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _orientation = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Maximum distance field
                  SizedBox(
                    width: fieldWidth,
                    child: Column(
                      children: [
                        Text('Maximum Distance (${_maxDistnace!.round()} km)', style: TextStyle(fontSize: 16)),
                        Slider(
                          min: 0,
                          max: 100,
                          activeColor: Colors.blue,
                          inactiveColor: Colors.grey,
                          thumbColor: Colors.white,
                          value: _maxDistnace!.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _maxDistnace = value.toInt();
                            });
                          },
                        ),
                      ],
                    )
                  ),
                  
                  // Age range field
                  SizedBox(
                    width: fieldWidth,
                    child: Column(
                      children: [
                        Text('Age Range (${_ageRange!.start.round()} - ${_ageRange!.end.round()})', style: const TextStyle(fontSize: 16)),
                          RangeSlider(
                            values: _ageRange,
                            min: 18,
                            max: 100,
                            activeColor: Colors.blue,
                            inactiveColor: Colors.grey,
                            onChanged: (RangeValues values) {
                              setState(() {
                                _ageRange = values;
                              });
                            },
                          ),
                      ])
                  ),

                  const SizedBox(height: 20),

                  // save button field
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Authorization().postRequest('/profile/preference/', {
                          'gender': _gender,
                          'orientation': _orientation,
                          'distance': _maxDistnace.toString(),
                          'min_age': _ageRange.start.toInt().toString(), 
                          'age': _ageRange.end.toInt().toString(), 
                        }).then((resp) => {
                          if (resp.statusCode == 200) {
                            print("succesfull"),
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const HomePage()))
                          }
                        });
                      }
                    },
                    child: const Text('Save'),
                  ),
                ]
              )
            )
          )
        )
      )
    );
  }
}