import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'NotificationsView.dart';

class UpdateEmailView extends StatefulWidget {
  const UpdateEmailView({Key? key});

  @override
  State<UpdateEmailView> createState() => _UpdateEmailViewState();
}

class _UpdateEmailViewState extends State<UpdateEmailView> {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController _newEmailController = TextEditingController();
  TextEditingController _repeatNewEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  List<String> _messages = [];

  void _showDialog(List<String> errorMessages, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:
                errorMessages.map((message) => Text('- $message')).toList(),
          ),
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

  Future<bool> isEmailAvailable(String newEmail) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: newEmail)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error occured when checking e-mail availability: $e');
      return false;
    }
  }

  void updateEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String value = _newEmailController.text;
        String repeatValue = _repeatNewEmailController.text;
        if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                .hasMatch(value) ||
            !RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                .hasMatch(repeatValue)) {
          _messages.add('Invalid e-mail format');
          _showDialog(_messages, "Error");
          _messages = [];
        } else if (value != repeatValue) {
          _messages.add('Both values must be the same');
          _showDialog(_messages, "Error");
          _messages = [];
        } else {
          bool isAvailable = await isEmailAvailable(value);
          if (isAvailable) {
            bool isPasswordCorrect = await verifyCurrentPassword(_passwordController.text);
            if(isPasswordCorrect){
              await FirebaseAuth.instance.currentUser!
                  .reauthenticateWithCredential(
                EmailAuthProvider.credential(
                  email: FirebaseAuth.instance.currentUser!.email!,
                  password: _passwordController.text,
                ),
              );
              await user.updateEmail(_newEmailController.text);
              _messages.add('E-mail updated successfully');
              _showDialog(_messages, "Done!");
              _messages = [];
            } else{
              _messages.add('Password is not correct');
              _showDialog(_messages, "Error");
              _messages = [];
              print(_passwordController.text);
            }

          } else {
            _messages.add('E-mail is already taken');
            _showDialog(_messages, "Error");
            _messages = [];
          }
        }
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Failed to update e-mail: $e');
    }
  }


  Future<bool> verifyCurrentPassword(String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: FirebaseAuth.instance.currentUser!.email!,
        password: password,
      );
      return true;
    } catch (error) {
      print('Wrong password: $error');
      return false;
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required obscureText,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.grey, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      validator: validator,
      enableSuggestions: false,
      autocorrect: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Change e-mail'),
          backgroundColor: Colors.blueAccent,
          leading: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NotificationsView(),
                ));
              },
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type new e-mail:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.all(8),
              child: _buildTextField(
                  label: "New e-mail",
                  controller: _newEmailController,
                  hintText: "New e-mail", obscureText: false),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type new e-mail again:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: _buildTextField(
                  label: "New e-mail",
                  controller: _repeatNewEmailController,
                  hintText: "New e-mail", obscureText: false),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type password:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: _buildTextField(
                  label: "Password",
                  controller: _passwordController,
                  hintText: "Password", obscureText: true),
            ),
            ElevatedButton(
              onPressed: () async {
                updateEmail();
              },
              child: const Text('Update e-mail'),
            ),
          ],
        ));
  }
}
