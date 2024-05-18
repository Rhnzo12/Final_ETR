import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/admin_screen/admin_edit_profile.dart';
import 'package:etr_philearn_mad2/admin_screen/current_question.dart';
import 'package:etr_philearn_mad2/admin_screen/philquestion_list.dart';
import 'package:etr_philearn_mad2/admin_screen/questiontoday_list.dart';
import 'package:etr_philearn_mad2/admin_screen/userslist.dart';
import 'package:etr_philearn_mad2/screen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final double profileHeight = 144.0;

  void updateProfileAdmin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminEditProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('Admin'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () => showLogoutConfirmationDialog(context),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildProfileImage(),
                Column(
                  children: [
                    const Text(
                      'Welcome',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          String username =
                              snapshot.data!.data()?['uname'] ?? 'Username';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                    // color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
                FloatingActionButton(
                  backgroundColor: const Color(0xFFff9906),
                  onPressed: updateProfileAdmin,
                  child: const Icon(
                    Icons.edit,
                    // color: Color(0xFFff9906),
                  ),
                )
              ],
            ),
            const Gap(15),
            Card(
              elevation: 5,
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ListQuestionToday()));
                },
                title: const Text('Update'),
                subtitle: const Text('Daily Question'),
                trailing: Card(
                    color: Colors.grey.shade400,
                    elevation: 3,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.black,
                      ),
                    )),
              ),
            ),
            Card(
              elevation: 5,
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ListPhilQuestion()));
                },
                title: const Text('Update'),
                subtitle: const Text('Philippine History Question'),
                trailing: Card(
                    color: Colors.grey.shade400,
                    elevation: 3,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.black,
                      ),
                    )),
              ),
            ),
            Card(
              elevation: 5,
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ListCurQuestion()));
                },
                title: const Text('Update'),
                subtitle: const Text('Current Events Question'),
                trailing: Card(
                    elevation: 3,
                    color: Colors.grey.shade400,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.black,
                      ),
                    )),
              ),
            ),
            Card(
              elevation: 5,
              child: ListTile(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => UserListPage()));
                },
                title: const Text('Manage'),
                subtitle: const Text('User Accounts'),
                trailing: Card(
                    elevation: 3,
                    color: Colors.grey.shade400,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.manage_accounts),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildProfileImage() => Padding(
        padding: const EdgeInsets.only(left: 10),
        child: CircleAvatar(
          radius: profileHeight / 3,
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
      );

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
}
