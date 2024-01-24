import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/ExpenseData.dart';
import 'NotificationsView.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<ExpenseData> expenseDataList = [];
  List<ExpenseData> recentExpenses = [];

  bool hasExpenses = false;
  bool hasExpenseWithUserCurrency = false;
  User? user = FirebaseAuth.instance.currentUser;
  String userCurrency = "";
  List<Map<String, dynamic>> expensesData = [];
  List<FlSpot> lineChartSpots = [];
  List<BarChartGroupData> barGroups = [];
  List<String> currencies = [];
  int _currentCarouselPage = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    _fetchRecentExpenses();
    _getUserCurrency();
    _loadExpensesDataLast7Days();
    _loadExpensesDataByCurrency();
  }

  void _loadExpensesDataByCurrency() async {
    final user = this.user;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: user?.uid)
          .get();

      List<ExpenseData> expensesByCurrency = prepareExpenseData(querySnapshot);

      currencies = expensesByCurrency
          .map((expense) => expense.currency)
          .toSet()
          .toList();

      barGroups = generateBarGroups(expensesByCurrency);

      setState(() {});
    } catch (e) {
      print('Error fetching expenses by currency: $e');
    }
  }

  List<BarChartGroupData> generateBarGroups(List<ExpenseData> expenses) {
    List<BarChartGroupData> groups = [];

    Map<String, double> currencySumMap = {};

    for (int i = 0; i < expenses.length; i++) {
      String currency = expenses[i].currency;
      double amount = expenses[i].amount;

      currencySumMap[currency] = (currencySumMap[currency] ?? 0.0) + amount;
    }

    for (int i = 0; i < currencies.length; i++) {
      String currency = currencies[i];

      List<BarChartRodData> rods = [];
      double sum = currencySumMap[currency] ?? 0.0;

      rods.add(BarChartRodData(
        y: sum,
        width: 16,
      ));

      groups.add(BarChartGroupData(
        x: i,
        barRods: rods,
        showingTooltipIndicators: [0],
      ));
    }

    return groups;
  }

  Widget _buildBarChart() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Text(
            'Expenses in different currencies',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                groupsSpace: 12,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueAccent,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.y.round().toString(),
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(showTitles: false),
                  topTitles: SideTitles(
                    showTitles: false,
                  ),
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTitles: (value) {
                      if (value.toInt() < currencies.length) {
                        return currencies[value.toInt()];
                      }
                      return '';
                    },
                    margin: 10,
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ))
      ],
    );
  }

  void _loadExpensesDataLast7Days() async {
    final user = this.user;
    expensesData = await getExpensesLast7Days(user!);

    lineChartSpots = generateSpotsForLast7Days();

    setState(() {});
  }

  void _getUserCurrency() async {
    try {
      final user = this.user;
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await firestore.collection('users').doc(user.uid).get();

        if (documentSnapshot.exists) {
          userCurrency = documentSnapshot.get('currency');

          if (userCurrency != "") {
            print('Value of "currency" field: $userCurrency');
          } else {
            print('"currency" field is empty or equals null.');
          }
        } else {
          print('Document does not exist');
        }
      }
    } catch (e) {
      print("Error fetching user currecy: $e");
    }
  }

  void _fetchRecentExpenses() async {
    try {
      final user = this.user;
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        QuerySnapshot querySnapshot = await firestore
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
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

            for (QueryDocumentSnapshot doc in querySnapshot.docs) {
              Map<String, dynamic> expenseData =
                  doc.data() as Map<String, dynamic>;

              if (expenseData.containsKey('currency') &&
                  expenseData['currency'] == userCurrency) {
                hasExpenseWithUserCurrency = true;
                break;
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching recent expenses: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getExpensesLast7Days(User user) async {
    final DateTime now = DateTime.now();
    final DateTime last7DaysStart = now.subtract(Duration(days: 7));

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: user.uid)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(last7DaysStart))
          .get();

      List<Map<String, dynamic>> results = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> expenseData = doc.data() as Map<String, dynamic>;
        String currency = expenseData['currency'] ?? '';

        if (currency == userCurrency) {
          DateTime date = (expenseData['date'] as Timestamp).toDate();
          double amount = expenseData['amount'].toDouble();

          results.add({
            'date': date,
            'amount': amount,
          });
        }
      }

      return results;
    } catch (e) {
      print('Error fetching expenses: $e');
      return [];
    }
  }

  List<FlSpot> generateSpotsForLast7Days() {
    List<FlSpot> spots =
        List.generate(7, (index) => FlSpot(index.toDouble(), 0));

    for (int i = 0; i < expensesData.length; i++) {
      DateTime date = expensesData[i]['date'];
      double amount = expensesData[i]['amount'].toDouble();

      int daysAgo = DateTime.now().difference(date).inDays;

      spots[daysAgo] = FlSpot(daysAgo.toDouble(), amount);
    }

    print("Spots: ");
    print(spots);

    return spots;
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              hasExpenses ? _buildCarousel() : _buildWelcomeMessage(),
              if (hasExpenses) _buildCarouselIndicators(),
              if (hasExpenses) _buildLatestExpensesList()
            ],
          )),
    );
  }

  Widget _buildCard(Widget widget, EdgeInsetsGeometry margin) => Container(
        margin: margin,
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: widget,
      );

  Widget _buildCarousel() {
    return CarouselSlider(
      carouselController: _carouselController,
      items: [_buildPieChart(), _buildLineChart(), _buildBarChart()],
      options: CarouselOptions(
        height: 300,
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
    );
  }

  Widget _buildCarouselIndicators() {
    List<Widget> indicators = [];
    for (int i = 0; i < 3; i++) {
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

  Widget _buildLineChart() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Text(
            'Expenses in last 7 days ($userCurrency)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: SideTitles(
                  showTitles: false,
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    DateTime date =
                        DateTime.now().subtract(Duration(days: value.toInt()));
                    return '${date.day}/${date.month}';
                  },
                  margin: 8,
                  reservedSize: 30,
                  interval: 1,
                ),
                leftTitles: SideTitles(
                  showTitles: false,
                  getTitles: (value) {
                    return value.toString();
                  },
                ),
              ),
              minY: 0,
              lineBarsData: [
                LineChartBarData(
                  spots: lineChartSpots.isNotEmpty
                      ? lineChartSpots
                      : [FlSpot(0, 0)],
                  isCurved: false,
                  colors: [Colors.blue],
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    colors: [
                      Colors.blue.withOpacity(0.2),
                      Colors.blue.withOpacity(0.1)
                    ],
                    gradientColorStops: [0.0, 0.5],
                  ),
                ),
              ],
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
          ),
        ),
        _buildLegendLineChart(),
      ],
    );
  }

  Widget _buildLegendLineChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.all(5),
          color: Colors.blue,
          width: 20,
          height: 20,
        ),
        Text('Expenses in last 7 days'),
      ],
    );
  }

  Widget _buildPieChart() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Text(
            'Graph of all expenses ($userCurrency)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('expenses')
                .where('userId', isEqualTo: user?.uid)
                .where('currency', isEqualTo: userCurrency)
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
      ],
    );
  }

  Widget _buildLatestExpensesList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest expenses:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          DataTable(
            columns: [
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Amount')),
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
                      expense.amount.toString() + " " + expense.currency,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
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
