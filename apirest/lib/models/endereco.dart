/// Modelo de endereço retornado pela API ViaCEP
/// Documentação: https://viacep.com.br
class Endereco {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade; // cidade
  final String uf;
  final String? complemento;

  Endereco({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
    this.complemento,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      localidade: json['localidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
      complemento: json['complemento'] as String?,
    );
  }
}
