import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'notifications_view.dart';

class Expense {
  final String userId;
  final String date;
  final double amount;
  final String category;
  final String description;

  Expense({
    required this.userId,
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
  });
}

class ExpensesView extends StatefulWidget {
  const ExpensesView({Key? key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    try {
      // Pobierz aktualnie zalogowanego użytkownika
      User? user = FirebaseAuth.instance.currentUser;

      // Sprawdź, czy użytkownik jest zalogowany
      if (user != null) {
        // Pobierz instancję Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Pobierz wszystkie dokumenty z kolekcji "expenses" dla danego użytkownika
        QuerySnapshot querySnapshot = await firestore
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .get();

        // Przekształć dane z dokumentów do listy wydatków
        List<Expense> userExpenses = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Expense(
            userId: data['userId'],
            date: data['date'],
            amount: data['amount'],
            category: data['category'],
            description: data['description'],
          );
        }).toList();

        setState(() {
          expenses = userExpenses;
        });
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
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
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Amount: ${expenses[index].amount}'),
            subtitle: Text('Category: ${expenses[index].category}'),
            // Dodaj inne pola, które chcesz wyświetlić
          );
        },
      ),
    );
  }
}
