import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/endereco.dart';
import 'api_exceptions.dart';

/// Serviço responsável por consultar a API pública ViaCEP.
/// Documentação: https://viacep.com.br
class CepService {
  static const _baseUrl = 'https://viacep.com.br/ws';
  static const _timeout = Duration(seconds: 10);

  /// Busca o endereço correspondente ao [cep] informado.
  ///
  /// [cep] deve conter exatamente 8 dígitos numéricos (sem hífen).
  ///
  /// Lança:
  /// - [ApiTimeoutException] se a requisição exceder 10s
  /// - [SemConexaoException] se não houver internet
  /// - [ApiErrorException] se o status HTTP for diferente de 200
  /// - [Exception] se o CEP não for encontrado (ViaCEP retorna {"erro": true})
  Future<Endereco> buscar(String cep) async {
    final uri = Uri.parse('$_baseUrl/$cep/json/');

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiErrorException(response.statusCode);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // ViaCEP retorna {"erro": true} (sem statusCode de erro) quando o
      // CEP é válido no formato mas não existe na base
      if (data['erro'] == true) {
        throw Exception('CEP não encontrado.');
      }

      return Endereco.fromJson(data);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw SemConexaoException();
    }
  }
}
