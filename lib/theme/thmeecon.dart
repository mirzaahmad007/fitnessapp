import 'package:flutter/material.dart';

class AppGradients extends ThemeExtension<AppGradients> {
  final Gradient cardGradient;
  final Gradient sidebarGradient;

  AppGradients({
    required this.cardGradient,
    required this.sidebarGradient,
  });

  // Light mode gradients
  static final light = AppGradients(
    cardGradient: LinearGradient(
      colors: [Colors.blue.shade200, Colors.blue.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    sidebarGradient: LinearGradient(
      colors: [Colors.grey.shade300, Colors.grey.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Dark mode gradients
  static final dark = AppGradients(
    cardGradient: LinearGradient(
      colors: [Colors.blue.shade700, Colors.blue.shade900],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    sidebarGradient: LinearGradient(
      colors: [Colors.grey.shade800, Colors.grey.shade900],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  @override
  AppGradients copyWith({Gradient? cardGradient, Gradient? sidebarGradient}) {
    return AppGradients(
      cardGradient: cardGradient ?? this.cardGradient,
      sidebarGradient: sidebarGradient ?? this.sidebarGradient,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return AppGradients(
      cardGradient: Gradient.lerp(cardGradient, other.cardGradient, t)!,
      sidebarGradient: Gradient.lerp(sidebarGradient, other.sidebarGradient, t)!,
    );
  }
}