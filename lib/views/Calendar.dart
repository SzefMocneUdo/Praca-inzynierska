import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/Expense.dart';
import '../model/FinancialItem.dart';
import '../model/Income.dart';

class TransactionCalendar extends StatefulWidget {
  @override
  _TransactionCalendarState createState() => _TransactionCalendarState();
}

class _TransactionCalendarState extends State<TransactionCalendar> {
  Map<DateTime, List<FinancialItem>> transactionsByDate =
      {}; // Initialize as an empty map
  List<FinancialItem> allFinancialData = [];
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  List<FinancialItem> selectedDayTransactions = [];
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        QuerySnapshot queryExpenses = await firestore
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .get();

        QuerySnapshot queryIncomes = await firestore
            .collection('incomes')
            .where('userId', isEqualTo: user.uid)
            .get();

        List<FinancialItem> allData = [
          ...queryExpenses.docs.map(
              (doc) => Expense.fromMap(doc.data() as Map<String, dynamic>)),
          ...queryIncomes.docs
              .map((doc) => Income.fromMap(doc.data() as Map<String, dynamic>))
        ];

        setState(() {
          allFinancialData = allData;
          _groupTransactionsByDate();
        });

        print('All Financial Data: $allFinancialData');
        print('Transactions by Date: $transactionsByDate');
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  void _groupTransactionsByDate() {
    Map<DateTime, List<FinancialItem>> groupedTransactions = {};
    for (var item in allFinancialData) {
      DateTime date = DateTime(item.date.year, item.date.month, item.date.day);
      groupedTransactions[date] = (groupedTransactions[date] ?? [])..add(item);
    }

    setState(() {
      transactionsByDate = groupedTransactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Transaction Calendar'),
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              calendarFormat: _calendarFormat,
              onFormatChanged: _onFormatChanged,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                  _updateTransactionsForSelectedDay(selectedDay);
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  var count = events.length;
                  if (count > 0) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(count),
                    );
                  }
                },
              ),
              eventLoader: (day) {
                return transactionsByDate[
                        DateTime(day.year, day.month, day.day)] ??
                    [];
              },
// Other properties of TableCalendar
            ),
            Expanded(
              // Use Expanded to take up remaining space
              child: _buildTransactionList(),
            ),
          ],
        ));
  }

  void _updateTransactionsForSelectedDay(DateTime day) {
    setState(() {
      selectedDay = day;
      selectedDayTransactions =
          transactionsByDate[DateTime(day.year, day.month, day.day)] ?? [];
      print('Selected Day Transactions: $selectedDayTransactions'); // Debug
    });
  }

  Widget _buildTransactionList() {
    if (selectedDayTransactions.isEmpty) {
      return Center(child: Text('No transactions for this day'));
    }

    return ListView.builder(
      itemCount: selectedDayTransactions.length,
      itemBuilder: (context, index) {
        var transaction = selectedDayTransactions[index];
        print('Displaying transaction: $transaction'); // Debug
        return ListTile(
          title: Text(transaction.name),
          subtitle: Text(transaction is Expense ? 'Expense' : 'Income'),
          trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
        );
      },
    );
  }
}

Widget _buildEventsMarker(int count) {
  return Container(
    padding: EdgeInsets.all(2),
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      color: Colors.blue,
    ),
    child: Text(
      '$count',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      ),
    ),
  );
}
