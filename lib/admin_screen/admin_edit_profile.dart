import 'package:etr_philearn_mad2/drawer_screen/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditProfileScreen extends StatefulWidget {
  const AdminEditProfileScreen({super.key});

  @override
  State<AdminEditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<AdminEditProfileScreen> {
  final uname = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final email = TextEditingController();
  bool showPassword = true;
  bool conshowPassword = true;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            uname.text = userDoc['uname'];
            email.text = currentUser.email ?? '';
          });
        } else {
          print('User document does not exist');
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void edit(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      return;
    }
    EasyLoading.show(status: 'Please Wait...');
    Future.delayed(const Duration(milliseconds: 500), () {
      EasyLoading.dismiss();
      editUserProfile(context);
    });
  }

  Future<void> editUserProfile(BuildContext context) async {
    EasyLoading.show(status: 'Saving your update');
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Update password in Authentication if changed
        if (password.text.isNotEmpty) {
          await currentUser.updatePassword(password.text);
        }
        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'uname': uname.text, 'password': password.text});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved successfully!',
                style: TextStyle(fontWeight: FontWeight.bold)),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileScreen()));
      }
    } on FirebaseAuthException catch (ex) {
      var errorTitle = '';
      var errorText = '';
      if (ex.code == 'weak-password') {
        errorText = 'Please enter a password with more than 6 characters';
        errorTitle = 'Weak Password';
      } else if (ex.code == 'email-already-in-use') {
        errorText = 'This email is already in use';
        errorTitle = 'Email Already in Use';
      } else if (ex.code == 'requires-recent-login') {
        errorText = 'Please log in again and try';
        errorTitle = 'Requires Recent Login';
      }

      print(errorTitle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
          backgroundColor: Colors.red,
        ),
      );
    } on FirebaseException catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving failed. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  InputDecoration setTextDecoration(String name, {bool isPassword = false}) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      label: Text(name),
      suffixIcon: isPassword
          ? IconButton(
              onPressed: toggleShowPassword,
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFFff9906),
              ),
            )
          : null,
    );
  }

  InputDecoration setTextDecoration2(String name, {bool isPassword2 = false}) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      label: Text(name),
      suffixIcon: isPassword2
          ? IconButton(
              onPressed: toggleShowPassword2,
              icon: Icon(
                conshowPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFFff9906),
              ),
            )
          : null,
    );
  }

  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void toggleShowPassword2() {
    setState(() {
      conshowPassword = !conshowPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double profileHeight = 144.0;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: profileHeight / 2,
                    backgroundColor: Colors.grey.shade800,
                    child:
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
                          String gender =
                              snapshot.data!.data()?['gender'] ?? '';
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
                  Gap(20),
                  TextFormField(
                    controller: uname,
                    decoration: setTextDecoration('User Name'),
                    style: const TextStyle(fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required. Enter your Username';
                      }
                      if (value.length < 5) {
                        return 'Username should be at least 5 characters.';
                      }
                      if (value.length > 10) {
                        return 'Username should be maximum 10 characters.';
                      }
                      return null;
                    },
                  ),
                  const Gap(8),
                  TextFormField(
                    obscureText: showPassword,
                    controller: password,
                    decoration: setTextDecoration('Password', isPassword: true),
                    style: const TextStyle(fontSize: 15),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 7) {
                        return 'Password should be more than 6 characters.';
                      }
                      return null;
                    },
                  ),
                  const Gap(8),
                  TextFormField(
                    obscureText: conshowPassword,
                    controller: confirmPassword,
                    decoration: setTextDecoration2('Confirm Password',
                        isPassword2: true),
                    style: const TextStyle(fontSize: 15),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          password.text != value) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () {
                      edit(context);
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
