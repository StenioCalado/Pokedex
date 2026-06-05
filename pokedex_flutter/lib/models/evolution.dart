class EvolutionStage {
  final int id;
  final String name;
  final String imageUrl;
  final int? minLevel;

  EvolutionStage({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.minLevel,
  });

  String get capitalizedName =>
      name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');
}

class EvolutionChain {
  final List<EvolutionStage> stages;

  EvolutionChain({required this.stages});
}
