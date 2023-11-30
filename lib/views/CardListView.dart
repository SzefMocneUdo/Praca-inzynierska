import 'package:awesome_card/awesome_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'card_components/card_styles.dart';
import 'card_components/card_utilis.dart';

class PaymentCard {
  final CardType type;
  final String number;
  final String name;
  final int month; // Updated to int
  final int year; // Updated to int
  final String cvv;

  PaymentCard({
    required this.type,
    required this.number,
    required this.name,
    required this.month,
    required this.year,
    required this.cvv,
  });
}

class CardListView extends StatefulWidget {
  @override
  _CardListViewState createState() => _CardListViewState();
}
class _CardListViewState extends State<CardListView> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<bool> showBackList = []; // Lista flag showBack dla każdej karty
  late Future<List<PaymentCard>> _creditCardsFuture;

  @override
  void initState() {
    super.initState();
    _initShowBackList(); // Inicjalizacja listy flag showBack
    _creditCardsFuture = _getCreditCards(); // Initialize the future
  }

  void _initShowBackList() {
    // Utwórz listę flag showBack tylko raz przed pętlą
    setState(() {
      showBackList.clear(); // Wyczyść listę, aby uniknąć błędów w przypadku aktualizacji stanu
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
                      // Zaktualizuj flagę showBack dla konkretnej karty
                      setState(() {
                        showBackList[index] = !showBackList[index];
                      });
                    },
                    child: CreditCard(
                      cardNumber: card.number,
                      cardExpiry: "${card.month}/${card.year}",
                      cardHolderName: card.name,
                      cvv: card.cvv,
                      showBackSide: showBackList[index], // Ustaw showBack dla konkretnej karty
                      frontBackground: CardStyles.customGradient(CardStyles.blueGradient),
                      backBackground: CardStyles.customGradient(CardStyles.blueGradient),
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
      _initShowBackList(); // Inicjalizacja listy flag showBack tylko raz przed pętlą
    }

    List<PaymentCard> cards = [];
    query.docs.forEach((cardSnapshot) {
      PaymentCard card = _buildPaymentCard(cardSnapshot);
      cards.add(card);

      if (showBackList.length <= cards.length) {
        showBackList.add(false); // Dla każdej nowej karty dodaj domyślną wartość false
      }
    });

    return cards;
  }

  PaymentCard _buildPaymentCard(DocumentSnapshot cardSnapshot) {
    return PaymentCard(
      type: CardUtils.getCardType(cardSnapshot['cardNumber']),
      number: cardSnapshot['cardNumber'],
      name: cardSnapshot['cardHolder'],
      month: cardSnapshot['expiryMonth'], // Assuming this is an int in Firestore
      year: cardSnapshot['expiryYear'],   // Assuming this is an int in Firestore
      cvv: cardSnapshot['cvv'],
    );
  }
}
