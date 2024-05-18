import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/admin_screen/admin_management/edit_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('User List'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('type', isNotEqualTo: 'admin')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No users found'));
            }

            final userData = snapshot.data!.docs;

            return ListView.builder(
              itemCount: userData.length,
              itemBuilder: (context, index) {
                var user = userData[index];
                String userName = user['uname'] ?? 'No name';
                String userEmail = user['email'] ?? 'No email';
                String userGender = user['gender'] ?? '';

                String profileImage = 'assets/images/';
                if (userGender.toLowerCase() == 'male') {
                  profileImage += 'male.png';
                } else if (userGender.toLowerCase() == 'female') {
                  profileImage += 'female.png';
                } else {
                  profileImage += 'other.png';
                }

                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('Username: $userName'),
                    subtitle: Text('Email: $userEmail'),
                    trailing: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade800,
                      child: Image.asset(
                        profileImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => EditUserPage(user: user),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
