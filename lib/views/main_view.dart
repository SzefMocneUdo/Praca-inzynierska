import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/constants/routes.dart';
import 'package:untitled/main.dart';
import 'package:untitled/views/goals_view.dart';
import 'package:untitled/views/settings_view.dart';

import '../bottomNavBar.dart';
import 'currencies_view.dart';
import 'expenses_view.dart';
import 'home_view.dart';
import 'notifications_view.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 2;
  final List<Widget> screens = [
    CurrenciesView(),
    ExpensesView(),
    HomeView(),
    GoalsView(),
    SettingsView()
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: screens[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showBottomMenu(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.money_off),
                title: Text('Add new outcome'),
                onTap: () {
                  // Dodaj logikę dla opcji "Dodaj nowy wydatek"
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Add new income'),
                onTap: () {
                  // Dodaj logikę dla opcji "Dodaj nowy przychód"
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('Attach new credit card'),
                onTap: () {
                  // Dodaj logikę dla opcji "Dodaj kartę kredytową"
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.flag),
                title: Text('Add new saving goal'),
                onTap: () {
                  // Dodaj logikę dla opcji "Dodaj nowy cel"
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

