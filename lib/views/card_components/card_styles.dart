import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardStyles {
  CardStyles._();

  static Widget red = Container(
    width: double.maxFinite,
    height: double.maxFinite,
    color: Color(0xffe31010),
  );

  static Widget customColor(Color color) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: color,
    );
  }

  static Widget customGradient(LinearGradient gradient) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(gradient: gradient),
    );
  }

  static LinearGradient blueGradient = LinearGradient(
    colors: [Colors.blue, Colors.lightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient orangeGradient = LinearGradient(
    colors: [Colors.red, Colors.orange],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient purpleGradient = LinearGradient(
    colors: [Colors.purple, Colors.deepPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient greenGradient = LinearGradient(
    colors: [Colors.green, Colors.lightGreen],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static LinearGradient yellowGradient = LinearGradient(
    colors: [Colors.yellow, Colors.amber],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient tealGradient = LinearGradient(
    colors: [Colors.teal, Colors.cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient pinkGradient = LinearGradient(
    colors: [Colors.pink, Colors.deepPurple],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static LinearGradient limeGradient = LinearGradient(
    colors: [Colors.lime, Colors.lightGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient indigoGradient = LinearGradient(
    colors: [Colors.indigo, Colors.blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient greyGradient = LinearGradient(
    colors: [Colors.grey, Colors.blueGrey],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
