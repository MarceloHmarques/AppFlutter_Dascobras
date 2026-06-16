import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('lib/app/assets/img/LogoLonga.png', width: 180),
    );
  }
}
