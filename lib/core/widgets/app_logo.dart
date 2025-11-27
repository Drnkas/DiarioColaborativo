import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key, this.size = 48}) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_rosa.png',
      width: 50,
      height: 50,
    );
  }
}
