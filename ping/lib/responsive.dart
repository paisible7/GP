import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    required this.desktop,
  }): super(key: key);

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;
    if (size.width > 600) {
      return desktop;
    }
    else {
      return mobile;
    }
  }
}
