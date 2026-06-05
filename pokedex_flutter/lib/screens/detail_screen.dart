import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../models/evolution.dart';
import '../services/poke_api_service.dart';
import '../repositories/database_repository.dart';
import '../widgets/type_chip.dart';
import '../widgets/stat_bar.dart';
import '../widgets/evolution_chain.dart';
import 'dart:async';

class DetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const DetailScreen({super.key, required this.pokemon});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _api = PokeApiService();
  final _db = DatabaseRepository();

  EvolutionChain? _evolutionChain;
  bool _loadingChain = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    try {
      print('💾 Salvando no histórico...');
      await _db.addToHistory(widget.pokemon);
      print('✅ Histórico salvo!');
    } catch (e) {
      print('❌ Erro no histórico: $e');
    }

    try {
      final fav = await _db.isFavorite(widget.pokemon.id);
      setState(() => _isFavorite = fav);
    } catch (e) {
      print('❌ Erro ao checar favorito: $e');
    }

    EvolutionChain chain;
    try {
      chain = await _api
          .fetchEvolutionChain(widget.pokemon.id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      print('❌ Erro na evolução: $e');
      chain = EvolutionChain(stages: []);
    }

    if (mounted) {
      setState(() {
        _evolutionChain = chain;
        _loadingChain = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _db.removeFavorite(widget.pokemon.id);
    } else {
      await _db.addFavorite(widget.pokemon);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  void _goToPokemon(int id, String name) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FutureBuilder<Pokemon>(
          future: _api.fetchPokemon(id.toString()),
          builder: (ctx, snap) {
            if (snap.hasData) return DetailScreen(pokemon: snap.data!);
            if (snap.hasError) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(child: Text('Erro ao carregar')),
              );
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Color get _primaryColor {
    final type = widget.pokemon.types.isNotEmpty
        ? widget.pokemon.types[0]
        : 'normal';
    return TypeChip.colorForType(type);
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar com imagem
          SliverAppBar(
            expandedHeight: 260,
            backgroundColor: _primaryColor,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${pokemon.capitalizedName}  ${pokemon.formattedId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                alignment: Alignment.center,
                children: [
                  Container(color: _primaryColor),
                  Positioned(
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 220,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      height: 160,
                      width: 160,
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          const CircularProgressIndicator(color: Colors.white),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.catching_pokemon, size: 120),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipos
                  Row(
                    children: pokemon.types
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: TypeChip(type: t),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Altura e peso
                  Row(
                    children: [
                      _infoBox('Altura', '${pokemon.height} m'),
                      const SizedBox(width: 12),
                      _infoBox('Peso', '${pokemon.weight} kg'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  if (pokemon.description.isNotEmpty) ...[
                    _sectionTitle('Sobre'),
                    const SizedBox(height: 8),
                    Text(
                      pokemon.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stats
                  _sectionTitle('Estatísticas Base'),
                  const SizedBox(height: 8),
                  ...pokemon.stats.entries.map(
                    (e) => StatBar(label: e.key, value: e.value),
                  ),

                  const SizedBox(height: 20),

                  // Cadeia de evolução
                  _sectionTitle('Cadeia de Evolução'),
                  const SizedBox(height: 12),
                  if (_loadingChain)
                    const Center(child: CircularProgressIndicator())
                  else if (_evolutionChain != null &&
                      _evolutionChain!.stages.length > 1)
                    EvolutionChainWidget(
                      chain: _evolutionChain!,
                      onTap: _goToPokemon,
                    )
                  else
                    const Text(
                      'Este pokémon não possui evoluções.',
                      style: TextStyle(color: Colors.black45, fontSize: 13),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _primaryColor,
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
