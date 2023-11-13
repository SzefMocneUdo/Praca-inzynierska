// AddExpenseScreen class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}
class _AddExpenseScreenState extends State<AddExpenseScreen> {
  TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Expense'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _dateController.text =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Date is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Amount is required';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Invalid amount format';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Category is required';
                  }
                  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                    return 'Only letters are allowed';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addExpense();
                  }
                },
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addExpense() {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the user is logged in
      if (user != null) {
        // Get the Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Create a document in the "expenses" collection with the data
        firestore.collection('expenses').add({
          'userId': user.uid,
          'name': _nameController.text,
          'date': _selectedDate,
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

    // Pop the screen to go back
    Navigator.pop(context);
  }
}
