import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<ExpenseData> recentExpenses = [];
  bool hasExpenses = false;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchRecentExpenses();
  }

  void _fetchRecentExpenses() async {
    try {
      final user = this.user;
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        QuerySnapshot querySnapshot = await firestore
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            // .orderBy('date', descending: true)
            .limit(3)
            .get();

        if (querySnapshot.docs.isEmpty) {
          setState(() {
            recentExpenses = List.empty();
            hasExpenses = false;
          });
        } else {
          setState(() {
            recentExpenses = prepareExpenseData(querySnapshot);
            hasExpenses = true;
          });
        }
      }
    } catch (e) {
      print('Error fetching recent expenses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: hasExpenses ? _buildChart() : _buildWelcomeMessage(),
      ),
    );
  }

  Widget _buildChart() {
    return Column(
      children: [
        // Sekcja: Nagłówek
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Text(
            'Wykres wszystkich wydatków',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Sekcja: Wykres z legendą
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('expenses')
                .where('userId',
                    isEqualTo: user
                        ?.uid) // Dodane ograniczenie do zalogowanego użytkownika
                .get(),
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
                            touchCallback: (FlTouchEvent event,
                                PieTouchResponse? touchResponse) {
                              if (event is FlTouchEvent ||
                                  event is FlLongPressEnd) {
                                int touchedIndex = touchResponse
                                        ?.touchedSection?.touchedSectionIndex ??
                                    -1;
                                if (touchedIndex >= 0 &&
                                    touchedIndex < expenseDataList.length) {
                                  showCategoryDetails(
                                      expenseDataList[touchedIndex]);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    // Sekcja: Legenda
                    Container(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: expenseDataList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getColor(index),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${expenseDataList[index].category}: ${(expenseDataList[index].amount / getTotalAmount(expenseDataList) * 100).toStringAsFixed(2)}%',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
        // Sekcja: Lista ostatnich 2 wydatków
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ostatnie wydatki:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DataTable(
                columns: [
                  DataColumn(label: Text('Kategoria')),
                  DataColumn(label: Text('Kwota')),
                ],
                rows: recentExpenses.map((expense) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          expense.category,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DataCell(
                        Text(
                          expense.amount.toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Text(
        'Welcome to the app!\nCreate new outcome to see a chart.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  List<ExpenseData> prepareExpenseData(QuerySnapshot? snapshot) {
    List<ExpenseData> expenseDataList = [];

    if (snapshot != null) {
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String category = data['category'] ?? 'Unknown';
        double amount =
            data['amount'] != null ? data['amount'].toDouble() : 0.0;
        String currency = data['currency'] ?? '';

        int existingIndex = expenseDataList
            .indexWhere((element) => element.category == category);

        if (existingIndex != -1) {
          expenseDataList[existingIndex].amount += amount;
        } else {
          expenseDataList.add(ExpenseData(category, amount, currency));
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
              Text('Number of Expenses: ${getNumberOfExpenses(expense)}'),
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

  int getNumberOfExpenses(ExpenseData expense) {
    int numberOfExpenses = expenseDataList
        .where((element) => element.category == expense.category)
        .length;

    return numberOfExpenses;
  }
}
