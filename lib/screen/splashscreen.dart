import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etr_philearn_mad2/admin_screen/admin_home.dart';
import 'package:etr_philearn_mad2/drawer_screen/home.dart';
import 'package:etr_philearn_mad2/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progressValue = 0.0;
  int progressStep = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    startProgress();
    checkAuthentication();
  }

  void startProgress() {
    const duration = Duration(milliseconds: 500);
    const totalSteps = 10;
    for (int i = 0; i < totalSteps; i++) {
      Future.delayed(duration * i, () {
        setState(() {
          progressStep++;
          progressValue = progressStep / totalSteps;
        });
      });
    }
  }

  void checkAuthentication() async {
    await Future.delayed(const Duration(
        milliseconds: 500 * 10)); // Wait for progress to complete
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      var data = document.data();

      if (data != null) {
        Widget landing;
        if (data['type'] == 'user') {
          landing = HomeScreen(userId: userId);
        } else {
          landing = AdminHomeScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => landing),
        );
      } else {
        // Handle the case where user data is not found in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'User data not found!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 500,
                  height: 500,
                ),
                const Gap(20),
                LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 17,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFff9906)),
                ),
                const Gap(10),
                Text(
                  '${(progressValue * 100).toInt()}%',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
