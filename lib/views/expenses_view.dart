import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/Expense.dart';
import 'expenseDetails.dart';
import 'notifications_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/Expense.dart';
import 'notifications_view.dart';
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
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the user is logged in
      if (user != null) {
        // Get the Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Get all documents from the "expenses" collection for the user
        QuerySnapshot querySnapshot = await firestore
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .get();

        // Transform data from documents to a list of expenses
        List<Expense> userExpenses = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Perform null checks before accessing properties
          return Expense(
            userId: data['userId'] ?? '',
            name: data['name'] ?? '',
            date: (data['date'] as Timestamp).toDate(),
            amount: data['amount'] != null ? data['amount'].toDouble() : 0.0,
            category: data['category'] ?? '',
            description: data['description'] ?? '',
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
        title: const Text('List of expenses'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('List of expenses', style: TextStyle(fontSize: 20.0)),
          ),
          if (expenses.isEmpty)
            Center(
              child: Text('No expenses available'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(expenses[index].name),
                          SizedBox(width: 10),
                          Text(':'),
                          SizedBox(width: 10),
                          Text('${expenses[index].amount}'),
                        ],
                      ),
                    ),
                    onTap: () {
                      // Show expense details as a smaller dialog
                      ExpenseDetailsDialog(expense: expenses[index]).show(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}