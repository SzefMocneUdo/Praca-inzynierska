import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/views/currencies_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/CurrencyRate.dart';



class FollowExchangeRatesScreen extends StatefulWidget {
  const FollowExchangeRatesScreen({Key? key}) : super(key: key);

  @override
  State<FollowExchangeRatesScreen> createState() =>
      _FollowExchangeRatesScreenState();
}

class _FollowExchangeRatesScreenState extends State<FollowExchangeRatesScreen> {
  List<String> currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "PLN"];
  String _fromController = "USD";
  String _toController = "EUR";

  Future<bool> checkIfObjectExists(
      FirebaseFirestore firestore, String fromValue, String toValue) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if(user != null){
        QuerySnapshot querySnapshot = await firestore
            .collection('followedCurrencies')
            .where('from', isEqualTo: fromValue)
            .where('to', isEqualTo: toValue)
            .where('userId', isEqualTo: user.uid)
            .get();

        return querySnapshot.docs.isNotEmpty;
      }
      else{
        print("User does not exist");
        return false;
      }

    } catch (e) {
      print('Wystąpił błąd: $e');
      throw e;
    }
  }


  // Metoda do zapisywania przeliczników do kolekcji followedCurrencies
  void _addCurrencies() async{
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        bool exists = await checkIfObjectExists(firestore, _fromController, _toController);

        if(exists){
          print("Object already exists");
        }
        else{
          firestore.collection('followedCurrencies').add({
            'from': _fromController,
            'to': _toController,
            "userId": user.uid
          });

          print('Currency rate added successfully!');
        }
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error adding currency rate: $e');
    }

    Navigator.pop(context);
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
              ElevatedButton(
                onPressed: () async {
                  // SharedPreferences prefs = await SharedPreferences.getInstance();
                  // await prefs.setString('fromCurrency', _fromController);
                  // await prefs.setString('toCurrency', _toController);

                  _addCurrencies(); // Zamknięcie bieżącego ekranu
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
