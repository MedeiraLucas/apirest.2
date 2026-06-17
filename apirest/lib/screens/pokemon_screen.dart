import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final _nomeController = TextEditingController();
  final _pokemonService = PokemonService();

  bool _carregando = false;
  String? _erro;
  Pokemon? _pokemon;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _buscarPokemon() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      setState(() {
        _erro = 'Digite o nome ou número do Pokémon.';
        _pokemon = null;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
      _pokemon = null;
    });

    try {
      final pokemon = await _pokemonService.buscar(nome);
      setState(() => _pokemon = pokemon);
    } catch (e) {
      // Captura ApiTimeoutException, SemConexaoException ou ApiErrorException
      setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Buscar Pokémon'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Campo de busca ────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome ou número',
                        hintText: 'Ex: pikachu, 25, charizard...',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _buscarPokemon(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _carregando ? null : _buscarPokemon,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Indicador de carregamento ────────────────────────────────
            if (_carregando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),

            // ── Mensagem de erro ─────────────────────────────────────────
            if (_erro != null && !_carregando)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _erro!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Resultado ─────────────────────────────────────────────────
            if (_pokemon != null && !_carregando) _ResultadoPokemon(pokemon: _pokemon!),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResultadoPokemon extends StatelessWidget {
  final Pokemon pokemon;
  const _ResultadoPokemon({required this.pokemon});

  Color _corPorTipo(String tipo) {
    const cores = {
      'fire': Color(0xFFEE8130),
      'water': Color(0xFF6390F0),
      'grass': Color(0xFF7AC74C),
      'electric': Color(0xFFF7D02C),
      'psychic': Color(0xFFF95587),
      'ice': Color(0xFF96D9D6),
      'dragon': Color(0xFF6F35FC),
      'dark': Color(0xFF705746),
      'fairy': Color(0xFFD685AD),
      'normal': Color(0xFFA8A77A),
      'fighting': Color(0xFFC22E28),
      'flying': Color(0xFFA98FF3),
      'poison': Color(0xFFA33EA1),
      'ground': Color(0xFFE2BF65),
      'rock': Color(0xFFB6A136),
      'bug': Color(0xFFA6B91A),
      'ghost': Color(0xFF735797),
      'steel': Color(0xFFB7B7CE),
    };
    return cores[tipo] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Imagem
          if (pokemon.imagemUrl.isNotEmpty)
            Image.network(
              pokemon.imagemUrl,
              height: 140,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported_outlined,
                size: 80,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 8),

          // Nome e número
          Text(
            '#${pokemon.id.toString().padLeft(3, '0')} ${pokemon.nome.toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),

          // Tipos
          Wrap(
            spacing: 8,
            children: pokemon.tipos.map((tipo) {
              return Chip(
                label: Text(
                  tipo.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _corPorTipo(tipo),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const Divider(height: 32),

          // Altura e peso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(
                icon: Icons.height_rounded,
                label: 'Altura',
                valor: '${pokemon.alturaMetros.toStringAsFixed(1)} m',
              ),
              _Stat(
                icon: Icons.monitor_weight_outlined,
                label: 'Peso',
                valor: '${pokemon.pesoQuilos.toStringAsFixed(1)} kg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _Stat({required this.icon, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
