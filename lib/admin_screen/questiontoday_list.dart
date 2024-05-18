import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/admin_screen/admin_management/todayedit.dart';
import 'package:flutter/material.dart';

class ListQuestionToday extends StatefulWidget {
  const ListQuestionToday({super.key});

  @override
  State<ListQuestionToday> createState() => _ListQuestionTodayState();
}

class _ListQuestionTodayState extends State<ListQuestionToday> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('Question Today List'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('questiontoday').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No questions found'));
          }

          final questions = snapshot.data!.docs;

          //convert document IDs to integers for sorting because in Firestore
          // it's treated as a string
          int getDocumentIdAsInt(DocumentSnapshot doc) {
            return int.tryParse(doc.id) ?? 0;
          }

          // Sorting documents by document ID converted to integers
          questions.sort(
              (a, b) => getDocumentIdAsInt(a).compareTo(getDocumentIdAsInt(b)));

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              var question = questions[index];
              return Card(
                elevation: 4,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditQuestionToday(questionId: question.id),
                      ),
                    );
                  },
                  title: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(
                          text: 'Question: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${question['question'] ?? 'No question text'}',
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    'Day: ${question.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Card(
                    elevation: 3,
                    color: Colors.grey.shade400,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
