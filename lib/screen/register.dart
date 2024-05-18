import 'package:etr_philearn_mad2/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

import 'package:gap/gap.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final uname = TextEditingController();
  final email = TextEditingController();
  final gender = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool showPassword = true;
  bool conshowPassword = true;
  String? _selectedGender;
  List<String> genderOptions = ['Male', 'Female', 'Other'];

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

  void register() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    EasyLoading.show(status: 'Please Wait...');
    Future.delayed(const Duration(milliseconds: 500), () {
      EasyLoading.dismiss();
      registerUser();
    });
  }

  Future<void> registerUser() async {
    EasyLoading.show(status: 'Registering your account');

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text);
      // Firestore add document
      String userId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'uname': uname.text,
        'email': email.text,
        'gender': _selectedGender,
        'password': password.text,
        'uid': userId,
        'curAnswered': '',
        'philAnswered': '',
        'score': '0',
        'lastDate': '',
        'type': 'user'
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registered successfully!',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (ex) {
      var errorTitle = '';
      var errorText = '';
      if (ex.code == 'weak-password') {
        errorText = 'Please enter a password with more than 6 characters';
        errorTitle = 'Weak Password';
      } else if (ex.code == 'email-already-in-use') {
        errorText = 'Password is already registered';
        errorTitle = 'Please enter a new email.';
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
          content: Text('Registration failed. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: Text('Register'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/bg1.png'),
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
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(20),
                      const Text(
                        'Register',
                        style: TextStyle(fontSize: 25),
                      ),
                      const Gap(12),
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
                        // maxLength: 10,
                      ),
                      const Gap(8),
                      TextFormField(
                        controller: email,
                        decoration: setTextDecoration('Email Address'),
                        style: const TextStyle(fontSize: 15),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required. Enter your email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const Gap(8),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        decoration: setTextDecoration('Gender'),
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                        items: genderOptions.map((gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(
                              gender,
                              style: TextStyle(
                                color: theme.brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required. Choose Gender';
                          }
                          return null;
                        },
                      ),
                      const Gap(8),
                      TextFormField(
                        obscureText: showPassword,
                        controller: password,
                        decoration:
                            setTextDecoration('Password', isPassword: true),
                        style: const TextStyle(fontSize: 15),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required. Enter your Password';
                          }
                          if (value.length < 7) {
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
                          if (value == null || value.isEmpty) {
                            return 'Required. Comfirm your Password';
                          }
                          if (password.text != value) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                      const Gap(10),
                      ElevatedButton(
                        onPressed: register,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color(0xFFff9906)),
                          elevation: WidgetStateProperty.all<double>(4.0),
                          shadowColor:
                              WidgetStateProperty.all<Color>(Colors.black),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Have an Account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()));
                            },
                            child: const Text(
                              'Login here',
                              style: TextStyle(color: Color(0xFFff9906)),
                            ),
                          ),
                        ],
                      ),
                    ],
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
