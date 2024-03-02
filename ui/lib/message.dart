import 'package:flutter/material.dart';

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

class MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherPersonName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // message from the other person
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(widget.otherPersonProfilePicture),
                  ),
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 218, 228), 
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Text(
                        'Hello!',
                        textAlign: TextAlign.left,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),  
                ),
                ListTile(
                  trailing: CircleAvatar(
                    backgroundImage: NetworkImage(widget.currentUserProfilePicture),
                  ),
                  title: Align(
                    alignment: Alignment.centerRight, 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), 
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 218, 228), 
                        borderRadius: BorderRadius.circular(12.0), 
                      ),
                      child: const Text(
                        "Hi there!",
                        textAlign: TextAlign.end,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
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

  void _sendMessage() {
    final String text = _messageController.text;
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

