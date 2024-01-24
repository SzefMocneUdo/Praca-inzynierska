import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'NotificationsView.dart';

class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({Key? key});

  @override
  State<UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _repeatNewPasswordController = TextEditingController();

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

  void updatePassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String value = _newPasswordController.text;
      String repeatValue = _repeatNewPasswordController.text;
      if (user != null) {
        if (value.length < 8 || repeatValue.length < 8) {
          _messages.add('Minimum 8 characters required for password');
          _showDialog(_messages, "Update password error");
          _messages = [];
        } else if (!RegExp(
                    r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*[A-Z]).*$')
                .hasMatch(value) ||
            !RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*[A-Z]).*$')
                .hasMatch(repeatValue)) {
          _messages.add(
              'Password must contain at least one digit, one special character, and one uppercase letter');
          _showDialog(_messages, "Update password error");
          _messages = [];
        } else if (value != repeatValue) {
          _messages.add('Passwords must be the same');
          _showDialog(_messages, "Update password error");
          _messages = [];
        } else {
          await user.updatePassword(value);
          _messages.add('Password updated successfully');
          _showDialog(_messages, "Done!");
          _messages = [];
        }
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Failed to update password: $e');
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: "New password",
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
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Change password'),
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
                  'Type new password:',
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
                  label: "New password", controller: _newPasswordController),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type new password again:',
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
                  label: "New password",
                  controller: _repeatNewPasswordController),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                updatePassword();
              },
              child: const Text('Update password'),
            ),
          ],
        ));
  }
}
