import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PhilSummaryScreen extends StatelessWidget {
  final List<Map<String, String>> questionHistory;

  const PhilSummaryScreen({super.key, required this.questionHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Summary'),
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
          ListView.builder(
            itemCount: questionHistory.length,
            itemBuilder: (context, index) {
              final questionData = questionHistory[index];
              final question = questionData['question'];
              final selectedAnswer =
                  questionData['selectedAnswer'] ?? ''; // default value
              final correctAnswer = questionData['correctAnswer'];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question: $question',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            // color: Colors.white,
                          ),
                        ),
                        Gap(8),
                        _buildAnswerCard('Your Answer: $selectedAnswer'),
                        Gap(8),
                        _buildAnswerCard('Correct Answer: $correctAnswer',
                            correct: true),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(String text, {bool correct = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: correct ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: correct ? Colors.green : Colors.red),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.0,
          color: correct ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
