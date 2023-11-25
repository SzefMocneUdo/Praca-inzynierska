import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_currency_rate/live_currency_rate.dart';
import 'package:untitled/views/currencies_view.dart';

class CurrencyConvrterScreen extends StatefulWidget {
  const CurrencyConvrterScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyConvrterScreen> createState() => _CurrencyConvrterScreenState();
}

class _CurrencyConvrterScreenState extends State<CurrencyConvrterScreen> {
  List<String> currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "PLN"];
  String _fromController = "USD";
  String _toController = "EUR";
  TextEditingController _amountController = TextEditingController();
  double _exchangeRateController = 0.0;
  double _resultController = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Currency Converter'),
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
                  builder: (context) => CurrenciesView(),
                ));
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Text(
                  'From:',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(width: 1, color: Colors.black)),
                width: 300,
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white54,
                  icon: Icon(Icons.arrow_drop_down),
                  iconEnabledColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  value: _fromController,
                  onChanged: (String? newValue) {
                    setState(() {
                      _fromController = newValue!;
                    });
                  },
                  items:
                  currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Text(
                  'To:',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(width: 1, color: Colors.black)),
                width: 300,
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white54,
                  icon: Icon(Icons.arrow_drop_down),
                  iconEnabledColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  value: _toController,
                  onChanged: (String? newValue) {
                    setState(() {
                      _toController = newValue!;
                    });
                  },
                  items:
                  currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Text(
                  'Amount:',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 5),
              Container(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                  ),
                  style: TextStyle(
                    fontSize: 20, // Powiększenie tekstu pola
                  ),
                ),
                width: 300,
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  String amountText = _amountController.text;
                  double amount = double.tryParse(amountText) ?? 0.0;
                  CurrencyRate rate = await LiveCurrencyRate.convertCurrency(
                      _fromController, _toController, amount);
                  _exchangeRateController = rate.result / amount;
                  setState(() {
                    _resultController = rate.result;
                  });
                },
                child: Text(
                  'Convert',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Exchange rate: " + _exchangeRateController.toStringAsFixed(2),
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 40),
              Text(
                _resultController.toStringAsFixed(2),
                style: TextStyle(fontSize: 50),
              )
            ],
          ),
        ));
  }
}