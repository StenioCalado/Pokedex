import 'package:flutter/material.dart';

class TypeChip extends StatelessWidget {
  final String type;
  final bool small;

  const TypeChip({super.key, required this.type, this.small = false});

  static const Map<String, Color> _typeColors = {
    'fire': Color(0xFFFF9741),
    'water': Color(0xFF3692DC),
    'grass': Color(0xFF38BF4B),
    'electric': Color(0xFFFBD100),
    'psychic': Color(0xFFFF6675),
    'ice': Color(0xFF4CD1C0),
    'dragon': Color(0xFF006FC9),
    'dark': Color(0xFF5B5366),
    'fairy': Color(0xFFFB89EB),
    'normal': Color(0xFF9DA0AA),
    'fighting': Color(0xFFFF6675),
    'flying': Color(0xFF89AAE3),
    'poison': Color(0xFFB567CE),
    'ground': Color(0xFFE2BF65),
    'rock': Color(0xFFB6A136),
    'bug': Color(0xFFA6B91A),
    'ghost': Color(0xFF735797),
    'steel': Color(0xFFB7B7CE),
  };

  static Color colorForType(String type) =>
      _typeColors[type.toLowerCase()] ?? const Color(0xFF9DA0AA);

  static const Map<String, String> _typeNames = {
    'fire': 'Fogo',
    'water': 'Água',
    'grass': 'Planta',
    'electric': 'Elétrico',
    'psychic': 'Psíquico',
    'ice': 'Gelo',
    'dragon': 'Dragão',
    'dark': 'Sombrio',
    'fairy': 'Fada',
    'normal': 'Normal',
    'fighting': 'Lutador',
    'flying': 'Voador',
    'poison': 'Veneno',
    'ground': 'Terra',
    'rock': 'Pedra',
    'bug': 'Inseto',
    'ghost': 'Fantasma',
    'steel': 'Aço',
  };

  @override
  Widget build(BuildContext context) {
    final color = colorForType(type);
    final label = _typeNames[type.toLowerCase()] ?? type;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
