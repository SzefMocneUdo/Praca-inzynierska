import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/views/FinancialItemDetailsDialog.dart';

import '../model/Expense.dart';
import '../model/FinancialItem.dart';
import '../model/Income.dart';

class TransactionCalendar extends StatefulWidget {
  @override
  _TransactionCalendarState createState() => _TransactionCalendarState();
}

class _TransactionCalendarState extends State<TransactionCalendar> {
  Map<DateTime, List<FinancialItem>> transactionsByDate = {};
  List<FinancialItem> allFinancialData = [];
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  List<FinancialItem> selectedDayTransactions = [];
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  int _currentCarouselPage = 0;
  final CarouselController _carouselController = CarouselController();
  DateTime _startRange = DateTime.now();
  DateTime _endRange = DateTime.now().add(Duration(days: 7));
  List<FinancialItem> _filteredTransactions = [];

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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startRange, end: _endRange),
    );
    if (picked != null &&
        picked != DateTimeRange(start: _startRange, end: _endRange)) {
      setState(() {
        _startRange = picked.start;
        _endRange = picked.end;
      });
    }
  }

  void _filterTransactionsByDateRange() {
    setState(() {
      _filteredTransactions = allFinancialData.where((transaction) {
        return transaction.date.isAfter(_startRange) &&
            transaction.date.isBefore(_endRange);
      }).toList();
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
          CarouselSlider(
            carouselController: _carouselController,
            items: [_buildCalendarView(), _buildDateRangePickerView()],
            options: CarouselOptions(
              height: 400,
              initialPage: 0,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              autoPlay: false,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselPage = index;
                });
              },
            ),
          ),
          _buildCarouselIndicators(),
          _buildTransactionListForCurrentView(),
        ],
      ),
    );
  }

  Widget _buildTransactionListForCurrentView() {
    List<FinancialItem> transactionsToShow = [];

    if (_currentCarouselPage == 0 && selectedDay != null) {
      transactionsToShow = transactionsByDate[DateTime(
              selectedDay!.year, selectedDay!.month, selectedDay!.day)] ??
          [];
    } else if (_currentCarouselPage == 1) {
      transactionsToShow = _filteredTransactions;
    }

    if (transactionsToShow.isEmpty) {
      return Expanded(
        child: Center(child: Text("No available transactions")),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: transactionsToShow.length,
        itemBuilder: (context, index) {
          var transaction = transactionsToShow[index];
          return ListTile(
            title: Text(transaction.name),
            subtitle: Text(transaction is Expense ? 'Expense' : 'Income'),
            trailing: Text('${transaction.currency} ${transaction.amount.toStringAsFixed(2)}'),
            onTap: () {
              FinancialItemDetailsDialog(financialItem: transaction)
                  .show(context);
            },
          );
        },
      ),
    );
  }

  Widget _buildCalendarView() {
    return TableCalendar(
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
        return transactionsByDate[DateTime(day.year, day.month, day.day)] ?? [];
      },
    );
  }

  Widget _buildDateRangePickerView() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _selectDateRange,
            child: Text('Choose the range of dates'),
          ),
          SizedBox(height: 8),
          Text(
            'Chosen rage of dates:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '${DateFormat('yyyy-MM-dd').format(_startRange)} do ${DateFormat('yyyy-MM-dd').format(_endRange)}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _filterTransactionsByDateRange,
            child: Text('Pokaż'),
          ),
        ],
      ),
    );
  }

  void _updateTransactionsForSelectedDay(DateTime day) {
    setState(() {
      selectedDay = day;
      selectedDayTransactions =
          transactionsByDate[DateTime(day.year, day.month, day.day)] ?? [];
      print('Selected Day Transactions: $selectedDayTransactions');
    });
  }

  Widget _buildCarouselIndicators() {
    List<Widget> indicators = [];
    for (int i = 0; i < 2; i++) {
      indicators.add(Container(
        width: 8.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentCarouselPage == i ? Colors.blue : Colors.grey,
        ),
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicators,
    );
  }

  Widget _buildTransactionTable(List<FinancialItem> transactionsToShow) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Name and type')),
          DataColumn(label: Text('Price')),
        ],
        rows: transactionsToShow.map((transaction) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.name),
                    Text(transaction is Expense ? 'Expense' : 'Income',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                onTap: () {
                  FinancialItemDetailsDialog(financialItem: transaction)
                      .show(context);
                },
              ),
              DataCell(
                Text('\$${transaction.amount.toStringAsFixed(2)}'),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (selectedDayTransactions.isEmpty) {
      return Center(child: Text('No transactions for this day'));
    }

    return ListView.builder(
      itemCount: selectedDayTransactions.length,
      itemBuilder: (context, index) {
        var transaction = selectedDayTransactions[index];
        print('Displaying transaction: $transaction');
        return ListTile(
          title: Text(transaction.name),
          subtitle: Text(transaction is Expense ? 'Expense' : 'Income'),
          trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
        );
      },
    );
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
}
