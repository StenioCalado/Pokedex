class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;
  final double height;
  final double weight;
  final Map<String, int> stats;
  final String description;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.stats,
    required this.description,
  });

  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  String get capitalizedName =>
      name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');

  factory Pokemon.fromJson(Map<String, dynamic> json, {String description = ''}) {
    final types = (json['types'] as List)
        .map((t) => t['type']['name'] as String)
        .toList();

    final stats = <String, int>{};
    for (final s in json['stats'] as List) {
      stats[s['stat']['name'] as String] = s['base_stat'] as int;
    }

    final imageUrl =
        json['sprites']['other']['official-artwork']['front_default'] as String? ??
        json['sprites']['front_default'] as String? ??
        '';

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      types: types,
      imageUrl: imageUrl,
      height: (json['height'] as int) / 10,
      weight: (json['weight'] as int) / 10,
      stats: stats,
      description: description,
    );
  }

  // Para salvar no banco local (favoritos/histórico)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'types': types.join(','),
      'image_url': imageUrl,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'] as int,
      name: map['name'] as String,
      types: (map['types'] as String).split(','),
      imageUrl: map['image_url'] as String,
      height: 0,
      weight: 0,
      stats: {},
      description: '',
    );
  }
}
