# Consumo de APIs REST 🌐

Aplicativo Flutter que consome **duas APIs públicas** com tratamento completo de erros de rede.

> **Atividade Prática — Aula 15: HTTP e Consumo de APIs REST**
> Faculdade Senac Joinville — Prof. Me. Gabriel Caixeta Silva

---

## APIs utilizadas

| API | Uso | Autenticação |
|---|---|---|
| [ViaCEP](https://viacep.com.br) | Preenchimento automático de endereço a partir do CEP | Não requer chave |
| [PokeAPI](https://pokeapi.co) | Busca de dados de Pokémon por nome ou número | Não requer chave |

Ambas são **gratuitas e sem necessidade de cadastro/API key** — basta ter conexão com a internet.

---

## Funcionalidades

### 🔍 Consulta de CEP (ViaCEP)
- Campo de texto numérico, limitado a 8 dígitos
- Validação local antes da requisição (8 dígitos numéricos)
- Preenchimento automático de logradouro, bairro, cidade e UF
- Tratamento do caso `{"erro": true}` (CEP inexistente)

### 🐾 Busca de Pokémon (PokeAPI)
- Busca por nome (ex: `pikachu`) ou número (ex: `25`)
- Exibe imagem oficial, tipos (com cores), altura e peso
- Tratamento de 404 (Pokémon não encontrado)

### ⚠️ Tratamento de erros (em ambas as telas)
- `TimeoutException` → timeout de 10s configurado em todas as requisições
- `SocketException` → mensagem de "sem conexão com a internet"
- Status HTTP ≠ 200 → mensagem específica por código (400/401/404/500)
- `CircularProgressIndicator` durante o carregamento

---

## Arquitetura

```
lib/
├── main.dart                   ← MaterialApp
├── models/
│   ├── endereco.dart            ← Endereco.fromJson (ViaCEP)
│   └── pokemon.dart              ← Pokemon.fromJson (PokeAPI)
├── services/
│   ├── api_exceptions.dart       ← Exceções customizadas
│   ├── cep_service.dart          ← CepService (ViaCEP)
│   └── pokemon_service.dart      ← PokemonService (PokeAPI)
└── screens/
    ├── home_screen.dart          ← NavigationBar (2 abas)
    ├── cep_screen.dart            ← Tela de consulta de CEP
    └── pokemon_screen.dart        ← Tela de busca de Pokémon
```

---

## Tratamento de erros — visão geral

```dart
try {
  final response = await http.get(uri).timeout(Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw ApiErrorException(response.statusCode);
  }

  return Modelo.fromJson(jsonDecode(response.body));
} on TimeoutException {
  throw ApiTimeoutException();
} on SocketException {
  throw SemConexaoException();
}
```

Veja o relatório completo em [`RELATORIO_TRATAMENTO_ERROS.md`](./RELATORIO_TRATAMENTO_ERROS.md).

---

## Permissão de Internet

Já configurada em `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Como rodar

```bash
flutter pub get
flutter run
```

### Testando o tratamento de erros
- **Timeout/Sem conexão:** ative o **modo avião** no emulador e tente buscar
- **404 (Pokémon):** busque por um nome inexistente, ex: `pokemonquenaoexiste`
- **CEP não encontrado:** busque `00000000`
- **CEP inválido:** digite menos de 8 dígitos

---

## Autor

**Lucas Medeira**
Curso: ADS — Faculdade Senac Joinville
