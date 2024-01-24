import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'NotificationsView.dart';

class ContactUsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Have a question or feedback? Contact us!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'You can email us using one of addresses:',
              style: TextStyle(fontSize: 18,),
            ),
            SizedBox(height: 20),
            _buildEmailRow("s95623@pollub.edu.pl", context),
            SizedBox(height: 10,),
            _buildEmailRow("s95624@pollub.edu.pl", context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailRow(String emailAddress, BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            emailAddress,
            style: TextStyle(fontSize: 18),
          ),
          IconButton(
            onPressed: () {
              _copyToClipboard(emailAddress);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.copy),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String textToCopy) {
    Clipboard.setData(ClipboardData(text: textToCopy));
  }
}