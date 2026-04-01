import 'package:flutter/material.dart';

/// Gradientes pré-configurados para os cards do diário.
class CardGradientPreset {
  const CardGradientPreset({
    required this.id,
    required this.label,
    required this.gradient,
  });

  final String id;
  final String label;
  final LinearGradient gradient;

  static const white = CardGradientPreset(
    id: 'white',
    label: 'Branco',
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
    ),
  );

  static const cream = CardGradientPreset(
    id: 'cream',
    label: 'Creme',
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF1E8), Color(0xFFFFF9F5)],
    ),
  );

  static const orangeYellow = CardGradientPreset(
    id: 'orange_yellow',
    label: 'Laranja | Amarelo',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB088), Color(0xFFFFE5A0), Color(0xFFFFF4D6)],
    ),
  );

  static const pinkPurple = CardGradientPreset(
    id: 'pink_purple',
    label: 'Rosa | Roxo',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFCB4D8), Color(0xFFF3CFF7), Color(0xFFF3CFF7)],
    ),
  );

  static const purpleBlueWhite = CardGradientPreset(
    id: 'purple_blue_white',
    label: 'Roxo | Azul | Branco',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFEADCF8), Color(0xFFD6ECFA), Color(0xFFF0F8FF)],
    ),
  );

  static const mint = CardGradientPreset(
    id: 'mint',
    label: 'Verde menta',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFDFF5E1), Color(0xFFE8F8EC), Color(0xFFF5FBF6)],
    ),
  );

  static const sky = CardGradientPreset(
    id: 'sky',
    label: 'Céu',
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFD6ECFA), Color(0xFFE8F4FC), Color(0xFFF5FAFF)],
    ),
  );

  static const List<CardGradientPreset> all = [
    white,
    cream,
    orangeYellow,
    pinkPurple,
    purpleBlueWhite,
    mint,
    sky,
  ];

  static CardGradientPreset byId(String? id) {
    if (id == null || id.isEmpty) return white;
    return all.firstWhere((p) => p.id == id, orElse: () => white);
  }
}
