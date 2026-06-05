import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 255,
  });

  static const Map<String, String> _statNames = {
    'hp': 'HP',
    'attack': 'Ataque',
    'defense': 'Defesa',
    'special-attack': 'Atq. Esp.',
    'special-defense': 'Def. Esp.',
    'speed': 'Velocidade',
  };

  Color _barColor() {
    final ratio = value / maxValue;
    if (ratio < 0.33) return const Color(0xFFFF6675);
    if (ratio < 0.66) return const Color(0xFFFFD700);
    return const Color(0xFF38BF4B);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              _statNames[label] ?? label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / maxValue,
                minHeight: 8,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
