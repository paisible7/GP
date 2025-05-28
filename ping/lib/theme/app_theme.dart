import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF001492); // Bleu
  static const Color secondary = Color(0xFF53AE32); // Vert
  static const Color textColor = Colors.black; // Texte
  static const Color background = Colors.white;

  static const Color primarySoft = Color(0xFF7A9BD0); // Bleu adouci
  static const Color secondarySoft = Color(0xFF9DDC84); // Vert adouci

  static const Color error = Color(0xFFD00E0E);
  static const Color success = Color(0xFF16AE26);
  static const Color warning = Color(0xFFEB8600);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF001492), Color(0xFF53AE32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}



/*

class AppColor {
  static const Color primary = Color(0xFF001492);
  static Color primarySoft = Color(0xFF548DF3);
  static Color primaryExtraSoft = Color(0xFFEFF3FC);
  static Color secondary = Color(0xFF1B1F24);
  static const Color secondarySoft = Color(0xFF9FA8DA);
  static const Color secondaryExtraSoft = Color(0xFFE8EAF6);
  static Color error = Color(0xFFD00E0E);
  static Color success = Color(0xFF16AE26);
  static Color warning = Color(0xFFEB8600);
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF001492), Color(0xFF001492)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}*/

