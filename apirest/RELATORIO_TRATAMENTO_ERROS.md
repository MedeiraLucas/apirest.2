# Relatório de Tratamento de Erros

**Aplicativo:** Consumo de APIs REST (ViaCEP + PokeAPI)
**Disciplina:** Desenvolvimento Mobile — Aula 15
**Autor:** Eduardo Jhonathan Passos Neumann

---

## 1. Erros tratados e por que são importantes

O aplicativo trata três categorias de erro de rede em todas as chamadas HTTP (`CepService` e `PokemonService`), encapsuladas em exceções customizadas no arquivo `api_exceptions.dart`:

### 1.1 `TimeoutException` → `ApiTimeoutException`
Toda requisição é encadeada com `.timeout(Duration(seconds: 10))`. Se o servidor não responder dentro desse intervalo, o Dart lança `TimeoutException`, capturada e convertida em `ApiTimeoutException`.

**Importância:** sem esse tratamento, uma rede lenta ou um servidor sobrecarregado deixaria o app "travado" indefinidamente em estado de carregamento, sem nunca dar feedback ao usuário. Em uma aplicação real isso é frustrante e pode passar a impressão de que o app está com bug ou congelado.

### 1.2 `SocketException` → `SemConexaoException`
Lançada pelo pacote `http` quando o dispositivo não consegue resolver o DNS ou estabelecer conexão TCP — situação típica de **modo avião** ou área sem sinal.

**Importância:** é o erro de rede mais comum no dia a dia de um app mobile. Sem tratá-lo, o usuário veria uma exceção genérica não tratada (`Unhandled Exception`) ou, em telas com `FutureBuilder`/`try-catch` ausente, o app poderia até fechar (crash) em determinados fluxos.

### 1.3 Status HTTP diferente de 200 → `ApiErrorException`
Após receber a resposta, o código verifica `response.statusCode != 200` antes de tentar deserializar o corpo. Se for diferente, lança `ApiErrorException` com uma mensagem específica conforme o código (400, 401, 404, 500, etc.).

**Importância:** uma API pode responder normalmente (sem erro de conexão) mas indicar uma falha de negócio — por exemplo, **404** quando o Pokémon não existe na PokeAPI. Sem essa verificação, o app tentaria fazer `jsonDecode` em um corpo de erro (que tem formato diferente do esperado), gerando uma exceção de parsing confusa e sem relação aparente com a causa real.

### 1.4 Caso especial: CEP não encontrado (ViaCEP)
A API ViaCEP **não retorna status 404** para CEP inexistente — ela retorna `200 OK` com o corpo `{"erro": true}`. Por isso, o `CepService` verifica esse campo explicitamente após o parse e lança uma exceção própria ("CEP não encontrado").

**Importância:** esse é um exemplo de erro de **negócio mascarado como sucesso técnico**. Ignorá-lo faria o app tentar exibir um endereço com todos os campos vazios, confundindo o usuário (ele veria o card de resultado preenchido com traços "—" sem entender o motivo).

---

## 2. Como o usuário é informado

Em ambas as telas (`CepScreen` e `PokemonScreen`), o fluxo de feedback é o mesmo:

1. **Durante a requisição:** um `CircularProgressIndicator` centralizado é exibido (`_carregando = true`), e o botão de busca fica desabilitado para evitar requisições duplicadas.
2. **Em caso de erro:** um card vermelho (`Colors.red.shade50`) com ícone `Icons.error_outline_rounded` exibe a mensagem retornada por `e.toString()` — que corresponde ao `toString()` da exceção customizada lançada (ex: *"Sem conexão com a internet. Verifique sua rede."*, *"A requisição demorou muito para responder."*, *"CEP não encontrado."*, *"Pokémon "xyz" não encontrado."*).
3. **Em caso de sucesso:** o card de resultado é exibido normalmente (endereço ou dados do Pokémon).

Os três estados (`_carregando`, `_erro`, `_endereco`/`_pokemon`) são mutuamente exclusivos no `setState`, garantindo que a UI nunca mostre, por exemplo, o spinner de carregamento junto com uma mensagem de erro antiga.

---

## 3. Situações reais onde cada erro pode ocorrer

| Erro | Situação real no app |
|---|---|
| `ApiTimeoutException` | Usuário em uma rede móvel 3G lenta ou em local com sinal fraco consulta um CEP; o servidor demora a responder e a requisição é abortada após 10s. |
| `SemConexaoException` | Usuário está em modo avião, em elevador, ou em área sem cobertura, e tenta buscar um Pokémon. |
| `ApiErrorException (404)` | Usuário digita "pikachuu" (erro de digitação) na busca de Pokémon — a PokeAPI responde 404 pois esse pokémon não existe. |
| `ApiErrorException (500)` | A API está fora do ar temporariamente (manutenção, instabilidade) e responde com erro de servidor. |
| CEP `{"erro": true}` | Usuário digita um CEP com 8 dígitos válidos no formato, mas que não corresponde a nenhum endereço real cadastrado nos Correios (ex: "00000000"). |

---

## 4. O que aconteceria sem o tratamento

- **Sem `try-catch` algum:** qualquer uma das exceções acima (`TimeoutException`, `SocketException`, exceção de parsing JSON) subiria sem ser capturada. Em uma chamada `async` disparada por um botão, isso geraria um `Unhandled Exception` no console e, dependendo do contexto, um *crash* visível ou a tela ficando travada no estado de carregamento para sempre — o app pareceria "quebrado" sem nenhuma explicação para o usuário.

- **Sem tratamento de `TimeoutException`:** a chamada `await http.get(uri)` ficaria aguardando indefinidamente em uma rede instável. O `CircularProgressIndicator` giraria para sempre, sem nenhum botão de "tentar novamente" disponível, dando a impressão de app travado.

- **Sem tratamento de `SocketException`:** em modo avião, a exceção subiria como `Unhandled Exception: SocketException: Failed host lookup`. O usuário veria uma tela vermelha de erro do Flutter (em modo debug) ou, em release, o app poderia simplesmente não responder ao clique, sem qualquer mensagem.

- **Sem verificação de `statusCode != 200`:** ao buscar um Pokémon inexistente, a API retornaria 404 com um corpo `{"detail": "Not Found"}`. O código tentaria acessar `json['id']`, `json['name']`, etc., que não existem nesse corpo — lançando um `TypeError` ou `NoSuchMethodError` ("null is not a subtype of int"), uma mensagem totalmente incompreensível para o usuário final e difícil de depurar em produção.

- **Sem verificação de `{"erro": true}` da ViaCEP:** o app exibiria o card de "Endereço encontrado" com todos os campos vazios/traços, levando o usuário a pensar que o CEP existe mas está com cadastro incompleto — quando na verdade o CEP simplesmente não existe.

---

## Conclusão

O tratamento de erros implementado cobre tanto falhas de **infraestrutura de rede** (timeout, sem conexão) quanto falhas de **negócio/aplicação** (status HTTP de erro, e o caso particular da ViaCEP que retorna sucesso técnico com erro semântico). Essa camada de exceções customizadas (`api_exceptions.dart`) centraliza as mensagens, evita vazamento de detalhes técnicos para o usuário final e garante que a interface sempre tenha um estado visual correspondente — carregando, erro ou sucesso — nunca deixando o usuário sem feedback.
