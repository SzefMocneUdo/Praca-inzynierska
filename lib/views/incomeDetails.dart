// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../model/Income.dart';
//
// class IncomeDetailsDialog {
//   final Income income;
//
//   IncomeDetailsDialog({required this.income});
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
//                 Text('Income Details', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 10),
//                 Text('Name: ${income.name}'),
//                 Text('Date: ${DateFormat('dd/MM/yyyy').format(income.date)}'),
//                 Text('Amount: ${income.amount}'),
//                 Text('Category: ${income.category}'),
//                 Text('Description: ${income.description}'),
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