import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/chat/model/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatBox extends ChangeNotifier {
//get auth of and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// send chat
  Future<void> sendChat(String receiverId, String message) async {
// get current user
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

//create chat
    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp);

// construct chatroom Id from current user and reciever Id (sorted for uniqueness)
    List<String> id = [currentUserId, receiverId];
    id.sort(); // to maintain the same position between the sender and receiver
    String chatRoomId =
        id.join('_'); // merge the id into single string for chat room
//add new message to firestore

    await _firestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .add(newMessage.toMap());
  }

// recieved chat
  Stream<QuerySnapshot> receiveChat(String userId, String otherUserId) {
    // construct chat room id from user id (sort for matching id used when sending)
    List<String> id = [userId, otherUserId];
    id.sort();
    String chatRoomId = id.join('_');

    return _firestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:etr_philearn_mad2/chat/model/message.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ChatBox extends ChangeNotifier {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> sendChat(String receiverUserId, String message) async {
//     final String currentUserId = _firebaseAuth.currentUser!.uid;
//     final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
//     final Timestamp timestamp = Timestamp.now();

//     Message newMessage = Message(
//       senderId: currentUserId,
//       senderEmail: currentUserEmail,
//       receiverId: receiverUserId,
//       message: message,
//       timestamp: timestamp,
//     );

//     List<String> id = [currentUserId, receiverUserId];
//     id.sort();
//     String chatRoomId = id.join('_');

//     await _firestore
//         .collection('chat_room')
//         .doc(chatRoomId)
//         .collection('message')
//         .add(newMessage.toMap());
//   }

//   Stream<QuerySnapshot> receiveChat(String userId, String otherUserId) {
//     List<String> id = [userId, otherUserId];
//     id.sort();
//     String chatRoomId = id.join('_');

//     return _firestore
//         .collection('chat_room')
//         .doc(chatRoomId)
//         .collection('message')
//         .orderBy('timestamp', descending: false)
//         .snapshots();
//   }
// }
