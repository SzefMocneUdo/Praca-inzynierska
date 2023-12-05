// import 'package:flutter/material.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
//
// class BottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final void Function(int) onTabChange;
//
//   const BottomNavBar({
//     Key? key,
//     required this.selectedIndex,
//     required this.onTabChange,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GNav(
//       gap: 0,
//       tabs: const [
//         GButton(
//           icon: Icons.currency_exchange,
//           text: 'Currency',
//         ),
//         GButton(
//           icon: Icons.money_off,
//           text: 'Transactions',
//         ),
//         GButton(
//           icon: Icons.flag,
//           text: 'Goals',
//         ),
//         GButton(
//           icon: Icons.account_circle_sharp,
//           text: 'Profile',
//         ),
//       ],
//       selectedIndex: selectedIndex,
//       onTabChange: onTabChange,
//     );
//   }
// }
