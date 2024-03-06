import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessagePage extends StatefulWidget {
  final String otherPersonName;
  final String otherPersonProfilePicture;
  final String currentUserProfilePicture;

  const MessagePage({
    required this.otherPersonName,
    required this.otherPersonProfilePicture,
    required this.currentUserProfilePicture,
  });

  @override
  MessagePageState createState() => MessagePageState();
}

class Message {
  String text;
  // True if the message was sent by the current user
  bool isCurrentUser; 
  DateTime timestamp;

  Message({
    required this.text,
    required this.isCurrentUser,
    required this.timestamp,
  });
}

class MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    // Initialize with some test messages
    _messages = [
      Message(
        text: 'Hello, how are you?',
        isCurrentUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Message(
        text: 'I\'m fine, thanks! And you?',
        isCurrentUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      Message(
        text: 'I\'m doing well too.',
        isCurrentUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io('http://localhost:3001', <String, dynamic>{
      'transports':['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO');
    });

    socket.on('message', (data) {
      print('Received message: $data');
    });

    socket.onDisconnect((_) => print('Disconnected from Socket.IO server'));
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final message = Message(
        text: text,
        isCurrentUser: true,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(message);
      });
      _messageController.clear();
      // send message to the server
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherPersonName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = _messages[index];
                return ListTile(
                  // display profile picture of the other user
                  leading: message.isCurrentUser ? null : CircleAvatar(
                    backgroundImage: NetworkImage(widget.otherPersonProfilePicture),
                  ),
                  // display profile picture of the current user
                  trailing: message.isCurrentUser ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.currentUserProfilePicture),
                  ) : null,
                  title: Align(
                    alignment: message.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: message.isCurrentUser ? Colors.blue[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: message.isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(message.timestamp),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  )
                );
              }
            ),
          ),
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

