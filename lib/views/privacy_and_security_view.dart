import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'notifications_view.dart';

class PrivacyAndSecurityView extends StatefulWidget {
  const PrivacyAndSecurityView({Key? key});

  @override
  State<PrivacyAndSecurityView> createState() => _PrivacyAndSecurityViewState();
}

class _PrivacyAndSecurityViewState extends State<PrivacyAndSecurityView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy and Security'),
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
    );
  }
}

