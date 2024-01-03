import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<String> savedConversions = [];

  Future<void> loadSavedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fromCurrency = prefs.getString('fromCurrency') ?? '';
    String toCurrency = prefs.getString('toCurrency') ?? '';

    CurrencyRate rate =
    await LiveCurrencyRate.convertCurrency(fromCurrency, toCurrency, 1);

    setState(() {
      _fromController = fromCurrency;
      _toController = toCurrency;
      _rateController = rate.result.toString();
    });

    // Pobranie listy zapisanych przeliczników
    List<String>? savedList = prefs.getStringList('savedConversions');
    if (savedList != null) {
      setState(() {
        savedConversions = savedList;
      });
    }
  }

  Future<List<String>> _calculateRates(List<QueryDocumentSnapshot> documents) async {
    List<String> rates = [];

    for (var doc in documents) {
      String from = doc['from'];
      String to = doc['to'];

      CurrencyRate rate = await LiveCurrencyRate.convertCurrency(from, to, 1);
      rates.add(rate.result.toString());
    }

    return rates;
  }

  void _deleteCurrencyRate(String from, String to) {
    FirebaseFirestore.instance
        .collection('currencyRates')
        .where('from', isEqualTo: from)
        .where('to', isEqualTo: to)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    })
        .catchError((error) {
      print('Error deleting currency rate: $error');
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
                Expanded(
                    child:
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('followedCurrencies').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text('No followed currencies available.'),
                            );
                          }

                          // Oblicz stawki walut na podstawie dokumentów z Firestore
                          return FutureBuilder<List<String>>(
                            future: _calculateRates(snapshot.data!.docs),
                            builder: (BuildContext context, AsyncSnapshot<List<String>> ratesSnapshot) {
                              if (ratesSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (ratesSnapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${ratesSnapshot.error}'),
                                );
                              }
                              if (!ratesSnapshot.hasData || ratesSnapshot.data!.isEmpty) {
                                return Center(
                                  child: Text('No rates available.'),
                                );
                              }

                              List<String> rates = ratesSnapshot.data!;


                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var currency = snapshot.data!.docs[index];
                                  String from = currency['from'];
                                  String to = currency['to'];
                                  double rate = double.tryParse(rates[index]) ?? 0.0;

                                  return Dismissible(
                                    key: Key('$from$to$rate'), // Klucz do identyfikowania elementu Dismissible
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(right: 16.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 36.0,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      if (direction == DismissDirection.endToStart) {
                                        // Confirm deletion
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Delete Currency Rate?'),
                                              content: Text('Are you sure you want to delete this currency rate?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true);
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return confirmDelete;
                                      }
                                      return false;
                                    },
                                    onDismissed: (direction) {
                                      if (direction == DismissDirection.endToStart) {
                                        // Delete from database
                                        _deleteCurrencyRate(from, to); // Implementacja usuwania przelicznika
                                      }
                                    },
                                    child: ListTile(
                                      title: Text('From: $from, To: $to, Rate: $rate'),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                    )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
