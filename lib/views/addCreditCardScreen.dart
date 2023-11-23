import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/card_type.dart';
import 'components/card_utilis.dart';
import 'components/input_formatters.dart';

class AddCreditCardScreen extends StatefulWidget {
  @override
  _AddCreditCardScreenState createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  CardType cardType = CardType.Invalid;

  void getCardTypeProvider() {
    if (cardNumberController.text.length <= 6) {
      String cardNumber = CardUtils.getCleanedNumber(cardNumberController.text);
      CardType type = CardUtils.getCardTypeFrmNumber(cardNumber);

      if (type != cardType) {
        setState(() {
          cardType = type;
          print(cardType);
        });
      }
    }
  }

  @override
  void initState() {
    cardNumberController.addListener(() {
      getCardTypeProvider();
    });
    super.initState();
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  CardNumberInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: "Card number",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: CardUtils.getCardIcon(cardType),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    hintText: "Full name",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Icon(
                        Icons.account_circle_sharp,
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        hintText: "CVV",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(
                            Icons.key,
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
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        CardMonthInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: "MM/YY",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(
                            Icons.calendar_month,
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
              const SizedBox(height: 16.0), // Dodany odstęp
              ElevatedButton(
                onPressed: () {
                  // Obsługa naciśnięcia przycisku
                  // Możesz dodać tutaj kod do dodawania karty
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
