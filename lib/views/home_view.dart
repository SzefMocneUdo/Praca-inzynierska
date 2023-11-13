import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/ExpenseData.dart';
import 'notifications_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<ExpenseData> expenseDataList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NotificationsView(),
              ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sekcja: Nagłówek
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Wykres wszystkich wydatków',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Sekcja: Wykres z legendą
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('expenses').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    expenseDataList = prepareExpenseData(snapshot.data);

                    return Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PieChart(
                            PieChartData(
                              sections: getSections(expenseDataList),
                              centerSpaceRadius: 40,
                              borderData: FlBorderData(
                                show: false,
                              ),
                              sectionsSpace: 0,
                              centerSpaceColor: Colors.white,
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, PieTouchResponse? touchResponse) {
                                  if (event is FlTouchEvent || event is FlLongPressEnd) {
                                    int touchedIndex = touchResponse?.touchedSection?.touchedSectionIndex ?? -1;
                                    if (touchedIndex >= 0 && touchedIndex < expenseDataList.length) {
                                      showCategoryDetails(expenseDataList[touchedIndex]);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Sekcja: Legenda
                        Wrap(
                          spacing: 16.0,
                          children: expenseDataList.map((expense) {
                            return Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getColor(expenseDataList.indexOf(expense)),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${expense.category}: ${(expense.amount / getTotalAmount(expenseDataList) * 100).toStringAsFixed(2)}%',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          // Sekcja: Lista ostatnich 3 wydatków
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ostatnie 3 wydatki:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('expenses').orderBy('date', descending: true).limit(3).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<ExpenseData> recentExpenses = prepareExpenseData(snapshot.data);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: recentExpenses.map((expense) {
                          return Text(
                            '${expense.category}: ${expense.amount}',
                            style: TextStyle(fontSize: 16),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ExpenseData> prepareExpenseData(QuerySnapshot? snapshot) {
    List<ExpenseData> expenseDataList = [];

    if (snapshot != null) {
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String category = data['category'] ?? 'Unknown';
        double amount = data['amount'] != null ? data['amount'].toDouble() : 0.0;

        int existingIndex = expenseDataList.indexWhere((element) => element.category == category);

        if (existingIndex != -1) {
          expenseDataList[existingIndex].amount += amount;
        } else {
          expenseDataList.add(ExpenseData(category, amount));
        }
      });
    }

    return expenseDataList;
  }

  List<PieChartSectionData> getSections(List<ExpenseData> data) {
    List<PieChartSectionData> sections = [];

    double totalAmount = getTotalAmount(data);

    for (int i = 0; i < data.length; i++) {
      sections.add(
        PieChartSectionData(
          color: getColor(i),
          value: data[i].amount / totalAmount,
          radius: 60,
          title: '',
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        ),
      );
    }

    return sections;
  }

  double getTotalAmount(List<ExpenseData> data) {
    double totalAmount = 0;

    for (var expense in data) {
      totalAmount += expense.amount;
    }

    return totalAmount;
  }

  Color getColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lime,
      Colors.blueGrey,
      Colors.brown,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.deepOrangeAccent,
      Colors.deepPurpleAccent,
      Colors.lightGreenAccent,
      Colors.limeAccent,
      Colors.amberAccent,
      Colors.tealAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.indigoAccent,
      Colors.lightBlueAccent,
      Colors.cyanAccent,
      Colors.blueAccent,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.yellow,
      Colors.grey,
      Colors.black,
      Colors.white,
      Colors.lightGreen,
      Colors.lime,
      Colors.amber,
      Colors.deepOrange,
      Colors.pink,
      Colors.indigo,
      Colors.lightBlue,
      Colors.cyan,
      Colors.blueGrey,
      Colors.brown,
    ];

    return colors[index % colors.length];
  }

  void showCategoryDetails(ExpenseData expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Category Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Category: ${expense.category}'),
              Text('Amount: ${expense.amount}'),
              Text('Percentage: ${(expense.amount / getTotalAmount(expenseDataList) * 100).toStringAsFixed(2)}%'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
