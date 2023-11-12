import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Expense'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date'),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Dodaj logikę do zapisu wydatku do systemu
                _addExpense();
              },
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _addExpense() {
      try {
        // Pobierz aktualnie zalogowanego użytkownika
        User? user = FirebaseAuth.instance.currentUser;

        // Sprawdź, czy użytkownik jest zalogowany
        if (user != null) {
          // Pobierz instancję Firestore
          FirebaseFirestore firestore = FirebaseFirestore.instance;

          // Utwórz dokument w kolekcji "expenses" z danymi
          firestore.collection('expenses').add({
            'userId': user.uid,
            'date': _dateController.text,
            'amount': double.parse(_amountController.text),
            'category': _categoryController.text,
            'description': _descriptionController.text,
          });

          print('Expense added successfully!');

        } else {
          print('User not logged in.');
        }
      } catch (e) {
        print('Error adding expense: $e');
      }
      Navigator.pop(context);
    }
}
