import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';
import 'api_exceptions.dart';

/// Serviço responsável por consultar a PokeAPI (segunda API pública).
/// Documentação: https://pokeapi.co
class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2/pokemon';
  static const _timeout = Duration(seconds: 10);

  /// Busca os dados do pokémon pelo [nomeOuId]
  /// (ex: "pikachu", "charizard", "25").
  ///
  /// Lança:
  /// - [ApiTimeoutException] se a requisição exceder 10s
  /// - [SemConexaoException] se não houver internet
  /// - [ApiErrorException] se o status HTTP for diferente de 200
  ///   (ex: 404 quando o pokémon não existe)
  Future<Pokemon> buscar(String nomeOuId) async {
    final termo = nomeOuId.trim().toLowerCase();
    final uri = Uri.parse('$_baseUrl/$termo');

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiErrorException(
          response.statusCode,
          response.statusCode == 404
              ? 'Pokémon "$nomeOuId" não encontrado.'
              : null,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Pokemon.fromJson(data);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw SemConexaoException();
    }
  }
}
