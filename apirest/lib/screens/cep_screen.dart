import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/endereco.dart';
import '../services/cep_service.dart';

class CepScreen extends StatefulWidget {
  const CepScreen({super.key});

  @override
  State<CepScreen> createState() => _CepScreenState();
}

class _CepScreenState extends State<CepScreen> {
  final _cepController = TextEditingController();
  final _cepService = CepService();

  bool _carregando = false;
  String? _erro;
  Endereco? _endereco;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');

    // Validação: deve ter exatamente 8 dígitos numéricos
    if (cep.length != 8) {
      setState(() {
        _erro = 'CEP inválido. Digite os 8 dígitos numéricos.';
        _endereco = null;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
      _endereco = null;
    });

    try {
      final endereco = await _cepService.buscar(cep);
      setState(() => _endereco = endereco);
    } catch (e) {
      // Captura ApiTimeoutException, SemConexaoException,
      // ApiErrorException ou erro genérico (CEP não encontrado)
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
        title: const Text('Consulta de CEP'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Campo de CEP ────────────────────────────────────────────
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
                      controller: _cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        hintText: '00000-000',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onSubmitted: (_) => _buscarCep(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _carregando ? null : _buscarCep,
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

            // ── Resultado: campos preenchidos automaticamente ────────────
            if (_endereco != null && !_carregando) _ResultadoEndereco(endereco: _endereco!),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResultadoEndereco extends StatelessWidget {
  final Endereco endereco;
  const _ResultadoEndereco({required this.endereco});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Endereço encontrado',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 24),
          _CampoInfo(label: 'CEP', valor: endereco.cep),
          _CampoInfo(label: 'Logradouro', valor: endereco.logradouro),
          if (endereco.complemento != null && endereco.complemento!.isNotEmpty)
            _CampoInfo(label: 'Complemento', valor: endereco.complemento!),
          _CampoInfo(label: 'Bairro', valor: endereco.bairro),
          _CampoInfo(label: 'Cidade', valor: endereco.localidade),
          _CampoInfo(label: 'UF', valor: endereco.uf),
        ],
      ),
    );
  }
}

class _CampoInfo extends StatelessWidget {
  final String label;
  final String valor;
  const _CampoInfo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor.isEmpty ? '—' : valor,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
