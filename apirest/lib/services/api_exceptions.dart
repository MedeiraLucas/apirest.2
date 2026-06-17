/// Exceções customizadas usadas pelos services da aplicação.
/// Permitem que a UI exiba mensagens amigáveis e específicas
/// para cada tipo de falha de rede.

/// Lançada quando a requisição excede o tempo limite (10s)
class ApiTimeoutException implements Exception {
  final String message;
  ApiTimeoutException([this.message = 'A requisição demorou muito para responder.']);

  @override
  String toString() => message;
}

/// Lançada quando não há conexão com a internet (SocketException)
class SemConexaoException implements Exception {
  final String message;
  SemConexaoException([this.message = 'Sem conexão com a internet. Verifique sua rede.']);

  @override
  String toString() => message;
}

/// Lançada quando o servidor responde com status != 200
/// (ex: 400, 404, 500)
class ApiErrorException implements Exception {
  final int statusCode;
  final String message;

  ApiErrorException(this.statusCode, [String? message])
      : message = message ?? _mensagemPadrao(statusCode);

  static String _mensagemPadrao(int code) {
    switch (code) {
      case 400:
        return 'Requisição inválida (400).';
      case 401:
        return 'Não autorizado (401).';
      case 404:
        return 'Recurso não encontrado (404).';
      case 500:
        return 'Erro interno do servidor (500).';
      default:
        return 'Erro do servidor: status $code.';
    }
  }

  @override
  String toString() => message;
}
