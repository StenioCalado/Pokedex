import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../repositories/database_repository.dart';
import '../services/poke_api_service.dart';
import '../widgets/type_chip.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _db = DatabaseRepository();
  final _api = PokeApiService();
  List<Pokemon> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final history = await _db.getHistory();
    setState(() {
      _history = history;
      _loading = false;
    });
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text('Deseja remover todo o histórico de visualizações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.clearHistory();
      _loadHistory();
    }
  }

  void _openDetail(Pokemon pokemon) async {
    try {
      final full = await _api.fetchPokemon(pokemon.id.toString());
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(pokemon: full)),
      );
    } catch (_) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(pokemon: pokemon)),
      );
    }
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text(
          'Histórico',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _clearHistory,
              tooltip: 'Limpar histórico',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.black26),
                      SizedBox(height: 12),
                      Text(
                        'Nenhum pokémon visitado ainda.',
                        style: TextStyle(color: Colors.black45),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = _history[i];
                    final primaryType =
                        p.types.isNotEmpty ? p.types[0] : 'normal';
                    final bgColor =
                        TypeChip.colorForType(primaryType).withOpacity(0.12);

                    return GestureDetector(
                      onTap: () => _openDetail(p),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TypeChip.colorForType(primaryType)
                                .withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: p.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.catching_pokemon,
                                size: 40,
                                color: Colors.black26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.capitalizedName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: p.types
                                        .map((t) => Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 6),
                                              child:
                                                  TypeChip(type: t, small: true),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              p.formattedId,
                              style: const TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
