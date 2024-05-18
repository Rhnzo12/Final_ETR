import 'package:etr_philearn_mad2/chat/chat_screen.dart';
import 'package:etr_philearn_mad2/drawer_screen/leaderboards.dart';
import 'package:etr_philearn_mad2/drawer_screen/profile.dart';
import 'package:etr_philearn_mad2/drawer_screen/setting.dart';
import 'package:etr_philearn_mad2/question_screen/curEvents_question.dart';
import 'package:etr_philearn_mad2/question_screen/philhistory_question.dart';
import 'package:etr_philearn_mad2/question_screen/todayquestion_screen.dart';
import 'package:etr_philearn_mad2/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userId});
  final String userId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int currentDay;
  late int philcurrentDay;
  late int curcurrentDay;
  bool questionAnswered = false;
  bool philquestionAnswered = false;
  bool curquestionAnswered = false;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    currentDay = now.day;
    philcurrentDay = now.day;
    curcurrentDay = now.day;
    checkIfQuestionAnswered();
    checkIfPhilQuestionAnswered();
    checkIfCuRQuestionAnswered();
  }

  void leaderboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LeaderBoardScreen(),
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

  void profile() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  Future<void> checkIfQuestionAnswered() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data();
        if (userData != null) {
          // Check if the user has answered the question today
          String? lastAnswerDate = userData['lastDate'];
          if (lastAnswerDate != null) {
            DateTime lastAnswerDateTime = DateTime.parse(lastAnswerDate);
            if (lastAnswerDateTime.day == currentDay) {
              // User has already answered the question today
              setState(() {
                questionAnswered = true;
              });
            }
          }
        }
      }
    } catch (error) {
      print("Error checking if question answered: $error");
    }
  }

  Future<void> checkIfPhilQuestionAnswered() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data();
        if (userData != null) {
          // Check if the user has answered the question today
          String? lastAnswerDate = userData['philAnswered'];
          if (lastAnswerDate != null) {
            DateTime lastAnswerDateTime = DateTime.parse(lastAnswerDate);
            if (lastAnswerDateTime.day == philcurrentDay) {
              // User has already answered the question today
              setState(() {
                philquestionAnswered = true;
              });
            }
          }
        }
      }
    } catch (error) {
      print("Error checking if question answered: $error");
    }
  }

  Future<void> checkIfCuRQuestionAnswered() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data();
        if (userData != null) {
          // Check if the user has answered the question today
          String? lastAnswerDate = userData['curAnswered'];
          if (lastAnswerDate != null) {
            DateTime lastAnswerDateTime = DateTime.parse(lastAnswerDate);
            if (lastAnswerDateTime.day == curcurrentDay) {
              // User has already answered the question today
              setState(() {
                curquestionAnswered = true;
              });
            }
          }
        }
      }
    } catch (error) {
      print("Error checking if question answered: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Home'),
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
                                          .instance.currentUser?.uid)
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
            const Card(
              elevation: 4.0,
              child: ListTile(
                title: Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFff9906),
                    fontSize: 20,
                  ),
                ),
                leading: Icon(
                  Icons.home,
                  size: 30,
                  color: Color(0xFFff9906),
                ),
              ),
            ),
            Card(
              elevation: 2.0,
              child: ListTile(
                onTap: profile,
                title: const Text('Profile'),
                leading: const Icon(Icons.person_2_rounded),
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Gap(10),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: const Color.fromARGB(255, 28, 45, 72),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('questiontoday')
                            .doc(currentDay.toString())
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Center(
                                child: Text('No data available'));
                          }
                          var data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          String question = data['question'] ?? '';
                          String buttonText = questionAnswered
                              ? 'Question Answered'
                              : 'Show Question';
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Question of the day!',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFff9906),
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  questionAnswered
                                      ? 'Congratulations! You have answered today\'s question.'
                                      : question,
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white),
                                ),
                                const Gap(20),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                        if (states
                                            .contains(WidgetState.disabled)) {
                                          return Colors.grey.withOpacity(0.5);
                                        }
                                        return const Color(0xFFff9906);
                                      },
                                    ),
                                    elevation:
                                        WidgetStateProperty.all<double>(4.0),
                                    shadowColor: WidgetStateProperty.all<Color>(
                                        Colors.black),
                                    foregroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                        if (states
                                            .contains(WidgetState.disabled)) {
                                          return Colors.grey;
                                        }
                                        return Colors.white;
                                      },
                                    ),
                                  ),
                                  onPressed: questionAnswered
                                      ? null
                                      : () async {
                                          setState(() {
                                            questionAnswered = true;
                                          });

                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const QuestionTodayScreen(),
                                            ),
                                          );
                                        },
                                  child: Text(
                                    buttonText,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Column(
                    children: [
                      Card(
                        elevation: 5,
                        color: philquestionAnswered
                            ? Colors.grey.withOpacity(0.5)
                            : const Color(0xFFff9906),
                        child: ListTile(
                          onTap: philquestionAnswered
                              ? null
                              : () async {
                                  setState(() {
                                    philquestionAnswered = true;
                                  });

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PhilHistoryQuestionScreen(),
                                    ),
                                  );
                                },
                          title: philquestionAnswered
                              ? const Text('Done')
                              : const Text(
                                  'Answer Now!',
                                  style: TextStyle(color: Colors.black),
                                ),
                          subtitle: philquestionAnswered
                              ? const Text('Answered')
                              : const Text(
                                  'Philippine History Mode',
                                  style: TextStyle(color: Colors.black),
                                ),
                          trailing: philquestionAnswered
                              ? Card(
                                  elevation: 3,
                                  color: Colors.grey.shade400,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              : Card(
                                  elevation: 3,
                                  color: Colors.grey.shade400,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const Gap(10),
                      Card(
                        elevation: 5,
                        color: curquestionAnswered
                            ? Colors.grey.withOpacity(0.5)
                            : const Color(0xFFff9906),
                        child: ListTile(
                          onTap: curquestionAnswered
                              ? null
                              : () async {
                                  setState(() {
                                    curquestionAnswered = true;
                                  });

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CurHistoryQuestionScreen(),
                                    ),
                                  );
                                },
                          title: curquestionAnswered
                              ? const Text(
                                  'Done',
                                )
                              : const Text(
                                  'Answer Now!',
                                  style: TextStyle(color: Colors.black),
                                ),
                          subtitle: curquestionAnswered
                              ? const Text('Answered')
                              : const Text(
                                  'Current Events Mode',
                                  style: TextStyle(color: Colors.black),
                                ),
                          trailing: curquestionAnswered
                              ? Card(
                                  elevation: 3,
                                  color: Colors.grey.shade400,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              : Card(
                                  elevation: 3,
                                  color: Colors.grey.shade400,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
