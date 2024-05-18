import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  final String uname;

  const ChatRoom(
      {Key? key,
      required this.receiverUserEmail,
      required this.receiverUserId,
      required this.uname})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController messageController = TextEditingController();
  final ChatBox chatbox = ChatBox();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendChat() async {
    if (messageController.text.isNotEmpty) {
      // Verify that sendChat is being called correctly
      print('Sending chat... ReceiverUserId: ${widget.receiverUserId}');

      await chatbox.sendChat(widget.receiverUserId, messageController.text);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.uname),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/bg1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Expanded(
                  child: buildChatList(),
                ),
                buildChatTextBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatbox.receiveChat(
        _firebaseAuth.currentUser!.uid,
        widget.receiverUserId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => buildChatItem(document))
              .toList(),
        );
      },
    );
  }

  Widget buildChatItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                data['senderEmail'],
                style: const TextStyle(fontSize: 10),
              ),
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(data['message']),
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget buildChatTextBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Enter Message',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Card(
            elevation: 2,
            child: IconButton(
              onPressed: sendChat,
              icon: const Icon(
                Icons.send_rounded,
                size: 30,
                color: Color(0xFFff9906),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
