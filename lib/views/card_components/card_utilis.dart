// card_utils.dart
import 'package:awesome_card/extra/card_type.dart';
import 'package:flutter/material.dart';

import 'card_strings.dart';

import 'package:flutter/material.dart';

class PaymentCard {
  CardType? type;
  String? number;
  String? name;
  int? month;
  int? year;
  String? cvv;

  PaymentCard({
    this.type,
    this.number,
    this.name,
    this.month,
    this.year,
    this.cvv,
  });

  @override
  String toString() {
    return '[Type: $type, Number: $number, Name: $name, Month: $month, Year: $year, CVV: $cvv]';
  }
}


class CardUtils {
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.fieldReq;
    }

    if (value.length < 3 || value.length > 4) {
      return 'CVV is invalid';
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.fieldReq;
    }

    int year;
    int month;

    if (value.contains(RegExp(r'(/)'))) {
      var split = value.split(RegExp(r'(/)'));
      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      month = int.parse(value.substring(0, value.length));
      year = -1;
    }

    if ((month < 1) || (month > 12)) {
      return 'Expiry month is invalid';
    }

    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      return 'Expiry year is invalid';
    }

    if (!hasDateExpired(month, year)) {
      return "Card has expired";
    }
    return null;
  }

  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  static bool hasDateExpired(int month, int year) {
    return isNotExpired(year, month);
  }

  static bool isNotExpired(int year, int month) {
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(RegExp(r'(/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    return fourDigitsYear < now.year;
  }

  static String getCleanedNumber(String text) {
    RegExp regExp = RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  static Widget? getCardIcon(CardType? cardType) {
    String img = "";
    Icon? icon;

    switch (cardType) {
      case CardType.americanExpress:
        img = 'american_express.png';
        break;
      case CardType.dinersClub:
        img = 'diners_club.png';
        break;
      case CardType.discover:
        img = 'discover.png';
        break;
      case CardType.jcb:
        img = 'jcb.png';
        break;
      case CardType.masterCard:
        img = 'master_card.png';
        break;
      case CardType.maestro:
        img = 'maestro.png';
        break;
      case CardType.rupay:
        img = 'rupay.png';
        break;
      case CardType.visa:
        img = 'visa.png';
        break;
      case CardType.elo:
        img = 'elo.png';
        break;
      case CardType.other:
        icon = const Icon(
          Icons.credit_card,
          size: 24.0,
          color: Color(0xFFB8B5C3),
        );
        break;
      default:
        icon = const Icon(
          Icons.warning,
          size: 24.0,
          color: Color(0xFFB8B5C3),
        );
        break;
    }

    Widget? widget;

    if (img.isNotEmpty) {
      widget = Image.asset(
        'lib/assets/card_provider/$img',
        width: 40.0,
      );
    } else {
      widget = icon;
    }

    return widget;
  }

  static String? validateCardNum(String? input) {
    if (input == null || input.isEmpty) {
      return Strings.fieldReq;
    }

    input = getCleanedNumber(input);

    if (input.length < 8) {
      return Strings.numberIsInvalid;
    }

    int sum = 0;
    int length = input.length;

    for (var i = 0; i < length; i++) {
      int digit = int.parse(input[length - i - 1]);

      if (i % 2 == 1) {
        digit *= 2;
      }

      sum += digit > 9 ? (digit - 9) : digit;
    }

    if (sum % 10 == 0) {
      return null;
    }

    return Strings.numberIsInvalid;
  }

  static CardType getCardType(String cardNumber) {
    final rAmericanExpress = RegExp(r'^3[47][0-9]{0,}$');
    final rDinersClub = RegExp(r'^3(?:0[0-59]{1}|[689])[0-9]{0,}$');
    final rDiscover = RegExp(
        r'^(6011|65|64[4-9]|62212[6-9]|6221[3-9]|622[2-8]|6229[01]|62292[0-5])[0-9]{0,}$');
    final rJcb = RegExp(r'^(?:2131|1800|35)[0-9]{0,}$');
    final rMasterCard =
        RegExp(r'^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[01]|2720)[0-9]{0,}$');
    final rMaestro = RegExp(r'^(5[06789]|6)[0-9]{0,}$');
    final rRupay = RegExp(r'^(6522|6521|60)[0-9]{0,}$');
    final rVisa = RegExp(r'^4[0-9]{0,}$');
    final rElo = RegExp(
        r'^(4011(78|79)|43(1274|8935)|45(1416|7393|763(1|2))|50(4175|6699|67[0-7][0-9]|9000)|50(9[0-9][0-9][0-9])|627780|63(6297|6368)|650(03([^4])|04([0-9])|05(0|1)|05([7-9])|06([0-9])|07([0-9])|08([0-9])|4([0-3][0-9]|8[5-9]|9[0-9])|5([0-9][0-9]|3[0-8])|9([0-6][0-9]|7[0-8])|7([0-2][0-9])|541|700|720|727|901)|65165([2-9])|6516([6-7][0-9])|65500([0-9])|6550([0-5][0-9])|655021|65505([6-7])|6516([8-9][0-9])|65170([0-4]))');

    // Remove all the spaces from the card number
    cardNumber = cardNumber.trim().replaceAll(' ', '');

    if (rAmericanExpress.hasMatch(cardNumber)) {
      return CardType.americanExpress;
    } else if (rMasterCard.hasMatch(cardNumber)) {
      return CardType.masterCard;
    } else if (rVisa.hasMatch(cardNumber)) {
      return CardType.visa;
    } else if (rDinersClub.hasMatch(cardNumber)) {
      return CardType.dinersClub;
    } else if (rRupay.hasMatch(cardNumber)) {
      // Additional check to see if it's a discover card
      // Some discover card starts with 6011 and some rupay card starts with 60
      // If the card number matches the 6011 then it must be discover.

      // Note: Keep rupay check before the discover check
      if (rDiscover.hasMatch(cardNumber)) {
        return CardType.discover;
      } else {
        return CardType.rupay;
      }
    } else if (rDiscover.hasMatch(cardNumber)) {
      return CardType.discover;
    } else if (rJcb.hasMatch(cardNumber)) {
      return CardType.jcb;
    } else if (rElo.hasMatch(cardNumber)) {
      return CardType.elo;
    } else if (rMaestro.hasMatch(cardNumber)) {
      return CardType.maestro;
    }

    return CardType.other;
  }
}
