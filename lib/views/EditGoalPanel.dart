import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditGoalPanel extends StatefulWidget {
  final String goalId;
  final String initialName;
  final double initialTargetAmount;
  final double initialCurrentAmount;
  final String initialCurrency;

  const EditGoalPanel({
    required this.goalId,
    required this.initialName,
    required this.initialTargetAmount,
    required this.initialCurrentAmount,
    required this.initialCurrency,
  });

  @override
  _EditGoalPanelState createState() => _EditGoalPanelState();
}

class _EditGoalPanelState extends State<EditGoalPanel> {
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _targetAmountController = TextEditingController(text: widget.initialTargetAmount.toString());
    _currentAmountController = TextEditingController(text: widget.initialCurrentAmount.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name:'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter goal name',
              ),
            ),
            SizedBox(height: 16.0),
            Text('Target Amount:'),
            TextField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter target amount',
              ),
            ),
            SizedBox(height: 16.0),
            Text('Current Amount:'),
            TextField(
              controller: _currentAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter current amount',
              ),
            ),
            SizedBox(height: 16.0),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () async {
              // Validate and save changes
              if (_validateFields()) {
                await _updateGoal();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ),
        SizedBox(height: 8.0),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              // Ask user if they want to discard changes
              _showDiscardChangesDialog();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
            ),
            child: Text('Cancel'),
          ),
        ),
      ],
    );
  }


  bool _validateFields() {
    // Add validation logic here
    // Return true if fields are valid, otherwise false
    return true;
  }

  Future<void> _updateGoal() async {
    try {
      double targetAmount = double.parse(_targetAmountController.text);
      double currentAmount = double.parse(_currentAmountController.text);

      await FirebaseFirestore.instance.collection('goals').doc(widget.goalId).update({
        'name': _nameController.text,
        'amount': targetAmount,
        'currentAmount': currentAmount,
        'currency': widget.initialCurrency,
      });

      print('Goal updated successfully!');
    } catch (error) {
      print('Error updating goal: $error');
    }
  }

  Future<void> _showDiscardChangesDialog() async {
    if (_nameController.text != widget.initialName ||
        _targetAmountController.text != widget.initialTargetAmount.toString() ||
        _currentAmountController.text != widget.initialCurrentAmount.toString()) {
      // Show dialog if changes are made
      bool discardChanges = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Discard Changes?'),
            content: Text('Are you sure you want to discard changes?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );

      if (discardChanges == true) {
        Navigator.pop(context);
      }
    } else {
      // If no changes made, directly pop the screen
      Navigator.pop(context);
    }
  }
}
