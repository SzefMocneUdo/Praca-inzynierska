import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/constants/routes.dart';
import 'dart:developer' as devtools show log;

import 'package:untitled/main.dart';
import 'package:untitled/views/profile_view.dart';
import 'package:untitled/views/settings_view.dart';

import 'currencies_view.dart';
import 'expenses_view.dart';
import 'bottom_manu_view.dart';
import 'notifications_view.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({Key? key});

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        backgroundColor: Colors.purple,
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

