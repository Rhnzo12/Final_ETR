import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';

class QuestionTodayScreen extends StatefulWidget {
  const QuestionTodayScreen({super.key});

  @override
  State<QuestionTodayScreen> createState() => _QuestionTodayScreenState();
}

class _QuestionTodayScreenState extends State<QuestionTodayScreen> {
  late int currentDay;
  late String correctAnswer;
  String? selectedAnswer;
  bool answerSelected = false;
  bool shuffleChoices = true;
  late List<String> shuffledChoices;
  late Map<String, Color?> choiceColors;
  User? user;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Auth
    user = FirebaseAuth.instance.currentUser;
    DateTime now = DateTime.now();
    currentDay = now.day;
    shuffledChoices = [];
    choiceColors = {};
  }

  void answered() {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'score': FieldValue.increment(5),
    }).then((_) {
      // After updating score, retrieve user's score
      FirebaseFirestore.instance
          .collection('users')
          .orderBy('score', descending: true)
          .get()
          .then((querySnapshot) {
        // Find index of current user in the sorted list
        int userIndex =
            querySnapshot.docs.indexWhere((doc) => doc.id == user!.uid);
        // Update user's rank
        int rank = userIndex + 1; // Adding 1 because index is 0-based
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'rank': rank}).then((_) {
          print('Rank updated successfully.');
        }).catchError((error) {
          print('Failed to update rank: $error');
        });
      }).catchError((error) {
        print('Failed to retrieve users: $error');
      });
    }).catchError((error) {
      print('Failed to update score: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Question of the day!'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color.fromARGB(255, 28, 45, 72),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.blueGrey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('questiontoday')
                        .doc(currentDay.toString())
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text('No data available'));
                      }
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      String question = data['question'] ?? '';
                      correctAnswer = data['correct'] ?? '';

                      List<String> choices = [
                        data['choice1'] ?? '',
                        data['choice2'] ?? '',
                        data['choice3'] ?? '',
                        correctAnswer
                      ];

                      if (shuffleChoices) {
                        choices.shuffle();
                        shuffledChoices = List.from(choices);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const Gap(20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: shuffledChoices
                                .asMap()
                                .entries
                                .map(
                                  (entry) => GestureDetector(
                                    onTap: () {
                                      if (!answerSelected) {
                                        setState(() {
                                          selectedAnswer = entry.value;
                                          answerSelected = true;
                                          shuffleChoices = false;
                                          choiceColors = {
                                            for (var choice in shuffledChoices)
                                              choice: choice == correctAnswer
                                                  ? Colors.green
                                                  : Colors.red
                                          };
                                        });

                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user!.uid)
                                            .update({
                                          'lastDate': DateTime.now().toString(),
                                        }).then((_) {
                                          // After updating lastDate, you can update score and rank
                                          if (entry.value == correctAnswer) {
                                            answered();
                                          }
                                        }).catchError((error) {
                                          print(
                                              'Failed to update lastDate: $error');
                                        });

                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 28, 45, 72),
                                            elevation: 4.0,
                                            shadowColor: Colors.blueGrey
                                                .withOpacity(0.5),
                                            title: Text(
                                              selectedAnswer == correctAnswer
                                                  ? 'Correct!'
                                                  : 'Wrong!',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  selectedAnswer ==
                                                          correctAnswer
                                                      ? 'assets/images/yes.png'
                                                      : 'assets/images/no.png',
                                                  height: 120,
                                                  width: 120,
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  selectedAnswer ==
                                                          correctAnswer
                                                      ? 'You got it right! +5 points'
                                                      : 'The correct answer is: $correctAnswer',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'OK',
                                                  style: TextStyle(
                                                      color: Color(0xFFff9906),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Container(
                                        height: 70,
                                        child: Card(
                                          elevation: 4,
                                          color: choiceColors[entry.value],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    entry.value,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      // color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  entry.value == selectedAnswer
                                                      ? Icons.check_box_rounded
                                                      : Icons
                                                          .check_box_outline_blank_rounded,
                                                  // color: Colors.white,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
