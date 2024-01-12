import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'EditGoalPanel.dart';

class VirtualPiggyBank {
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final String id;

  VirtualPiggyBank(
      this.userId, this.name, this.targetAmount, this.currentAmount, this.currency, this.id);
}

class GoalsView extends StatefulWidget {
  const GoalsView({Key? key}) : super(key: key);

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to the notifications view
              // Replace with your navigation logic
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getUserGoals(),
        builder: (context, AsyncSnapshot<List<VirtualPiggyBank>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            ); // Loading indicator while data is being fetched
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No goals available'),
            ); // Inform the user that there are no goals
          } else {
            List<VirtualPiggyBank> userGoals = snapshot.data!;
            return ListView.builder(
              itemCount: userGoals.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(userGoals[index].id),
                  background: Container(
                    color: Colors.green, // Zmiana koloru na zielony
                    child: Icon(
                      Icons.edit, // Zmiana ikony na olówek
                      color: Colors.white,
                      size: 36.0,
                    ),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16.0),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red, // Zmiana koloru na czerwony
                    child: Icon(
                      Icons.delete, // Zmiana ikony na kosz
                      color: Colors.white,
                      size: 36.0,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16.0),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Confirm deletion
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Goal?'),
                            content: Text('Are you sure you want to delete this goal?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (direction == DismissDirection.startToEnd) {
                      // Edit goal
                      _editGoal(userGoals[index]);
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      // Delete goal
                      _deleteGoal(userGoals[index]);
                    }
                  },
                  child: _buildPiggyBankCard(userGoals[index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<VirtualPiggyBank>> _getUserGoals() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        QuerySnapshot goalsSnapshot = await _firestore
            .collection('goals')
            .where('userId', isEqualTo: user.uid)
            .get();

        // Ensure the widget is still mounted before updating the state
        if (mounted) {
          List<VirtualPiggyBank> userGoals = goalsSnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return VirtualPiggyBank(
              user.uid,
              data['name'] ?? '',
              (data['amount'] ?? 0.0).toDouble(),
              (data['currentAmount'] ?? 0.0).toDouble(),
              data['currency'] ?? '',
              data['id'] ?? '',
            );
          }).toList();

          return userGoals;
        }
      } catch (e) {
        print('Error fetching goals: $e');
      }
    }

    return [];
  }

  Widget _buildPiggyBankCard(VirtualPiggyBank piggyBank) {
    double progressPercentage = 0.0;

    if (piggyBank.targetAmount != 0) {
      progressPercentage =
          (piggyBank.currentAmount / piggyBank.targetAmount) * 100;

      if (progressPercentage.isNaN || progressPercentage.isInfinite) {
        progressPercentage = 0.0;
      }
    }

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              piggyBank.name,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            _buildAmountInfo(piggyBank),
            SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: progressPercentage / 100,
              color: Colors.blueAccent,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInfo(VirtualPiggyBank piggyBank) {
    double progressPercentage = 0.0;

    if (piggyBank.targetAmount != 0) {
      progressPercentage =
          (piggyBank.currentAmount / piggyBank.targetAmount) * 100;

      if (progressPercentage.isNaN || progressPercentage.isInfinite) {
        progressPercentage = 0.0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount Raised: ${piggyBank.currentAmount} ${piggyBank.currency} / Goal Amount: ${piggyBank.targetAmount} ${piggyBank.currency} (${progressPercentage.toStringAsFixed(0)}%)',
        ),
        SizedBox(height: 8.0),
        Text(
          'Progress: ${progressPercentage.toStringAsFixed(0)}%',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _deleteGoal(VirtualPiggyBank piggyBank) async {
    try {
      // Delete goal from Firebase
      await _firestore.collection('goals').doc(piggyBank.id).delete();
      print('Goal deleted successfully!');
    } catch (error) {
      print('Error deleting goal: $error');
    }
  }

  void _editGoal(VirtualPiggyBank piggyBank) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditGoalPanel(
          goalId: piggyBank.id,
          initialName: piggyBank.name,
          initialTargetAmount: piggyBank.targetAmount,
          initialCurrentAmount: piggyBank.currentAmount,
          initialCurrency: piggyBank.currency,
        ),
      ),
    );
  }
}
