import 'package:flutter/material.dart';

import '../theme.dart';

enum DotState { empty, half, full }

class SessionDots extends StatelessWidget {
  const SessionDots({super.key, required this.states});
  final List<DotState> states;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in states)
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kInk, width: 1.2),
              color: s == DotState.full ? kInk : Colors.white,
              gradient: s == DotState.half
                  ? const LinearGradient(
                      colors: [kInk, kInk, Colors.white, Colors.white],
                      stops: [0, 0.5, 0.5, 1],
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
