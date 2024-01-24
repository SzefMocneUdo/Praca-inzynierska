import 'package:flutter/material.dart';
import 'package:untitled/views/SettingsView.dart';

import 'AddCreditCardScreen.dart';
import 'AddExpenseScreen.dart';
import 'AddFinancialGoalScreen.dart';
import 'AddIncomeScreen.dart';
import 'CurrenciesView.dart';
import 'CustomBottomAppBar.dart';
import 'GoalsView.dart';
import 'HomeView.dart';
import 'TransactionsView.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 2;
  final List<Widget> screens = [
    CurrenciesView(),
    Transactions(),
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
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      height: 65.0,
      width: 65.0,
      child: FittedBox(
        child: GestureDetector(
          onLongPress: () {
            _showBottomMenu(context);
          },
          child: ClipOval(
            child: FloatingActionButton(
              onPressed: () {
                _onItemTapped(2);
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return CustomBottomAppBar(
      color: Colors.blueAccent,
      selectedIndex: _selectedIndex,
      onTabChange: _onItemTapped,
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
                title: Text('Add a new expense'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddExpenseScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Add an new income'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddIncomeScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('Attach a new credit card'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCreditCardScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.flag),
                title: Text('Add a new saving goal'),
                onTap: () async {
                  Navigator.pop(context);
                  bool goalAdded = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFinancialGoalScreen(),
                    ),
                  );

                  if (goalAdded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Goal added successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    _onItemTapped(2);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
