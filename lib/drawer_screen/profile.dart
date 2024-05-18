import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/chat/chat_screen.dart';
import 'package:etr_philearn_mad2/drawer_screen/home.dart';
import 'package:etr_philearn_mad2/drawer_screen/leaderboards.dart';
import 'package:etr_philearn_mad2/drawer_screen/profile_edit.dart';
import 'package:etr_philearn_mad2/drawer_screen/setting.dart';
import 'package:etr_philearn_mad2/screen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double coverHeight = 280.0;
  final double profileHeight = 144.0;
  void leaderboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LeaderBoardScreen(),
      ),
    );
  }

  void home() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(
          userId: '',
        ),
      ),
    );
  }

  void settings() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void updateProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ChatScreen()));
            },
            icon: const Icon(Icons.message_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 28, 45, 72),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
                        String username =
                            snapshot.data!.data()?['uname'] ?? 'Username';
                        return Row(
                          children: [
                            Image.asset(
                              profileImage,
                              width: 70,
                              height: 70,
                            ),
                            const Gap(5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                  ),
                                ),
                                const Gap(10),
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Text(
                                        'Score: N/A',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      );
                                    }
                                    dynamic scoreData = snapshot.data!['score'];
                                    int score = scoreData is String
                                        ? int.tryParse(scoreData) ?? 0
                                        : scoreData ?? 0;
                                    return Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.yellow, size: 25),
                                        const Gap(5),
                                        Text(
                                          'Score: $score',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Text(
                                        'Rank: N/A',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      );
                                    }

                                    // Fetch the current user's score
                                    var currentUserScore =
                                        snapshot.data!['score'] ?? 0;

                                    // Fetch all users' scores and sort them in descending order
                                    return FutureBuilder<QuerySnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .orderBy('score', descending: true)
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.data!.docs.isEmpty) {
                                          return const Text(
                                            'Rank: N/A',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          );
                                        }

                                        var users = snapshot.data!.docs;
                                        // Sort users based on their scores
                                        users.sort((a, b) {
                                          var aScore = a['score'] is String
                                              ? int.tryParse(a['score']) ?? 0
                                              : a['score'] ?? 0;
                                          var bScore = b['score'] is String
                                              ? int.tryParse(b['score']) ?? 0
                                              : b['score'] ?? 0;
                                          // Compare scores directly
                                          return bScore.compareTo(aScore);
                                        });

                                        // Find the index of the current user's score in the sorted list
                                        var currentUserIndex = users.indexWhere(
                                            (user) =>
                                                (user.data() as Map<String,
                                                    dynamic>)['score'] ==
                                                currentUserScore);

                                        // Calculate the rank based on the index (adding 1 since index is zero-based)
                                        var rank = currentUserIndex + 1;

                                        // Display the rank along with compared score
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.leaderboard_rounded,
                                                    color: Colors.green,
                                                    size: 25),
                                                const Gap(5),
                                                Text(
                                                  'Rank: $rank',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),
            Card(
              elevation: 2.0,
              child: ListTile(
                onTap: home,
                title: const Text('Home'),
                leading: const Icon(Icons.home),
              ),
            ),
            const Card(
              elevation: 4.0,
              child: ListTile(
                title: Text(
                  'Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFff9906),
                    fontSize: 20,
                  ),
                ),
                leading: Icon(
                  Icons.person_2_rounded,
                  size: 30,
                  color: Color(0xFFff9906),
                ),
              ),
            ),
            Card(
              elevation: 2.0,
              child: ListTile(
                onTap: leaderboard,
                title: const Text('Leaderboard'),
                leading: const Icon(Icons.leaderboard_rounded),
              ),
            ),
            Card(
              elevation: 2.0,
              child: ListTile(
                onTap: settings,
                title: const Text('Settings'),
                leading: const Icon(Icons.settings),
              ),
            ),
            Card(
              elevation: 2.0,
              child: ListTile(
                onTap: () => showLogoutConfirmationDialog(context),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/homebg.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Positioned(
            top: top + 72,
            left: 0,
            right: 0,
            child: Container(
              width: 1.0,
              height: 2,
              color: Colors.black,
              // margin: EdgeInsets.symmetric(vertical: .0), // Optional margin
            ),
          ),
          buildCoverImage(),
          Positioned(
            top: top,
            child: buildProfileImage(),
          ),
          Positioned(
            top: top + 100,
            left: 140,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      String username =
                          snapshot.data!.data()?['uname'] ?? 'Username';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            child: Text(
                              username,
                              style: const TextStyle(
                                  // color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: top + 160,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 25),
                    const Gap(5),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Text(
                            'Score: N/A',
                            style: TextStyle(
                              // color: Colors.white,
                              fontSize: 20,
                            ),
                          );
                        }
                        dynamic scoreData = snapshot.data!['score'];
                        int score = scoreData is String
                            ? int.tryParse(scoreData) ?? 0
                            : scoreData ?? 0;
                        return Text(
                          'Score: $score',
                          style: const TextStyle(
                            // color: Colors.white,
                            fontSize: 20,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.leaderboard,
                        color: Colors.green, size: 25),
                    const Gap(5),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Text(
                            'Rank: N/A',
                            style: TextStyle(
                              // color: Colors.white,
                              fontSize: 20,
                            ),
                          );
                        }

                        // Fetch the current user's score
                        var currentUserScore = snapshot.data!['score'] ?? 0;

                        // Fetch all users' scores and sort them in descending order
                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .orderBy('score', descending: true)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Text(
                                'Rank: N/A',
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontSize: 20,
                                ),
                              );
                            }

                            var users = snapshot.data!.docs;
                            // Sort users based on their scores
                            users.sort((a, b) {
                              var aScore = a['score'] is String
                                  ? int.tryParse(a['score']) ?? 0
                                  : a['score'] ?? 0;
                              var bScore = b['score'] is String
                                  ? int.tryParse(b['score']) ?? 0
                                  : b['score'] ?? 0;
                              // Compare scores directly
                              return bScore.compareTo(aScore);
                            });

                            // Find the index of the current user's score in the sorted list
                            var currentUserIndex = users.indexWhere((user) =>
                                (user.data()
                                    as Map<String, dynamic>)['score'] ==
                                currentUserScore);

                            // Calculate the rank based on the index (adding 1 since index is zero-based)
                            var rank = currentUserIndex + 1;

                            // Display the rank along with compared score
                            return Text(
                              'Rank: $rank',
                              style: const TextStyle(
                                // color: Colors.white,
                                fontSize: 20,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: top + 190,
            left: 0,
            right: 0,
            child: Container(
              width: 1.0,
              height: 2,
              color: Colors.black,
              // margin: EdgeInsets.symmetric(vertical: .0), // Optional margin
            ),
          ),
          Positioned(
              top: top + 200,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFFff9906)),
                      elevation: WidgetStateProperty.all<double>(4.0),
                      shadowColor: WidgetStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: updateProfile,
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
              )),
        ],
      ),
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.grey,
        child: Image.asset(
          'assets/images/homebg.png',
          width: double.infinity,
          height: coverHeight,
          fit: BoxFit.cover,
        ),
      );

  Widget buildProfileImage() => Padding(
        padding: const EdgeInsets.only(left: 10),
        child: CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: Colors.black,
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
                  width: 141,
                  height: 141,
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
