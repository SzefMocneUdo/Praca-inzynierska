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
  late String newPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios, color: Colors.black,),
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
            TextField(
              onChanged: (text){
                newPassword = text;
              },
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(hintText: 'New Password'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.updatePassword(newPassword);
                    print('Password updated successfully');
                  } else {
                    print('User not logged in');
                  }
                } catch (e) {
                  print('Failed to update password: $e');
                }
              },
              child: const Text('Update password'),
            ),
          ],
        )
    );
  }
}