import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../repositories/database_repository.dart';
import '../widgets/pokemon_card.dart';
import '../services/poke_api_service.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _db = DatabaseRepository();
  final _api = PokeApiService();
  List<Pokemon> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    final favs = await _db.getFavorites();
    setState(() {
      _favorites = favs;
      _loading = false;
    });
  }

  void _openDetail(Pokemon pokemon) async {
    // Tenta buscar dados completos
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
    _loadFavorites(); // Atualiza após voltar (pode ter removido favorito)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text(
          'Favoritos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_border, size: 64, color: Colors.black26),
                      SizedBox(height: 12),
                      Text(
                        'Nenhum favorito ainda.',
                        style: TextStyle(color: Colors.black45),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Toque na ⭐ nos detalhes de um pokémon.',
                        style: TextStyle(color: Colors.black38, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _favorites.length,
                  itemBuilder: (_, i) => PokemonCard(
                    pokemon: _favorites[i],
                    onTap: () => _openDetail(_favorites[i]),
                  ),
                ),
    );
  }
}
