import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:etr_philearn_mad2/admin_screen/userslist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditUserPage extends StatefulWidget {
  final DocumentSnapshot user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController uname;
  late TextEditingController email;
  late TextEditingController password;
  bool showPassword = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    uname = TextEditingController(text: widget.user['uname']);
    email = TextEditingController(text: widget.user['email']);
    password = TextEditingController();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      setState(() {
        isAdmin = userSnapshot['type'] == 'admin';
      });
    }
  }

  @override
  void dispose() {
    uname.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
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

  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> updateUser() async {
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to edit users.',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (formKey.currentState!.validate()) {
      try {
        String uid = widget.user.id;
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'uname': uname.text,
          'email': email.text,
          if (password.text.isNotEmpty) 'password': password.text,
        });

        if (password.text.isNotEmpty) {
          User? user = FirebaseAuth.instance.currentUser;
          await user?.updatePassword(password.text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully',
                style: TextStyle(fontWeight: FontWeight.bold)),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserListPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user: $e',
                style: TextStyle(fontWeight: FontWeight.bold)),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: uname,
                decoration: const InputDecoration(
                    label: Text('Username'), border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              Gap(8),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(
                    label: Text('Email'), border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!EmailValidator.validate(value)) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              Gap(8),
              TextFormField(
                obscureText: showPassword,
                controller: password,
                decoration: setTextDecoration('Password', isPassword: true),
                style: const TextStyle(fontSize: 15),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 7) {
                    return 'Password should be more than 6 characters.';
                  }
                  return null;
                },
              ),
              const Gap(16),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    updateUser();
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(const Color(0xFFff9906)),
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
    );
  }
}
