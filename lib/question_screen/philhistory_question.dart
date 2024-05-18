import 'dart:async';
import 'package:etr_philearn_mad2/question_screen/summary_asnwer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';

class PhilHistoryQuestionScreen extends StatefulWidget {
  const PhilHistoryQuestionScreen({super.key});

  @override
  State<PhilHistoryQuestionScreen> createState() =>
      _PhilHistoryQuestionScreenState();
}

class _PhilHistoryQuestionScreenState extends State<PhilHistoryQuestionScreen> {
  late int philcurrentDay;
  late String correctAnswer;
  String? selectedAnswer;
  bool answerSelected = false;
  bool shuffleChoices = true;
  late List<String> shuffledChoices;
  late Map<String, Color?> choiceColors;
  late User? user;
  int questionNumber = 1;
  int totalQuestions = 10;
  int score = 0;
  List<Map<String, String>> questionHistory = [];
  late Timer _timer = Timer(Duration.zero, () {});
  late ValueNotifier<int> _secondsNotifier;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    DateTime now = DateTime.now();
    philcurrentDay = now.day;
    shuffledChoices = [];
    choiceColors = {};
    fetchQuestionData(questionNumber);
    _secondsNotifier = ValueNotifier<int>(30);
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _secondsNotifier.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    if (_timer.isActive) {
      _timer.cancel();
    }
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_secondsNotifier.value == 0) {
          timer.cancel();
          if (!answerSelected) {
            // if the user has not selected an answer, move to the next question
            goToNextQuestion();
          }
        } else {
          _secondsNotifier.value -= 1;
        }
      },
    );
  }

  void fetchQuestionData(int questionNumber) {
    FirebaseFirestore.instance
        .collection('philQuestion')
        .doc(questionNumber.toString())
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        String question = data['question'] ?? '';
        correctAnswer = data['correct'] ?? '';

        List<String> choices = [
          data['choice1'] ?? '',
          data['choice2'] ?? '',
          data['choice3'] ?? '',
          correctAnswer
        ];

        setState(() {
          questionHistory.add({
            'question': question,
            'selectedAnswer': selectedAnswer ?? '',
            'correctAnswer': correctAnswer,
          });
          if (shuffleChoices) {
            choices.shuffle();
            shuffledChoices = List.from(choices);
          }
          _secondsNotifier.value = 30;
        });
      } else {
        print('Document does not exist in the database');
      }
    }).catchError((error) {
      print('Error fetching document: $error');
    });
  }

  void Answered() {
    // Increment the user's score and update the answered timestamp
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'score': FieldValue.increment(1),
      'philAnswered': DateTime.now().toString(),
    }).then((_) {
      // If the operation was successful, update the local score state
      if (mounted) {
        setState(() {
          score++;
        });

        // Fetch all users and their scores
        FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true)
            .get()
            .then((querySnapshot) {
          int rank = 1;
          for (int i = 0; i < querySnapshot.docs.length; i++) {
            var doc = querySnapshot.docs[i];
            var userId = doc.id;

            // Compare current user's score with other users' scores
            if (userId == user!.uid) {
              // Update the rank
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .update({'rank': rank}).then((_) {
                print('Rank updated successfully.');
              }).catchError((error) {
                print('Error updating rank: $error');
              });
              break; // Stop loop once the user's rank is set
            }

            // If current user's score is lower, increment the rank
            if (doc.data()['score'] < score) {
              rank++;
            }
          }
        }).catchError((error) {
          print('Error retrieving users: $error');
        });
      }
    }).catchError((error) {
      print('Error updating score: $error');
    });
  }

  void goToNextQuestion() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          selectedAnswer = null;
          answerSelected = false;
          shuffleChoices = true;
          questionNumber++;
          if (questionNumber <= totalQuestions) {
            fetchQuestionData(questionNumber);
          }
          startTimer();
        });
      }
    });
  }

  void gotoSummary() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PhilSummaryScreen(questionHistory: questionHistory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Philippine History'),
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
          ValueListenableBuilder<int>(
            valueListenable: _secondsNotifier,
            builder: (context, value, child) {
              double progress = value / 30.0; // 30 seconds timer
              return LinearProgressIndicator(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                minHeight: 15,
                value: progress,
                backgroundColor: Colors.grey[600],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFff9906)),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('philQuestion')
                              .doc(questionNumber.toString())
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              if (questionNumber > totalQuestions) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Congratulations!',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Gap(10),
                                    Image.asset(
                                      'assets/images/yes.png',
                                      height: 200,
                                      width: 200,
                                    ),
                                    const Gap(20),
                                    Text(
                                      'Your Score: $score/$totalQuestions',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Gap(15),
                                    ElevatedButton(
                                      onPressed: gotoSummary,
                                      child: const Text('Show Summary'),
                                    )
                                  ],
                                );
                              }
                              return const Center(
                                  child: Text('No data available'));
                            }
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String question = data['question'] ?? '';
                            correctAnswer = data['correct'] ?? '';

                            List<String> choices = [
                              data['choice1'] ?? '',
                              data['choice2'] ?? '',
                              data['choice3'] ?? '',
                              correctAnswer = data['correct'] ?? ''
                            ];
                            print(choices);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(5),
                                Text(
                                  question,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Gap(15),
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
                                                  for (var choice
                                                      in shuffledChoices)
                                                    choice:
                                                        choice == correctAnswer
                                                            ? Colors.green
                                                            : Colors.red
                                                };
                                              });
                                              if (selectedAnswer ==
                                                  correctAnswer) {
                                                Answered();
                                              }

                                              questionHistory
                                                      .last['selectedAnswer'] =
                                                  selectedAnswer ?? '';
                                              goToNextQuestion();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Container(
                                              height: 70,
                                              child: Card(
                                                elevation: 4,
                                                color:
                                                    choiceColors[entry.value],
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          entry.value,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                        entry.value ==
                                                                selectedAnswer
                                                            ? Icons
                                                                .check_box_rounded
                                                            : Icons
                                                                .check_box_outline_blank_rounded,
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
                      ],
                    ),
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
