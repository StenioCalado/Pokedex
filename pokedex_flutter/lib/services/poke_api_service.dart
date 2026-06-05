import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../models/evolution.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  // Busca lista paginada de pokémons
  Future<List<Map<String, dynamic>>> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pokemon?limit=$limit&offset=$offset'),
    );
    if (response.statusCode != 200) throw Exception('Erro ao buscar lista');
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // Busca pokémon por nome ou ID
  Future<Pokemon> fetchPokemon(String nameOrId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pokemon/${nameOrId.toLowerCase()}'),
    );
    if (response.statusCode != 200) {
      throw Exception('Pokémon "$nameOrId" não encontrado');
    }
    final data = jsonDecode(response.body);
    final description = await _fetchDescription(data['id'] as int);
    return Pokemon.fromJson(data, description: description);
  }

  // Busca descrição (flavor text) em português ou inglês
  Future<String> _fetchDescription(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon-species/$id'),
      );
      if (response.statusCode != 200) return '';
      final data = jsonDecode(response.body);
      final entries = data['flavor_text_entries'] as List;

      // Tenta pt-BR primeiro, depois en
      final ptEntry = entries.firstWhere(
        (e) => e['language']['name'] == 'pt-BR',
        orElse: () => null,
      );
      if (ptEntry != null) {
        return (ptEntry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }

      final enEntry = entries.firstWhere(
        (e) => e['language']['name'] == 'en',
        orElse: () => null,
      );
      if (enEntry != null) {
        return (enEntry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }
    } catch (_) {}
    return '';
  }

  // Busca cadeia de evolução
  Future<EvolutionChain> fetchEvolutionChain(int pokemonId) async {
    // Primeiro pega a species para obter a URL da chain
    final speciesRes = await http.get(
      Uri.parse('$_baseUrl/pokemon-species/$pokemonId'),
    );
    if (speciesRes.statusCode != 200) return EvolutionChain(stages: []);

    final speciesData = jsonDecode(speciesRes.body);
    final chainUrl = speciesData['evolution_chain']['url'] as String;

    final chainRes = await http.get(Uri.parse(chainUrl));
    if (chainRes.statusCode != 200) return EvolutionChain(stages: []);

    final chainData = jsonDecode(chainRes.body);
    final stages = <EvolutionStage>[];

    await _parseChain(chainData['chain'], stages, null);
    return EvolutionChain(stages: stages);
  }

  Future<void> _parseChain(
    Map<String, dynamic> node,
    List<EvolutionStage> stages,
    int? minLevel,
  ) async {
    final name = node['species']['name'] as String;
    final url = node['species']['url'] as String;
    final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);

    final imgUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    stages.add(
      EvolutionStage(id: id, name: name, imageUrl: imgUrl, minLevel: minLevel),
    );

    final evolvesTo = node['evolves_to'] as List;
    for (final next in evolvesTo) {
      final details = next['evolution_details'] as List;
      final level = details.isNotEmpty ? details[0]['min_level'] as int? : null;
      await _parseChain(next, stages, level);
    }
  }

  Future<List<String>> fetchPokemonNamesByType(String type) async {
    final response = await http.get(Uri.parse('$_baseUrl/type/$type'));
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body);
    return (data['pokemon'] as List)
        .map((p) => p['pokemon']['name'] as String)
        .toList();
  }
}
