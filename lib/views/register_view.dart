import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:untitled/constants/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _password;
  Color usernameIconColor = Colors.grey;
  Color emailIconColor = Colors.grey;
  Color passwordIconColor = Colors.grey;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _username = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    required IconData iconData,
    required Function(String) validator,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            iconData,
            color: iconColor,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: iconColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: iconColor),
          ),
        ),
        style: TextStyle(color: Colors.black),
        validator: (value) => validator(value!),
        onTap: () {
          setState(() {
            if (iconData == Icons.person) {
              usernameIconColor = Colors.blue;
              emailIconColor = Colors.grey;
              passwordIconColor = Colors.grey;
            } else if (iconData == Icons.email) {
              usernameIconColor = Colors.grey;
              emailIconColor = Colors.blue;
              passwordIconColor = Colors.grey;
            } else if (iconData == Icons.lock) {
              usernameIconColor = Colors.grey;
              emailIconColor = Colors.grey;
              passwordIconColor = Colors.blue;
            }
          });
        },
      ),
    );
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Zweryfikuj Email'),
          content: Column(
            children: [
              Text('Aby zakończyć proces rejestracji, zweryfikuj swój adres e-mail.'),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null && !user.emailVerified) {
                    await user.sendEmailVerification();
                    Navigator.of(context).pop();
                    _showEmailSentDialog();
                  }
                },
                child: Text('Wyślij Email Weryfikacyjny'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Email Weryfikacyjny Wysłany'),
          content: Text('Email weryfikacyjny został wysłany. Sprawdź swoją skrzynkę odbiorczą.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), backgroundColor: Colors.white),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('lib/assets/ic_logo.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
              ),
              _buildTextField(
                controller: _username,
                hintText: 'Username',
                isPassword: false,
                iconData: Icons.person,
                validator: (value) {
                  if (value.length < 10) {
                    return 'Minimum 10 characters required';
                  } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Only letters and digits allowed';
                  }
                  return null;
                },
                iconColor: usernameIconColor,
              ),
              SizedBox(height: 10.0),
              _buildTextField(
                controller: _email,
                hintText: 'E-mail',
                isPassword: false,
                iconData: Icons.email,
                validator: (value) {
                  if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
                    return 'Invalid email format';
                  }
                  return null;
                },
                iconColor: emailIconColor,
              ),
              SizedBox(height: 10.0),
              _buildTextField(
                controller: _password,
                hintText: 'Password',
                isPassword: true,
                iconData: Icons.lock,
                validator: (value) {
                  if (value.length < 8) {
                    return 'Minimum 8 characters required';
                  } else if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*[A-Z]).*$').hasMatch(value)) {
                    return 'Password must contain at least one digit, one special character, and one uppercase letter';
                  }
                  return null;
                },
                iconColor: passwordIconColor,
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final username = _username.text;
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                      await userCredential.user?.sendEmailVerification();
                      devtools.log(userCredential.toString());
                      _showEmailVerificationDialog();
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        devtools.log('This password is too weak');
                      } else if (e.code == 'email-already-in-use') {
                        devtools.log('This email is already in use');
                      } else if (e.code == 'invalid-email') {
                        devtools.log('Invalid email entered');
                      }
                    }
                  }
                },
                child: const Text('Sign Up'),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Already have an account? Log in here!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
