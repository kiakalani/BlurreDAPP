import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:ui/auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:ui/profile_details.dart';
import 'package:ui/sock.dart';

class MessagePage extends StatefulWidget {
  final String otherUserName;
  Uint8List? otherUserProfilePicture;
  final String otherUserId;

  MessagePage(
      {required this.otherUserName,
      required this.otherUserProfilePicture,
      required this.otherUserId});

  @override
  MessagePageState createState() => MessagePageState();
}

class Message {
  String text;
  // True if the message was sent by the current user
  bool isCurrentUser;
  DateTime timestamp;
  bool seen;

  Message(
      {required this.text,
      required this.isCurrentUser,
      required this.timestamp,
      required this.seen});
}

class MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  List<Message> _messages = [];
  List<dynamic> messages = [];
  Uint8List? _currentUserProfilePicture;
  String? _currentUserId;
  bool _isSeen = false;

  @override
  void initState() {
    super.initState();

    // _initSocket();
    _fetchAndSetProfilePicture();
  }

  void _fetchAndSetProfilePicture() {
    Authorization().getRequest("/profile/").then((value) {
      final responseBody = json.decode(value.toString());
      if (responseBody['profile'] != null &&
          responseBody['profile']['picture1'] != null &&
          responseBody['profile']['id'] != null) {
        final String base64Image = responseBody['profile']['picture1'];
        final String currentUserId = responseBody['profile']['id'].toString();
        _currentUserId = currentUserId;
        setState(() {
          _currentUserProfilePicture = base64Decode(base64Image);
          _fetchMessages();
        });
      }
    });
  }

  void _fetchMessages() {
    Authorization().getRequest("/message/${widget.otherUserId}/").then((value) {
      final responseBody = json.decode(value.toString());
      if (responseBody['messages'] != null) {
        List<Message> texts = [];
        messages = List<dynamic>.from(responseBody['messages']);
        for (var element in messages) {
          String text = element['message'];
          bool isCurrentUser = (element['sender'].toString() == _currentUserId);
          DateTime d =
              DateTime.fromMillisecondsSinceEpoch(element['timestamp'] * 1000);
          bool seen = element['read'].toString() == 'true';
          texts.add(Message(
              text: text,
              isCurrentUser: isCurrentUser,
              timestamp: d,
              seen: seen));
        }
        setState(() {
          _messages = texts;
        });
        SocketIO().emit('seen', {'dest': widget.otherUserId});
      }
    });
    SocketIO().on(
        'receive_msg',
        (p0) => {
              setState(() {
                _messages.add(Message(
                    text: p0['message']['message'],
                    isCurrentUser: false,
                    timestamp: DateTime.fromMillisecondsSinceEpoch(
                        p0['message']['timestamp'] * 1000),
                    seen: true));
              }),
              SocketIO().emit('seen', {'dest': widget.otherUserId}),
            });

    SocketIO().on(
        'seen_last',
        (p0) => {
              if (p0['user'] != null &&
                  p0['user'].toString() == widget.otherUserId)
                {_isSeen = true, setState(() => _isSeen = true)}
            });
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final message = Message(
          text: text,
          isCurrentUser: true,
          timestamp: DateTime.now(),
          seen: false);
      _isSeen = false;
      Authorization().postRequest('/message/${widget.otherUserId}/', {
        'message': message.text
      }).then((value) => {
            setState(() {
              _messages.add(message);
              var responseBody = json.decode(value.toString());
              if (responseBody['updated_pics'] != null) {
                widget.otherUserProfilePicture =
                    base64Decode(responseBody['updated_pics']);
              }
            }),
          });
      _messageController.clear();
      // send message to the server
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final message = _messages[index];
                  return Column(
                    children: [
                      ListTile(
                        // display profile picture of the other user
                        leading: message.isCurrentUser
                            ? null
                            : GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => ProfileDetailsPage(
                                    currentUserId: widget.otherUserId.toString(),
                                  )));
                              },
                              child: CircleAvatar(
                                backgroundImage: widget.otherUserProfilePicture != null
                                    ? MemoryImage(widget.otherUserProfilePicture!)
                                    : null,
                              ),
                            ), 
                        // display profile picture of the current user
                        trailing: message.isCurrentUser
                            ? CircleAvatar(
                                backgroundImage: _currentUserProfilePicture != null
                                    ? MemoryImage(_currentUserProfilePicture!)
                                    : null,
                              )
                            : null,
                        title: Align(
                            alignment: message.isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child:
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: message.isCurrentUser
                                      ? Colors.blue[100]
                                      : Colors.green[100],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        message.text,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Align(
                                        alignment: Alignment.bottomRight,
                                        child: Column(children: [
                                          Text(
                                            _formatTimestamp(message.timestamp),
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          ),
                                        ]
                                      )
                                    ),                      
                                  ],
                                ),
                              ),
                            ),
                        ),
                        // Sent and Seen area
                        if (index == _messages.length - 1 && message.isCurrentUser) 
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _isSeen || message.seen ? 'Seen' : 'Sent',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                  );
                 }),
          ),
          const SizedBox(width: 4),
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket.disconnect();
    super.dispose();
  }
}

// to send message: make a post request to the `/message/<other_user_id>/` to send a message.
// For the body of the message send: {'message': 'The text you are trying to send'}.

// to receive all the messages when you open the page:
// Make a get request to `/message/<other_user_id>/`
