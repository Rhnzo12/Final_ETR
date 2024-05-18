import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/admin_screen/questiontoday_list.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditCurQuestion extends StatefulWidget {
  final String questionId;

  const EditCurQuestion({required this.questionId, super.key});

  @override
  State<EditCurQuestion> createState() => _EditCurQuestionState();
}

class _EditCurQuestionState extends State<EditCurQuestion> {
  final formKey = GlobalKey<FormState>();
  final quest = TextEditingController();
  final corr = TextEditingController();
  final choice1 = TextEditingController();
  final choice2 = TextEditingController();
  final choice3 = TextEditingController();

  InputDecoration setTextDecoration(String name) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      label: Text(name),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTodayQuestionData();
  }

  Future<void> fetchTodayQuestionData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('curQuestion')
          .doc(widget.questionId)
          .get();
      setState(() {
        quest.text = doc['question'];
        corr.text = doc['correct'];
        choice1.text = doc['choice1'];
        choice2.text = doc['choice2'];
        choice3.text = doc['choice3'];
      });
    } catch (e) {
      print('Error fetching question today data: $e');
    }
  }

  Future<void> updateQuestion() async {
    try {
      await FirebaseFirestore.instance
          .collection('curQuestion')
          .doc(widget.questionId)
          .update({
        'question': quest.text,
        'correct': corr.text,
        'choice1': choice1.text,
        'choice2': choice2.text,
        'choice3': choice3.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question updated successfully',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListQuestionToday()),
      );
    } catch (e) {
      print('Error updating question: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating question: $e',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('Manage Current Events Question'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: quest,
                    decoration: setTextDecoration('Question'),
                    style: const TextStyle(fontSize: 15),
                    maxLines: 20,
                    minLines: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required. Please enter question';
                      }
                      return null;
                    },
                  ),
                  const Gap(8),
                  TextFormField(
                    controller: corr,
                    decoration: setTextDecoration('Correct Answer'),
                    style: const TextStyle(fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required. Please enter correct answer';
                      }
                      return null;
                    },
                  ),
                  const Gap(8),
                  TextFormField(
                    controller: choice1,
                    decoration: setTextDecoration('Choice 1'),
                    style: const TextStyle(fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required. Please enter choice 1';
                      }
                      return null;
                    },
                  ),
                  const Gap(8),
                  TextFormField(
                    controller: choice2,
                    decoration: setTextDecoration('Choice 2'),
                    style: const TextStyle(fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required. Please enter choice 2';
                      }
                      return null;
                    },
                  ),
                  const Gap(8),
                  TextFormField(
                    controller: choice3,
                    decoration: setTextDecoration('Choice 3'),
                    style: const TextStyle(fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required. Please enter choice 3';
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        updateQuestion();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFFff9906)),
                      elevation: WidgetStateProperty.all<double>(4.0),
                      shadowColor: WidgetStateProperty.all<Color>(Colors.black),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
