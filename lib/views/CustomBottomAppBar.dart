import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final Color color;
  final List<String> tabLabels = [
    'Currency',
    'Transactions',
    'Home',
    'Goals',
    'Settings'
  ];

  CustomBottomAppBar({
    required this.selectedIndex,
    required this.onTabChange,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: color,
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabIconButton(Icons.cached, 0),
          _buildTabIconButton(Icons.attach_money, 1),
          _buildTabIconButton(Icons.flag, 3),
          _buildTabIconButton(Icons.settings, 4),
        ],
      ),
    );
  }

  Widget _buildTabIconButton(IconData icon, int index) {
    bool isSelected = selectedIndex == index && index != 2;

    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () => onTabChange(index),
          color: isSelected ? Colors.white : Colors.grey,
          tooltip: tabLabels[index],
        ),
        if (isSelected)
          Text(
            tabLabels[index],
            style: TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}
