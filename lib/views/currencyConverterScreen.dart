import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchForExchangeRateScreen extends StatefulWidget {
  const SearchForExchangeRateScreen({Key? key}) : super(key: key);

  @override
  State<SearchForExchangeRateScreen> createState() => _SearchForExchangeRateScreenState();
}

void _launchURL() async {
  const url = 'https://g.co/kgs/ZHmSqn';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _SearchForExchangeRateScreenState extends State<SearchForExchangeRateScreen> {
  List<String> currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "PLN"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exchange Rate Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _launchURL(); // Wywołanie funkcji do otwierania linku
          },
          child: Text('Otwórz link'),
        ),
      ),
    );
  }
}
