import 'package:flutter/material.dart';

import '../theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: kLine),
      ),
      child: Icon(Icons.timer_outlined, size: size * 0.56, color: kInk),
    );
  }
}
