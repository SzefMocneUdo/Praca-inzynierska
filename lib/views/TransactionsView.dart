

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/Expense.dart';
import '../model/FinancialItem.dart';
import '../model/Income.dart';
import 'FinancialItemDetailsDialog.dart';
import 'NotificationsView.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List<FinancialItem> allFinancialData = [];
  List<Expense> expenses = [];
  List<Income> incomes = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() async {
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

        List<Expense> userExpenses = queryExpenses.docs.map((doc) {
          return Expense.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        List<Income> userIncomes = queryIncomes.docs.map((doc) {
          return Income.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        List<FinancialItem> allData = [...userExpenses, ...userIncomes];

        setState(() {
          allFinancialData = allData;
          expenses = userExpenses;
          incomes = userIncomes;
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Financial Overview'),
          backgroundColor: Colors.blueAccent,
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
          bottom: TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Expenses'),
              Tab(text: 'Incomes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFinancialList(allFinancialData),
            _buildFinancialListExpense(expenses),
            _buildFinancialListIncomes(incomes),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialList(List<FinancialItem> financialData) {
    financialData.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Financial Overview',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        if (financialData.isEmpty)
          Center(
            child: Text('No financial data available'),
          )
        else
          SizedBox(
            height: 600, // Set a fixed height or adjust as needed
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: financialData.map<DataRow>((financialItem) {
                  Color amountColor =
                  financialItem is Income ? Colors.green : Colors.red;

                  return DataRow(
                    cells: [
                      DataCell(Text(financialItem.name)),
                      DataCell(
                        GestureDetector(
                          child: Text(
                            '${financialItem.amount} ${financialItem.currency}',
                            style: TextStyle(
                              color: amountColor,
                            ),
                          ),
                          onTap: () {
                            _showFinancialItemDetails(financialItem);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }



  Widget _buildFinancialListIncomes(List<Income> income) {
    income.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Incomes Overview',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        if (income.isEmpty)
          const Center(
            child: Text('No income data available'),
          )
        else
          SizedBox(
            height: 600, // Set a fixed height or adjust as needed
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: income.map<DataRow>((financialItem) {
                  Color amountColor = Colors.green;

                  return DataRow(
                    cells: [
                      DataCell(Text(financialItem.name)),
                      DataCell(
                        GestureDetector(
                          child: Text(
                            '${financialItem.amount} ${financialItem.currency}',
                            style: TextStyle(
                              color: amountColor,
                            ),
                          ),
                          onTap: () {
                            _showIncomeDetails(financialItem);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildFinancialListExpense(List<Expense> financialData) {
    financialData.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Expenses Overview',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        if (financialData.isEmpty)
          const Center(
            child: Text('No financial data available'),
          )
        else
          SizedBox(
            height: 600, // Set a fixed height or adjust as needed
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: financialData.map<DataRow>((financialItem) {
                  Color amountColor = Colors.red;

                  return DataRow(
                    cells: [
                      DataCell(Text(financialItem.name)),
                      DataCell(
                        GestureDetector(
                          child: Text(
                            '${financialItem.amount} ${financialItem.currency}',
                            style: TextStyle(
                              color: amountColor,
                            ),
                          ),
                          onTap: () {
                            _showExpenseDetails(financialItem);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }


  void _showExpenseDetails(Expense expense) {
    FinancialItemDetailsDialog(financialItem: expense).show(context);
  }

  void _showIncomeDetails(Income income) {
    FinancialItemDetailsDialog(financialItem: income).show(context);
  }

  void _showFinancialItemDetails(FinancialItem financialItem) {
    FinancialItemDetailsDialog(financialItem: financialItem).show(context);
  }
}