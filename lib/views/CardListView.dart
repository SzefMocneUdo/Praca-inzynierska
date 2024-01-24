import 'package:awesome_card/awesome_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/PaymentCard.dart';
import 'card_components/CardStyles.dart';
import 'card_components/CardUtilis.dart';

class CardListView extends StatefulWidget {
  @override
  _CardListViewState createState() => _CardListViewState();
}

class _CardListViewState extends State<CardListView> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<bool> showBackList = [];
  late Future<List<PaymentCard>> _creditCardsFuture;

  @override
  void initState() {
    super.initState();
    _initShowBackList();
    _creditCardsFuture = _getCreditCards();
  }

  void _initShowBackList() {
    setState(() {
      showBackList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Credit Cards"),
      ),
      body: FutureBuilder<List<PaymentCard>>(
        future: _creditCardsFuture,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            List<PaymentCard> cards = snapshot.data!;
            return ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                PaymentCard card = cards[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showBackList[index] = !showBackList[index];
                      });
                    },
                    child: CreditCard(
                      cardNumber: card.number,
                      cardExpiry: "${card.month}/${card.year}",
                      cardHolderName: card.name,
                      cvv: card.cvv,
                      showBackSide: showBackList[index],
                      frontBackground:
                          CardStyles.customGradient(CardStyles.blueGradient),
                      backBackground:
                          CardStyles.customGradient(CardStyles.blueGradient),
                      showShadow: true,
                      textExpDate: 'Exp. Date',
                      textName: 'Card Holder',
                      textExpiry: 'MM/YY',
                      frontTextColor: Colors.black,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<PaymentCard>> _getCreditCards() async {
    User? user = _auth.currentUser;
    String? userId = user?.uid;

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('cards')
        .where('userId', isEqualTo: userId)
        .get();

    if (showBackList.isEmpty) {
      _initShowBackList();
    }

    List<PaymentCard> cards = [];
    query.docs.forEach((cardSnapshot) {
      PaymentCard card = _buildPaymentCard(cardSnapshot);
      cards.add(card);

      if (showBackList.length <= cards.length) {
        showBackList.add(false);
      }
    });

    return cards;
  }

  PaymentCard _buildPaymentCard(DocumentSnapshot cardSnapshot) {
    return PaymentCard(
      type: CardUtils.getCardType(cardSnapshot['cardNumber']),
      number: cardSnapshot['cardNumber'],
      name: cardSnapshot['cardHolder'],
      month: cardSnapshot['expiryMonth'],
      year: cardSnapshot['expiryYear'],
      cvv: cardSnapshot['cvv'],
    );
  }
}
