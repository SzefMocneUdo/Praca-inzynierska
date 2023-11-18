import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:untitled/constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  Color emailBorderColor = Colors.grey;
  Color passwordBorderColor = Colors.grey;
  Color emailIconColor = Colors.grey;
  Color passwordIconColor = Colors.grey;

  String? loginErrorMessage;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    required IconData iconData,
    required Function(String) validator,
    required Color borderColor,
    required Color iconColor,
    Widget? prefixWidget,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextField(
        controller: controller,
        enableSuggestions: false,
        keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
        autocorrect: false,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixWidget != null ? Padding(padding: const EdgeInsets.all(8.0), child: prefixWidget) : Icon(iconData, color: iconColor),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: borderColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
        style: TextStyle(color: Colors.black),
        onTap: () {
          setState(() {
            if (controller == _email) {
              emailBorderColor = Colors.blue;
              passwordBorderColor = Colors.grey;
              emailIconColor = Colors.blue;
              passwordIconColor = Colors.grey;
            } else if (controller == _password) {
              emailBorderColor = Colors.grey;
              passwordBorderColor = Colors.blue;
              emailIconColor = Colors.grey;
              passwordIconColor = Colors.blue;
            }
            loginErrorMessage = null; // Reset the error message when the user taps on the text field
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.white),
      body: Center(
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
            SizedBox(height: 20.0),
            _buildTextField(
              controller: _email,
              hintText: 'E-mail',
              isPassword: false,
              iconData: Icons.email,
              validator: (value) {
                return null; // Add your validation logic here
              },
              borderColor: emailBorderColor,
              iconColor: emailIconColor,
            ),
            SizedBox(height: 10.0),
            _buildTextField(
              controller: _password,
              hintText: 'Password',
              isPassword: true,
              iconData: Icons.lock,
              validator: (value) {
                return null; // Add your validation logic here
              },
              borderColor: passwordBorderColor,
              iconColor: passwordIconColor,
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                  if (userCredential.user?.emailVerified ?? false) {
                    Navigator.of(context).pushNamedAndRemoveUntil(mainRoute, (route) => false);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Account not verified'),
                          content: Text('Please verify your email before logging in.'),
                          actions: [
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Send verification email'),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                    setState(() {
                      loginErrorMessage = 'Incorrect login credentials';
                    });
                    Future.delayed(Duration.zero, () {
                      _showErrorDialog(loginErrorMessage!);
                    });
                  }
                }
              },
              child: const Text('LogIn'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not registered yet? Register here!'),
            ),
          ],
        ),
      ),
    );
  }
}
