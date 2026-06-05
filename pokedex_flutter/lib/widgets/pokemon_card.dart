import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import 'type_chip.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;

  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types[0] : 'normal';
    final bgColor = TypeChip.colorForType(primaryType).withOpacity(0.15);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TypeChip.colorForType(primaryType).withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            // Número ao fundo
            Positioned(
              right: 8,
              bottom: 8,
              child: Text(
                pokemon.formattedId,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: TypeChip.colorForType(primaryType).withOpacity(0.2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  Text(
                    pokemon.capitalizedName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Tipos
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: pokemon.types
                        .map((t) => TypeChip(type: t, small: true))
                        .toList(),
                  ),
                  const Spacer(),
                  // Imagem
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      height: 90,
                      width: 90,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(
                        height: 90,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.catching_pokemon,
                        size: 60,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
