import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/evolution.dart';

class EvolutionChainWidget extends StatelessWidget {
  final EvolutionChain chain;
  final void Function(int id, String name)? onTap;

  const EvolutionChainWidget({super.key, required this.chain, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (chain.stages.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < chain.stages.length; i++) ...[
            if (i > 0) _arrow(chain.stages[i].minLevel),
            _stageWidget(chain.stages[i]),
          ],
        ],
      ),
    );
  }

  Widget _arrow(int? level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
          if (level != null)
            Text(
              'Nv.$level',
              style: const TextStyle(fontSize: 10, color: Colors.black45),
            ),
        ],
      ),
    );
  }

  Widget _stageWidget(EvolutionStage stage) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(stage.id, stage.name) : null,
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: stage.imageUrl,
            width: 72,
            height: 72,
            placeholder: (_, __) => const SizedBox(
              width: 72,
              height: 72,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.catching_pokemon, size: 48, color: Colors.black26),
          ),
          const SizedBox(height: 4),
          Text(
            stage.capitalizedName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
