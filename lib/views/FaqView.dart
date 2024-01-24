import 'package:flutter/material.dart';
import 'package:untitled/views/NotificationsView.dart';

import '../model/Item.dart';

class FaqView extends StatefulWidget {
  @override
  _FaqViewState createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  List<Item> _data = generateItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
        backgroundColor: Colors.blueAccent,
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
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
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(4.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _data[index].isExpanded = isExpanded;
              });
            },
            children: _data.map<ExpansionPanel>((Item item) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      item.headerValue,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
                body: ListTile(
                  title: Text(item.expandedValue),
                ),
                isExpanded: item.isExpanded,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

List<Item> generateItems() {
  List<Item> items = [];
  items.add(Item(
    headerValue: 'How to use the app?',
    expandedValue:
        'To use the app, log in and start adding incomes and outcomes. '
        'Main screen of the app contains your statistics and charts based on your expenses.'
        'You can switch between different pages to see more info about your finance.',
  ));

  items.add(Item(
    headerValue: 'How to add a new expense?',
    expandedValue:
        'To add a new expense You need to hold "+" button placed on the navigation bar for 2 seconds.'
        'From the displayed menu select "Add a new expense". Fill all of the required fields and press "Add Expense" button.',
  ));

  items.add(Item(
    headerValue: 'How to add an new income?',
    expandedValue:
        'To add a new income You need to hold "+" button placed on the navigation bar for 2 seconds.'
        'From the displayed menu select "Add an new income". Fill all of the required fields and press "Add Income" button.',
  ));

  items.add(Item(
    headerValue: 'How to attach a new credit card?',
    expandedValue:
        'To attach a new credit card You need to hold "+" button placed on the navigation bar for 2 seconds.'
        'From the displayed menu select "Attach a new credit card". Fill all of the required fields and press "Add" button.'
        'You can also select card style and turn it to the other side.',
  ));

  items.add(Item(
    headerValue: 'How to add a new saving goal?',
    expandedValue:
        'To add a new saving goal You need to hold "+" button placed on the navigation bar for 2 seconds.'
        'From the displayed menu select "Add a new saving goal". Fill all of the required fields and press "Add Goal" button.',
  ));

  items.add(Item(
    headerValue: 'How to view current currency rates?',
    expandedValue:
        'To view current currency rates You need to press "Currency" button placed on the left side of the navigation bar.'
        'You should see Currency screen that displays followed currency rates.'
        'If You want to follow a new currency rate, press "Follow exchange rates" button.',
  ));

  items.add(Item(
    headerValue: 'How to view financial overview?',
    expandedValue:
        'To view financial overview You need to press "Transaction" button placed on the navigation bar.'
        'You should see Financial Overview screen that displays all of your transactions.'
        'You can switch between 3 sections: "All", "Expenses" and "Incomes".',
  ));

  items.add(Item(
    headerValue: 'How to view main screen?',
    expandedValue:
        'To view main screen You need to press "+" button placed on the navigation bar.'
        'You should see main screen screen that displays transaction charts and your latest expenses.'
        'You can switch between charts scrolling them horizontally.',
  ));

  items.add(Item(
      headerValue: 'How to view saving goals?',
      expandedValue:
          'To view saving goals You need to press "Goals" button placed on the navigation bar.'
          'You should see Goals screen that displays your saving goals.'));

  items.add(Item(
      headerValue: 'How to open settings?',
      expandedValue:
          'To open settings You need to press "Settings" button placed on the right side of the navigation bar.'
          'You should see Settings screen. From this screen, You can manage your account, application performance '
          'and get access to Calendar and Cards.'));

  items.add(Item(
      headerValue: 'How to view calendar?',
      expandedValue:
          'To view calendar You need to open settings and press "Calendar" button in "Features" section.'
          'You should see Calendar screen that displays your transactions in the time frame on the calendar.'
          'You can see the details of each of them by clicking on the specific day on the calendar window.'));
  items.add(Item(
      headerValue: 'How to view credit cards?',
      expandedValue:
          'To view credit cards You need to open settings and press "Cards" button in "Features" section.'
          'You should see Cards screen that displays your attached credit cards.'
          'You can details of the card by clicking on the card widget.'));

  return items;
}
