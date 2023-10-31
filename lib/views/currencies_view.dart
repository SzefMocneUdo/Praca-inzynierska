import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/constants/routes.dart';
import 'dart:developer' as devtools show log;

import 'package:untitled/main.dart';
import 'package:untitled/navBar.dart';
import 'package:untitled/views/profile_view.dart';
import 'package:untitled/views/savings_view.dart';
import 'package:untitled/views/settings_view.dart';

import 'expenses_view.dart';
import 'main_view.dart';
import 'notifications_view.dart';

class CurrenciesView extends StatefulWidget {
  const CurrenciesView({Key? key});

  @override
  State<CurrenciesView> createState() => _CurrenciesViewState();
}

class _CurrenciesViewState extends State<CurrenciesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        onLogout: () async {
          final shouldLogOut = await showLogOutDialog(context);
          if (shouldLogOut) {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
          }
          devtools.log(shouldLogOut.toString());
        },
        onSettingsPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SettingsView(),
          ));
        }, onMainScreenPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MainView(),
        ));
      }, onExpensesPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ExpensesView(),
        ));
      }, onCurrenciesPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CurrenciesView(),
        ));
      }, onSavingsPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SavingsView(),
        ));
      }, onNotificationsPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NotificationsView(),
        ));
      },
      ),
      appBar: AppBar(
        title: const Text('Currencies'),
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

