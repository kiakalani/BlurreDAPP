import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ui/auth.dart';
import 'package:ui/profile_details.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  SwipePageState createState() => SwipePageState();
}

class SwipePageState extends State<SwipePage> {
  Uint8List? _profilePicture;
  String? _bio;
  String? _name;
  int? _age;
  List<int>? _userIds;
  int? _currentUserId;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // fetch user id
    _fetchUserIds();
  }

  void _fetchUserIds() {
    Authorization().getRequest("/swipe/").then((value) {
      final responseBody = json.decode(value.toString()); 
      if (responseBody['ids'] != null) {
        setState(() {
          _userIds = List<int>.from(responseBody['ids']);
          if (_userIds!.isEmpty) {
            // Show that there are no more matching users
          } else {
            // get current user id
            _getCurrentUserId();
          } 
        });
      }
    });
  }

  void _getCurrentUserId() {
    if (_userIds != null && _userIds!.isNotEmpty) {
      _currentUserId = _userIds!.removeAt(0);
      // Initialize profile details 
      _fetchProfileDetails();
    } else {
      _fetchUserIds();
    }
  }

  void swipe(String action) async {
    Authorization().postRequest('/swipe/', {
      "swiped": _currentUserId.toString(),
      "action": action
    }).then((value) => {
      if (value.statusCode == 200) {
        // This means swipe is done correctly
        _getCurrentUserId(),
      }
    });
  }

  void _fetchProfileDetails() {
    Authorization().postRequest("/profile/details/", {
      "user_id": _currentUserId.toString()
    }).then((value) {
      final responseBody = json.decode(value.toString()); 
      if (responseBody['profile'] != null && 
          responseBody['profile']['name'] != null &&
          responseBody['profile']['age'] != null &&
          responseBody['profile']['picture1'] != null &&
          responseBody['profile']['bio'] != null 
          ) {
        final String base64Image = responseBody['profile']['picture1'];
        final String bio = responseBody['profile']['bio'];
        final String name = responseBody['profile']['name'];
        final int age = responseBody['profile']['age'];
        setState(() {
          _profilePicture = base64Decode(base64Image);
          _bio = bio;
          _name = name;
          _age = age;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Authorization().isLoggedIn().then((logged_in) => {
      if (logged_in) {
        _isLoggedIn = true
      } else {
        _isLoggedIn = false
      }
    });
    return Scaffold(
      body: !_isLoggedIn || _profilePicture == null
      ? Container(
        width: double.infinity,
        height: double.infinity, 
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/ads.jpg"), 
            fit: BoxFit.cover
          ),
        ),
      )
      : Card(
          elevation: 4,
          child: Column(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfileDetailsPage(
                        currentUserId: _currentUserId.toString(),
                      )));
                  },
                  child: Image.memory(_profilePicture!, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${_name ?? 'N/A'}, ${_age?.toString() ?? 'N/A'}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  _bio ?? 'N/A',
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
                        swipe('left');
                      },
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      onPressed: () {
                        swipe('right');
                      },
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.favorite, color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }
}
    
    