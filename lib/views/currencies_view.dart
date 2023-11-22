import 'package:flutter/material.dart';
import 'package:untitled/views/followExchangeRatesScreen.dart';
import 'currencyConverterScreen.dart';
import 'notifications_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_currency_rate/live_currency_rate.dart';


class CurrenciesView extends StatefulWidget {
  const CurrenciesView({Key? key});

  @override
  State<CurrenciesView> createState() => _CurrenciesViewState();
}

class _CurrenciesViewState extends State<CurrenciesView> {
  String _fromController = '';
  String _toController = '';
  String _rateController = '';

  Future<void> loadSavedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() async{
      _fromController = prefs.getString('fromCurrency') ?? '';
      _toController = prefs.getString('toCurrency') ?? '';

      CurrencyRate rate = await LiveCurrencyRate.convertCurrency(
          _fromController, _toController, 1);

      _rateController = rate.result.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    loadSavedCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currencies'),
        backgroundColor: Colors.blueAccent,
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
      body: Column(
        children: [
          Container(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FollowExchangeRatesScreen(),
                      ));
                    },
                    child: Column(children: [
                      Center(
                        child: Icon(
                          Icons.add,
                          size: 100,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Follow exchange rates",
                      ),
                    ]),
                  ),
                ),
                VerticalDivider(
                  color: Colors.grey,
                  thickness: 2,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CurrencyConvrterScreen(),
                      ));
                    },
                    child: Column(children: [
                      Center(
                        child: Icon(
                          Icons.currency_exchange,
                          size: 100,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Converter",
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.black,
            thickness: 1.0,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      _fromController,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      _toController,
                      style: TextStyle(fontSize: 20),
                    ),

                  ],
                ),

                // You can implement currency conversion using CurrencyRate here
                // Use _fromController and _toController for conversion
              ],
            ),
          ),
        ],
      ),
    );
  }
}
