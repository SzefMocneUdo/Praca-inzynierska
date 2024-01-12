// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../model/Expense.dart';
//
// class ExpenseDetailsDialog {
//   final Expense expense;
//
//   ExpenseDetailsDialog({required this.expense});
//
//   void show(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Expense Details', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 10),
//                 Text('Name: ${expense.name}'),
//                 Text('Date: ${DateFormat('dd/MM/yyyy').format(expense.date)}'),
//                 Text('Amount: ${expense.amount}'),
//                 Text('Category: ${expense.category}'),
//                 Text('Description: ${expense.description}'),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text('Close'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }