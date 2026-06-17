/// Modelo de Pokémon retornado pela PokeAPI
/// Documentação: https://pokeapi.co
class Pokemon {
  final int id;
  final String nome;
  final String imagemUrl;
  final int alturaDecimetros;
  final int pesoHectogramas;
  final List<String> tipos;

  Pokemon({
    required this.id,
    required this.nome,
    required this.imagemUrl,
    required this.alturaDecimetros,
    required this.pesoHectogramas,
    required this.tipos,
  });

  /// Altura em metros (a API retorna em decímetros)
  double get alturaMetros => alturaDecimetros / 10;

  /// Peso em kg (a API retorna em hectogramas)
  double get pesoQuilos => pesoHectogramas / 10;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>? ?? {};
    final tiposJson = json['types'] as List<dynamic>? ?? [];

    return Pokemon(
      id: json['id'] as int,
      nome: json['name'] as String,
      imagemUrl: (sprites['front_default'] as String?) ??
          (sprites['other']?['official-artwork']?['front_default']
              as String?) ??
          '',
      alturaDecimetros: json['height'] as int? ?? 0,
      pesoHectogramas: json['weight'] as int? ?? 0,
      tipos: tiposJson
          .map((t) => (t['type']?['name'] as String?) ?? '')
          .where((t) => t.isNotEmpty)
          .toList(),
    );
  }
}
