import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/Expense.dart';
import '../model/FinancialItem.dart';
import '../model/Income.dart';

class FinancialItemDetailsDialog {
  final FinancialItem financialItem;

  FinancialItemDetailsDialog({required this.financialItem});

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  financialItem is Expense
                      ? 'Expense Details'
                      : 'Income Details',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Name: ${financialItem.name}'),
                Text('Date: ${_formattedDate(financialItem.date)}'),
                Text('Amount: ${financialItem.amount} ${financialItem.currency}'),
                if (financialItem is Expense)
                  ...[
                    Text('Category: ${(financialItem as Expense).category}'),
                    Text('Description: ${(financialItem as Expense).description}'),
                    Text('Payment Method: ${(financialItem as Expense).paymentMethod}'),
                  ]
                else if (financialItem is Income)
                  Text('(No additional details for income)'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formattedDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
