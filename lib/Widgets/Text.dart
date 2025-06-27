import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.displayText,
    required this.styleVariant,
  });

  final String displayText;
  final String styleVariant;

  @override
  Widget build(BuildContext context) {
    style() {
      switch (styleVariant){
        case 'title':
          return TextStyle(fontSize: 24, color : Color.fromARGB(255, 10, 140, 214), fontWeight: FontWeight.bold);
          case 'subtitle':
          return TextStyle(fontSize: 20, color : Color.fromARGB(255, 10, 140, 214), fontWeight: FontWeight.bold);
         default:
          return TextStyle(fontSize: 16, color : Color.fromARGB(255, 10, 140, 214), fontWeight: FontWeight.normal);
      }
    }

    return Text(displayText,style: style(),
    );
  }
}