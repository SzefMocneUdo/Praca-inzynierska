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
  List<String> _errorMessages = [];

  void updatePassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String value = _newPasswordController.text;
      if (user != null) {
        if (value.length < 8) {
          _errorMessages.add('Minimum 8 characters required for password');
        } else if (!RegExp(
                r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*[A-Z]).*$')
            .hasMatch(value)) {
          _errorMessages.add(
              'Password must contain at least one digit, one special character, and one uppercase letter');
        } else {
          await user.updatePassword(value);
          print('Password updated successfully');
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
