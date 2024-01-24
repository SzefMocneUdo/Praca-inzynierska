import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'CurrenciesView.dart';

class FollowExchangeRatesScreen extends StatefulWidget {
  const FollowExchangeRatesScreen({Key? key}) : super(key: key);

  @override
  State<FollowExchangeRatesScreen> createState() =>
      _FollowExchangeRatesScreenState();
}

class _FollowExchangeRatesScreenState extends State<FollowExchangeRatesScreen> {
  String errorMessage = "";
  bool error = false;
  Currency? _fromController;
  Currency? _toController;
  late TextEditingController _fromCurrencyTextField;
  late TextEditingController _toCurrencyTextField;

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

  Future<bool> checkIfObjectExists(
      FirebaseFirestore firestore, String fromValue, String toValue) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await firestore
            .collection('followedCurrencies')
            .where('from', isEqualTo: fromValue)
            .where('to', isEqualTo: toValue)
            .where('userId', isEqualTo: user.uid)
            .get();

        return querySnapshot.docs.isNotEmpty;
      } else {
        print("User does not exist");
        return false;
      }
    } catch (e) {
      print('Wystąpił błąd: $e');
      throw e;
    }
  }

  void _addCurrencies() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        bool exists = await checkIfObjectExists(
          firestore,
          _fromController?.code ?? '',
          _toController?.code ?? '',
        );
        if (exists) {
          error = true;
          errorMessage = "Object already exists";
          print("Object already exists");
        } else if (_fromController == null || _toController == null) {
          error = true;
          errorMessage = "Currency is required";
          print("Currency is required");
        } else {
          error = false;
          firestore.collection('followedCurrencies').add({
            'from': _fromController?.code ?? '',
            'to': _toController?.code ?? '',
            "userId": user.uid
          });
          print('Currency rate added successfully!');
        }
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error encountered when adding currency rate: $e');
    }

    if (error) {
      showErrorDialog(context, 'Error', errorMessage);
      return;
    }

    Navigator.pop(context);
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
          title: const Text('Follow Exchange Rates'),
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
                child: _buildCurrencyPickerTextField(false),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  _addCurrencies();
                },
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ));
  }
}
