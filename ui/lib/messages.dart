
import 'package:flutter/material.dart';
import 'package:ui/auth.dart';
import 'message.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
  Map<String, dynamic> usersData = {};

  @override
  void initState() {
    super.initState();
    // fetch matched users
    _fetchMatchedUsers();
  }

  void _fetchMatchedUsers() {
    Authorization().postRequest("/message/", {}).then((value) {
      if (value.statusCode == 200) {
        final responseBody = json.decode(value.toString()); 
        print(value);
         setState(() {
          if (responseBody['info'] != null) {
            usersData = Map<String, dynamic>.from(responseBody['info']);
          }
        });
      }    
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersList = usersData.entries.map((entry) {
      return {
        'userId': entry.key,
        'name': entry.value['name'],
        'picture': base64Decode(entry.value['picture']), 
        'new_messages': entry.value['new_messages'].toString(),
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.separated(
        itemCount: usersList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: MemoryImage(usersList[index]['picture']),
            ),
            title: Text(usersList[index]['name']),
            trailing: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                usersList[index]['new_messages'],
                style: const TextStyle(color: Colors.black),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MessagePage(
                    otherUserName: usersList[index]['name'],
                    otherUserProfilePicture: usersList[index]['picture'],
                    otherUserId: usersList[index]['userId'],
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}