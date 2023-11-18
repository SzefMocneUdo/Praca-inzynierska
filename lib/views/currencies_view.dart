import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Currencies'),
        backgroundColor: Colors.blueAccent,
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

