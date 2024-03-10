
import 'package:flutter/material.dart';
import 'message.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> messages = [
      {
        'name': 'Alice',
        'imageUrl': 'https://storage.googleapis.com/pfpai/styles/392d70ba-8354-4869-ba0a-e075c8ea6d25.png?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=firebase-adminsdk-hu3sa%40stockai-362303.iam.gserviceaccount.com%2F20240301%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20240301T020126Z&X-Goog-Expires=518400&X-Goog-SignedHeaders=host&X-Goog-Signature=0c72c933cce3b03183156d24b549424146f2918a83142385cec276977e3de4e9b44da4b48a7480e18461df09e3fd25a032f94dbacfa6d748025acfa56021d9ab0b2e0409dcf0873029ea9a328abfb75cb34b5282db6c01240e47fcd987910f11e71e131af60300be85608321d7efc6ce95fb0e1f6015bfd622dc7a802c7db9e7a3cf70bd5ec03c5cf4bbd1fa569a797624aa9a9b1def22c853c2fef1d36b50aaefbde5f8ec9fe2281644e313c86278e7db26c14fbb7e5a015118cab0cb537f1f87f2f8888e19f246f2af80d465511341fa4b2105b60a571beb3d2b11bae5fa42980d76029e395cb50d015345b3ead161e4a971789119764f407a002d0d9aa6e1', 
      },
      {
        'name': 'Bob',
        'imageUrl': 'https://storage.googleapis.com/pfpai/styles/4d8dc817-827b-49bf-ad44-9fefe62edda0.png?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=firebase-adminsdk-hu3sa%40stockai-362303.iam.gserviceaccount.com%2F20240301%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20240301T020126Z&X-Goog-Expires=518400&X-Goog-SignedHeaders=host&X-Goog-Signature=30692ffa6233f0c5d1e67a5ae42fb733d92eee91c3cfc633f524f4da167fcfd4a49288da2b977d0a882cde888284505d4bd7a58b22d9f0b33ee5ca2db7d38b4c9edca1b37332914d66e90557efd4f27fcf0742f7a358cbcef7a20d8a9cb7ada4df5b1b776e6c5474c6f73d87065ea72cc152fd72f7532094fb4689ab3315935d3b5df2412d44c8f0e805c9d4f415d0f4b0dae52884b51c930bd7b238c18689c37335b98a579ac290a89cc209e66f126172faa769119bfbf96ed96cf0bbfb5b9bed69942930ae5d0e5cc66e5dc816f64dbfe17af02ab5469fcc474f5c14694b127c9192081ec069d0d196bdd73141197e0941744ba36b6288d9f9650a7461cbd1', 
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.separated(
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(messages[index]['imageUrl']),
            ),
            title: Text(messages[index]['name']),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MessagePage(
                    otherPersonName: messages[index]['name'],
                    otherPersonProfilePicture: messages[index]['imageUrl'],
                    currentUserProfilePicture: 'https://storage.googleapis.com/pfpai/styles/5784050e-9013-480a-b16d-b2c66fd89e1d.png?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=firebase-adminsdk-hu3sa%40stockai-362303.iam.gserviceaccount.com%2F20240301%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20240301T020126Z&X-Goog-Expires=518400&X-Goog-SignedHeaders=host&X-Goog-Signature=303cf3838ce63b75002cac65eda2be0d930bc2cbf481093d434539eb08104ed15d98bb157ef5ffae7f8f6274beeb53a24173c21e24336cf7ce4836665585ad72806de8f4a6c6a80d2395003f7cb20f4eab8fc47bbed5a9089857966a7f223b91ebf859e7309f6ac1c5c8a3b6a037ebd9263541674672197578ae12fb88a5455ba1d6083940db328b1049fd9d7a2a69cd48fae7a0a4b5bcf0fe7ea2bf9e8ef5c70e1cdfe3eda98d4afd49396d6e05b9caa6f647acafc94866358dca34404f12f05ad37c95e01f96650bc1c5afed01287ccf7dde5bbb5a61bc139813a27e61aceb6a2d8c5189c2f3d537486085c8de93b71d86b520f84e63a90168c6d7e507977e', 
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