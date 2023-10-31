import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

typedef void LogoutCallback();

class NavBar extends StatelessWidget {
  final VoidCallback onMainScreenPressed;
  final VoidCallback onExpensesPressed;
  final VoidCallback onCurrenciesPressed;
  final VoidCallback onSavingsPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSettingsPressed;
  final LogoutCallback onLogout;
  NavBar({Key? key, required this.onLogout, required this.onSettingsPressed, required this.onMainScreenPressed, required this.onExpensesPressed, required this.onCurrenciesPressed, required this.onSavingsPressed, required this.onNotificationsPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(user!.email ?? 'No email available'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(),
            ),
            decoration: BoxDecoration(), accountName: null,
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Main screen"),
            onTap: onMainScreenPressed,
          ),
          ListTile(
            leading: Icon(Icons.money),
            title: Text("Expenses"),
            onTap: onExpensesPressed,
          ),
          ListTile(
            leading: Icon(Icons.line_axis),
            title: Text("Currencies"),
            onTap: onCurrenciesPressed,
          ),
          ListTile(
            leading: Icon(Icons.savings),
            title: Text("Savings"),
            onTap: onSavingsPressed,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
            onTap: onNotificationsPressed,
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: 20,
                height: 20,
                child: Text(
                  '8',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12
                  )
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: onSettingsPressed,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Log out"),
            onTap: () {
            onLogout(); // Wywołaj funkcję zwrotną przy naciśnięciu przycisku "Log out"
          },
          )
        ],
      ),
    );
  }
}
