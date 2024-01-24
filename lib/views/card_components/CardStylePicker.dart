import 'package:flutter/material.dart';

import 'CardStyles.dart';

class CardStylePicker extends StatefulWidget {
  final ValueChanged<Widget?> onStyleSelected;

  const CardStylePicker({Key? key, required this.onStyleSelected})
      : super(key: key);

  @override
  _CardStylePickerState createState() => _CardStylePickerState();
}

class _CardStylePickerState extends State<CardStylePicker> {
  Widget? selectedCardStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Card Style'),
              content: Container(
                width: double.maxFinite,
                height: 200.0,
                child: ListView(
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: selectedCardStyle == CardStyles.red
                                ? Colors.red
                                : Colors.red,
                            radius: 12.0,
                          ),
                          SizedBox(width: 10.0),
                          Text('Red'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedCardStyle = CardStyles.red;
                        });
                        Navigator.pop(context);
                        widget.onStyleSelected(selectedCardStyle);
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selectedCardStyle ==
                                        CardStyles.customGradient(
                                            CardStyles.blueGradient)
                                    ? CardStyles.blueGradient
                                    : CardStyles.blueGradient,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text('Blue Gradient'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedCardStyle = CardStyles.customGradient(
                              CardStyles.blueGradient);
                        });
                        Navigator.pop(context);
                        widget.onStyleSelected(selectedCardStyle);
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selectedCardStyle ==
                                        CardStyles.customGradient(
                                            CardStyles.orangeGradient)
                                    ? CardStyles.orangeGradient
                                    : CardStyles.orangeGradient,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text('Orange Gradient'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedCardStyle = CardStyles.customGradient(
                              CardStyles.orangeGradient);
                        });
                        Navigator.pop(context);
                        widget.onStyleSelected(selectedCardStyle);
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selectedCardStyle ==
                                        CardStyles.customGradient(
                                            CardStyles.purpleGradient)
                                    ? CardStyles.purpleGradient
                                    : CardStyles.purpleGradient,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text('Purple Gradient'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedCardStyle = CardStyles.customGradient(
                              CardStyles.purpleGradient);
                        });
                        Navigator.pop(context);
                        widget.onStyleSelected(selectedCardStyle);
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selectedCardStyle ==
                                        CardStyles.customGradient(
                                            CardStyles.greenGradient)
                                    ? CardStyles.greenGradient
                                    : CardStyles.greenGradient,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text('Green Gradient'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedCardStyle = CardStyles.customGradient(
                              CardStyles.greenGradient);
                        });
                        Navigator.pop(context);
                        widget.onStyleSelected(selectedCardStyle);
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selectedCardStyle ==
                                        CardStyles.customGradient(
                                            CardStyles.yellowGradient)
                                    ? CardStyles.yellowGradient
                                    : CardStyles.yellowGradient,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text('Yellow Gradient'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedCardStyle = CardStyles.customGradient(
                              CardStyles.yellowGradient);
                        });
                        Navigator.pop(context);
                        widget.onStyleSelected(selectedCardStyle);
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selectedCardStyle ==
                                        CardStyles.customGradient(
                                            CardStyles.limeGradient)
                                    ? CardStyles.limeGradient
                                    : CardStyles.limeGradient,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text('Lime Gradient'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedCardStyle = CardStyles.customGradient(
                              CardStyles.limeGradient);
                        });
                        Navigator.pop(context);
                        widget.onStyleSelected(selectedCardStyle);
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selectedCardStyle ==
                                        CardStyles.customGradient(
                                            CardStyles.greyGradient)
                                    ? CardStyles.greyGradient
                                    : CardStyles.greyGradient,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text('Grey Gradient'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedCardStyle = CardStyles.customGradient(
                              CardStyles.greyGradient);
                        });
                        Navigator.pop(context);
                        widget.onStyleSelected(selectedCardStyle);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Text('Select Card Style'),
    );
  }
}
