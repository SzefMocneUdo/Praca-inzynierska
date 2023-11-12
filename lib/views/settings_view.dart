import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/constants/routes.dart';
import 'package:untitled/main.dart';
import 'dart:developer' as devtools show log;

import 'package:untitled/views/currencies_view.dart';
import 'package:untitled/views/expenses_view.dart';
import 'package:untitled/views/main_view.dart';
import 'package:untitled/views/notifications_view.dart';
import 'package:untitled/views/profile_view.dart';
import 'package:untitled/views/goals_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool valueDarkTheme = false;
  bool valueNotifications = false;

  void onChangeFunctionDarkTheme(bool newValue) {
    setState(() {
      valueDarkTheme = newValue;
    });
  }

  void onChangeFunctionNotifications(bool newValue) {
    setState(() {
      valueNotifications = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsView()));
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
                  Icons.settings,
                  color: Colors.blue,
                ),
                SizedBox(width: 10),
                Text(
                  "Settings",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            buildOption(context, "Profile Settings", profileRoute),
            buildNotificationOption("Notifications", valueNotifications, onChangeFunctionNotifications),
            buildNotificationOption("Dark theme", valueDarkTheme, onChangeFunctionDarkTheme),
            buildOption(context, "Privacy and Security", privacyAndSecurityRoute),
            buildOption(context, "Help", helpRoute),
            buildLogoutOption(context),
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
  GestureDetector buildLogoutOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Implement logout functionality here
        FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );

      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Colors.red, // Customize the color as needed
                ),
                SizedBox(width: 10),
                Text(
                  "Logout",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red), // Customize the color as needed
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

