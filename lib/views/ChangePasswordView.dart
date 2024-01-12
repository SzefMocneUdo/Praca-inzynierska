import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/constants/routes.dart';

import 'NotificationsView.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({Key? key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: GestureDetector(
          child: Icon( Icons.arrow_back_ios, color: Colors.black,  ),
          onTap: () {
            Navigator.pop(context);
          } ,
        ) ,
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
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            SizedBox(height: 40),
            Row(
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  color: Colors.blue,
                ),
                SizedBox(width: 10),
                Text(
                  "Profile",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            Text(user!.email ?? 'No email available'),
            // buildOption(context, "Change photo"),
             buildOption(context, "Change password", updatePasswordRoute),
            // Divider(),
            // buildOption(context, "Log out"),
            // buildOption(context, "Delete account")
          ],
        ),
      ),
    );
  }

  GestureDetector buildOption(BuildContext context, String title, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text(title),
        //       content: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Text("Option 1"),
        //           Text("Option 2"),
        //         ],
        //       ),
        //       actions: [
        //         TextButton(
        //           onPressed: () {
        //                            },
        //           child: Text("Close"),
        //         ),
        //       ],
        //     );
        //   },
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Padding buildNotificationOption(String title, bool value, Function(bool) onChangeMethod) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[600]),
          ),
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              activeColor: Colors.blue,
              trackColor: Colors.grey,
              value: value,
              onChanged: onChangeMethod,
            ),
          )
        ],
      ),
    );
  }
}
