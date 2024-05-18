import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/chat/chat_room.dart';
import 'package:etr_philearn_mad2/screen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<void> logout(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Logging out...');
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } catch (error) {
      print("Error logging out: $error");
    } finally {
      EasyLoading.dismiss();
    }
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 28, 45, 72),
          elevation: 4.0,
          shadowColor: Colors.blueGrey.withOpacity(0.5),
          title: const Text(
            'Logout',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "No",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                await logout(context);
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                    color: Color(0xFFff9906), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showLogoutConfirmationDialog(context),
            icon: Icon(Icons.logout),
          ),
        ],
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
          buildUserList(),
        ],
      ),
    );
  }

  Widget buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isNotEqualTo: 'admin')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Ensure that data['uid'] is not null
    print('Data UID: ${data['uid']}');

    if (FirebaseAuth.instance.currentUser!.email != data['email']) {
      String? receiverUserId = data['uid'];

      return ListTile(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade800,
                child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      String gender = snapshot.data!.data()?['gender'] ?? '';
                      String profileImage = 'assets/images/';
                      if (gender.toLowerCase() == 'male') {
                        profileImage += 'male.png';
                      } else if (gender.toLowerCase() == 'female') {
                        profileImage += 'female.png';
                      } else {
                        profileImage += 'other.png';
                      }

                      return Image.asset(
                        profileImage,
                        // width: 70,
                        // height: 70,
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
              Gap(15),
              Text(
                data['uname'],
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        onTap: () {
          // Check if receiverUserId is being passed correctly
          print('ReceiverUserId before navigating: $receiverUserId');

          if (receiverUserId != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatRoom(
                  receiverUserEmail: data['email'],
                  receiverUserId: receiverUserId,
                  uname: data['uname']),
            ));
          } else {
            print('Error: receiverUserId is null');
          }
        },
      );
    } else {
      return Container();
    }
  }
}
