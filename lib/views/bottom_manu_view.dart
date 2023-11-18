import 'package:flutter/material.dart';
import 'package:untitled/views/settings_view.dart';

import 'addExpenseScreen.dart';
import 'addIncomeScreen.dart';
import 'currencies_view.dart';
import 'transactions_view.dart';
import 'goals_view.dart';
import 'home_view.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 2;
  final List<Widget> screens = [
    // Replace with your desired widgets
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
      color: Colors.blueAccent, // Set your desired color
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
                title: Text('Add new outcome'),
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
                title: Text('Add new income'),
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
                title: Text('Attach new credit card'),
                onTap: () {
                  Navigator.pop(context);
                  // Add your navigation logic
                },
              ),
              ListTile(
                leading: Icon(Icons.flag),
                title: Text('Add new saving goal'),
                onTap: () {
                  Navigator.pop(context);
                  // Add your navigation logic
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final Color color;
  final List<String> tabLabels = ['Currency', 'Transactions', 'Home','Goals', 'Setting'];

  CustomBottomAppBar({
    required this.selectedIndex,
    required this.onTabChange,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: color,
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabIconButton(Icons.cached, 0),
          _buildTabIconButton(Icons.attach_money, 1),
          _buildTabIconButton(Icons.flag, 3),
          _buildTabIconButton(Icons.settings, 4),
        ],
      ),
    );
  }

  Widget _buildTabIconButton(IconData icon, int index) {
    bool isSelected = selectedIndex == index && index != 2 ; // Check if the tab is selected and not the home

    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () => onTabChange(index),
          color: isSelected ? Colors.white : Colors.grey,
          tooltip: tabLabels[index],
        ),
        if (isSelected) // Display the label only for the selected tab
          Text(
            tabLabels[index],
            style: TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}
