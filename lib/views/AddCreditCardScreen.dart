import 'package:awesome_card/awesome_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/PaymentCard.dart';
import 'NotificationsView.dart';
import 'card_components/CardStylePicker.dart';
import 'card_components/CardStyles.dart';
import 'card_components/CardUtilis.dart';
import 'card_components/InputFormatters.dart';

class AddCreditCardScreen extends StatefulWidget {
  @override
  _AddCreditCardScreenState createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  CardType? cardType;
  bool showBack = false;

  FocusNode cardNumberFocusNode = FocusNode();
  FocusNode expiryDateFocusNode = FocusNode();
  FocusNode cvvFocusNode = FocusNode();

  FirebaseAuth _auth = FirebaseAuth.instance;

  Widget? selectedCardStyle;

  @override
  void initState() {
    super.initState();
    cardNumberController.addListener(() {
      getCardTypeProvider();
      setState(() {});
    });
    expiryDateController.addListener(() {
      setState(() {});
    });
    cvvController.addListener(() {
      setState(() {
        showBack = cvvFocusNode.hasFocus;
      });
    });

    cardNumberFocusNode.addListener(() {
      setState(() {
        showBack = false;
      });
    });

    expiryDateFocusNode.addListener(() {
      setState(() {
        showBack = false;
      });
    });

    cvvFocusNode.addListener(() {
      setState(() {
        showBack = cvvFocusNode.hasFocus;
      });
    });
  }

  void getCardTypeProvider() {
    if (cardNumberController.text.length <= 6) {
      String cardNumber = CardUtils.getCleanedNumber(cardNumberController.text);
      CardType type = CardUtils.getCardType(cardNumber);

      if (type != cardType) {
        setState(() {
          cardType = type;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "New Card",
          style: TextStyle(color: Colors.black),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                setState(() {
                  showBack = !showBack;
                });
              },
              child: CreditCard(
                cardNumber: cardNumberController.text,
                cardExpiry: expiryDateController.text,
                cardHolderName: fullNameController.text,
                cvv: cvvController.text,
                showBackSide: showBack,
                frontBackground: selectedCardStyle ??
                    CardStyles.customGradient(CardStyles.blueGradient),
                backBackground: selectedCardStyle ??
                    CardStyles.customGradient(CardStyles.blueGradient),
                showShadow: true,
                textExpDate: 'Exp. Date',
                textName: 'Card Holder',
                textExpiry: 'MM/YY',
                frontTextColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(height: 20.0),
            CardStylePicker(
              onStyleSelected: (selectedStyle) {
                setState(() {
                  selectedCardStyle = selectedStyle;
                });
              },
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cardNumberController,
                    focusNode: cardNumberFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(19),
                      CardNumberInputFormatter(),
                    ],
                    onChanged: (value) {
                      getCardTypeProvider();
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Card number",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Icon(
                          Icons.credit_card,
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: fullNameController,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Card Holder",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: expiryDateController,
                    focusNode: expiryDateFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      CardMonthInputFormatter(),
                    ],
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "MM/YY",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextFormField(
                    controller: cvvController,
                    focusNode: cvvFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "CVV",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                String? cardNumValidation =
                    CardUtils.validateCardNum(cardNumberController.text);

                if (cardNumValidation != null) {
                  showErrorDialog(context, 'Error', cardNumValidation);
                  return;
                }

                String? cvvValidation =
                    CardUtils.validateCVV(cvvController.text);

                if (cvvValidation != null) {
                  showErrorDialog(context, 'Error', cvvValidation);
                  return;
                }

                String? dateValidation =
                    CardUtils.validateDate(expiryDateController.text);

                if (dateValidation != null) {
                  showErrorDialog(context, 'Error', dateValidation);
                  return;
                }

                User? user = _auth.currentUser;
                String? userId = user?.uid;

                bool isCardAlreadyAdded = await checkIfCardExists(
                  userId!,
                  cardNumberController.text,
                );

                if (isCardAlreadyAdded) {
                  showErrorDialog(
                    context,
                    'Error',
                    'This card number is already associated with your account.',
                  );
                  return;
                }

                PaymentCard paymentCard = PaymentCard(
                  type: cardType!,
                  number: cardNumberController.text,
                  name: fullNameController.text,
                  month: CardUtils.getExpiryDate(expiryDateController.text)[0],
                  year: CardUtils.getExpiryDate(expiryDateController.text)[1],
                  cvv: cvvController.text,
                );

                try {
                  await FirebaseFirestore.instance.collection('cards').add({
                    'userId': userId,
                    'cardNumber': paymentCard.number,
                    'cardHolder': paymentCard.name,
                    'expiryMonth': paymentCard.month,
                    'expiryYear': paymentCard.year,
                    'cvv': paymentCard.cvv,
                  });

                  Navigator.pop(context);
                } catch (error) {
                  print('Error saving to Firebase: $error');
                  showErrorDialog(context, 'Error',
                      'Failed to save card. Please try again.');
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkIfCardExists(String userId, String cardNumber) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('cards')
        .where('userId', isEqualTo: userId)
        .where('cardNumber', isEqualTo: cardNumber)
        .get();

    return query.docs.isNotEmpty;
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

  void showSuccessDialog(BuildContext context, PaymentCard paymentCard) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Card added successfully!'),
              SizedBox(height: 10),
              Text('Card Number: ${paymentCard.number}'),
              Text('Card Holder: ${paymentCard.name}'),
              Text('Expiry Date: ${paymentCard.month}/${paymentCard.year}'),
              Text('CVV: ${paymentCard.cvv}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
