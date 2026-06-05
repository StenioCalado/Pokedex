import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/type_chip.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = PokeApiService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  final List<Pokemon> _pokemons = [];
  bool _loading = false;
  bool _loadingMore = false;
  int _offset = 0;
  static const int _pageSize = 20;

  final Set<String> _selectedTypes = {};
  static const List<String> _types = [
    'fire', 'water', 'grass', 'electric', 'psychic',
    'ice', 'dragon', 'dark', 'fairy', 'normal',
    'fighting', 'flying', 'poison', 'ground', 'rock',
    'bug', 'ghost', 'steel',
  ];

  @override
  void initState() {
    super.initState();
    _loadPokemons();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _selectedTypes.isEmpty &&
        _searchController.text.isEmpty) {
      _loadMore();
    }
  }

  Future<void> _loadPokemons() async {
    setState(() => _loading = true);
    try {
      final list = await _api.fetchPokemonList(limit: _pageSize, offset: 0);
      final pokemons = await Future.wait(
        list.map((p) => _api.fetchPokemon(p['name'] as String)),
      );
      setState(() {
        _pokemons
          ..clear()
          ..addAll(pokemons);
        _offset = _pageSize;
      });
    } catch (e) {
      _showError('Erro ao carregar pokémons');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final list = await _api.fetchPokemonList(
        limit: _pageSize,
        offset: _offset,
      );
      final pokemons = await Future.wait(
        list.map((p) => _api.fetchPokemon(p['name'] as String)),
      );
      setState(() {
        _pokemons.addAll(pokemons);
        _offset += _pageSize;
      });
    } catch (_) {} finally {
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _searchPokemon(String query) async {
    if (query.trim().isEmpty) {
      _loadPokemons();
      return;
    }
    setState(() => _loading = true);
    try {
      final pokemon = await _api.fetchPokemon(query.trim().toLowerCase());
      setState(() {
        _pokemons
          ..clear()
          ..add(pokemon);
      });
    } catch (_) {
      setState(() => _pokemons.clear());
      _showError('Pokémon "$query" não encontrado');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _filterByType(String type) async {
  setState(() {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
  });

  if (_selectedTypes.isEmpty) {
    _loadPokemons();
    return;
  }

  setState(() => _loading = true);
  try {
    // Busca os nomes de cada tipo selecionado
    final nameLists = await Future.wait(
      _selectedTypes.map((t) => _api.fetchPokemonNamesByType(t)),
    );

    // Intersecção: só pokémons que aparecem em TODOS os tipos selecionados
    Set<String> names = nameLists.first.toSet();
    for (final list in nameLists.skip(1)) {
      names = names.intersection(list.toSet());
    }

    // Limita a 40 pra não travar
    final limited = names.take(40).toList();
    final pokemons = await Future.wait(
      limited.map((n) => _api.fetchPokemon(n)),
    );

    setState(() {
      _pokemons
        ..clear()
        ..addAll(pokemons);
    });
  } catch (_) {
    _showError('Erro ao filtrar');
  } finally {
    setState(() => _loading = false);
  }
}

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _openDetail(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(pokemon: pokemon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text(
          'Pokédex',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            color: const Color(0xFFCC0000),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onSubmitted: _searchPokemon,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou número...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          _loadPokemons();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filtros por tipo
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final type = _types[i];
                final selected = _selectedTypes.contains(type);
                return GestureDetector(
                  onTap: () => _filterByType(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: selected
                          ? Border.all(
                              color: TypeChip.colorForType(type),
                              width: 2,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TypeChip(type: type, small: true),
                  ),
                );
              },
            ),
          ),

          // Grid de pokémons
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _pokemons.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum pokémon encontrado',
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _pokemons.length + (_loadingMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == _pokemons.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return PokemonCard(
                            pokemon: _pokemons[i],
                            onTap: () => _openDetail(_pokemons[i]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
