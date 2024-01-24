import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/Currency.dart';
import 'NotificationsView.dart';

class AddFinancialGoalScreen extends StatefulWidget {
  @override
  _AddFinancialGoalScreenState createState() => _AddFinancialGoalScreenState();
}

class _AddFinancialGoalScreenState extends State<AddFinancialGoalScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  DateTime? selectedDate;

  final CollectionReference goalsCollection =
      FirebaseFirestore.instance.collection('goals');

  List<Currency> currencies = [
    Currency(code: 'USD', name: 'US Dollar'),
    Currency(code: 'EUR', name: 'Euro'),
    Currency(code: 'GBP', name: 'British Pound'),
  ];

  Currency? selectedCurrency;

  Future<String> _generateGoalId() async {
    String dataToHash =
        '${nameController.text}${amountController.text}${selectedCurrency?.code}${selectedDate?.millisecondsSinceEpoch}';
    Digest md5Result = md5.convert(Utf8Encoder().convert(dataToHash));
    return md5Result.toString();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addGoal(BuildContext context) async {
    if (nameController.text.isEmpty ||
        amountController.text.isEmpty ||
        selectedCurrency == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0;

    if (amount.isNaN || amount.isInfinite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid amount. Please enter a valid number.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String goalId = await _generateGoalId();

    Map<String, dynamic> goalData = {
      'name': nameController.text,
      'amount': amount,
      'currency': selectedCurrency!.code,
      'deadline': Timestamp.fromDate(selectedDate!),
      'id': goalId
    };

    try {
      await goalsCollection.doc(goalId).set({
        ...goalData,
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Financial goal added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding financial goal. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Financial Goal'),
        backgroundColor: Colors.blueAccent,
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<Currency>(
              value: selectedCurrency,
              onChanged: (Currency? newValue) {
                setState(() {
                  selectedCurrency = newValue;
                });
              },
              items: currencies.map<DropdownMenuItem<Currency>>(
                (Currency currency) {
                  return DropdownMenuItem<Currency>(
                    value: currency,
                    child: Text(currency.name),
                  );
                },
              ).toList(),
              decoration: InputDecoration(labelText: 'Currency'),
              validator: (value) {
                if (value == null) {
                  return 'Currency is required';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Deadline:'),
                SizedBox(width: 8),
                Text(
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _addGoal(context),
              child: Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
