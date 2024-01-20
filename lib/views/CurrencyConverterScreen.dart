import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_currency_rate/live_currency_rate.dart';
import 'package:currency_picker/currency_picker.dart';

import 'CurrenciesView.dart';

class CurrencyConvrterScreen extends StatefulWidget {
  const CurrencyConvrterScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyConvrterScreen> createState() => _CurrencyConvrterScreenState();
}

class _CurrencyConvrterScreenState extends State<CurrencyConvrterScreen> {
  TextEditingController _amountController = TextEditingController();
  double _exchangeRateController = 0.0;
  double _resultController = 0.0;
  Currency? _fromController;
  Currency? _toController;
  late TextEditingController _fromCurrencyTextField;
  late TextEditingController _toCurrencyTextField;
  bool error = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fromCurrencyTextField = TextEditingController();
    _toCurrencyTextField = TextEditingController();
  }

  void _openCurrencyPicker(bool isFrom) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          if (isFrom) {
            _fromController = currency;
            _fromCurrencyTextField.text = currency.name;
          } else {
            _toController = currency;
            _toCurrencyTextField.text = currency.name;
          }
        });
      },
    );
  }

  Widget _buildCurrencyPickerTextField(bool isFrom) {
    if (isFrom) {
      return TextFormField(
        controller: _fromCurrencyTextField,
        readOnly: true,
        decoration: InputDecoration(
          hintText:
              _fromController != null ? _fromController!.name : 'Currency',
          prefixIcon: Icon(
            Icons.attach_money,
            color: Colors.grey,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            ),
            onPressed: () {
              _openCurrencyPicker(isFrom);
            },
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.grey, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        style: TextStyle(color: Colors.black),
      );
    } else {
      return TextFormField(
        controller: _toCurrencyTextField,
        readOnly: true,
        decoration: InputDecoration(
          hintText: _toController != null ? _toController!.name : 'Currency',
          prefixIcon: Icon(
            Icons.attach_money,
            color: Colors.grey,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            ),
            onPressed: () {
              _openCurrencyPicker(isFrom);
            },
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.grey, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        style: TextStyle(color: Colors.black),
      );
    }
  }

  void showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: _buildCurrencyPickerTextField(true),
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
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _buildCurrencyPickerTextField(false)),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  String amountText = _amountController.text;
                  double amount = double.tryParse(amountText) ?? 0.0;

                  if (_fromController == null || _toController == null ) {
                    setState(() {
                      errorMessage = "Currency is required";
                    });
                    showErrorDialog(context, 'Error', errorMessage);
                    return;
                  }
                  else if(amount == 0.0){
                    setState(() {
                      errorMessage = "Amount is required";
                    });
                    showErrorDialog(context, 'Error', errorMessage);
                    return;
                  }
                  else{
                    String fromCode = _fromController!.code ?? "";
                    String toCode = _toController!.code ?? "";

                    CurrencyRate rate = await LiveCurrencyRate.convertCurrency(
                        fromCode, toCode, amount);
                    _exchangeRateController = rate.result / amount;

                    setState(() {
                      _resultController = rate.result;
                    });
                  }


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
