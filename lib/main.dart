import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/previsao_dia.dart' as modelo;
import 'services/busca_cidade_screen.dart';
import 'services/previsao_service.dart';
import 'services/cptec_service.dart';

void main() {
  runApp(const PrevisaoTempoApp());
}

class PrevisaoTempoApp extends StatelessWidget {
  const PrevisaoTempoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clima',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DA3FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final PrevisaoService _previsaoService = PrevisaoService();

  String cidade = 'Jacareí';
  String uf = 'SP';
  String? codigoCidade;

  List<modelo.PrevisaoDia> previsoes = [];

  bool carregando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarCidadeSalva();
  }

Future<void> carregarCidadeSalva() async {
  final prefs = await SharedPreferences.getInstance();

  final nomeSalvo = prefs.getString('cidade_nome');
  final ufSalva = prefs.getString('cidade_uf');
  final idSalvo = prefs.getString('cidade_id');

  if (!mounted) return;

  setState(() {
    cidade = nomeSalvo ?? 'Jacareí';
    uf = ufSalva ?? 'SP';
    codigoCidade = idSalvo;
  });

  if (codigoCidade != null && codigoCidade!.isNotEmpty) {
    await carregarPrevisao();
  } else {
    // Caso não exista cidade salva, busca Jacareí
    final resultado = await CptecService().buscarCidades('Jacareí');

    if (resultado.isNotEmpty && mounted) {
      await salvarCidade(resultado.first);
    }
  }
}

  Future<void> salvarCidade(Cidade novaCidade) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('cidade_nome', novaCidade.nome);
    await prefs.setString('cidade_uf', novaCidade.uf);
    await prefs.setString('cidade_id', novaCidade.id);

    if (!mounted) return;

    setState(() {
      cidade = novaCidade.nome;
      uf = novaCidade.uf;
      codigoCidade = novaCidade.id;
      previsoes = [];
      erro = null;
    });

    await carregarPrevisao();
  }

  Future<void> abrirBuscaCidade() async {
    final resultado = await Navigator.push<Cidade>(
      context,
      MaterialPageRoute(
        builder: (context) => const BuscaCidadeScreen(),
      ),
    );

    if (resultado != null) {
      await salvarCidade(resultado);
    }
  }

  Future<void> carregarPrevisao() async {
    if (codigoCidade == null || codigoCidade!.isEmpty) return;

    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resultado =
          await _previsaoService.buscarPrevisao(codigoCidade!);

      if (!mounted) return;

      setState(() {
        previsoes = resultado;
        carregando = false;

        if (resultado.isEmpty) {
          erro = 'Nenhuma previsão encontrada para esta cidade.';
        }
      });
    } catch (e, stackTrace) {
      debugPrint('ERRO AO BUSCAR PREVISÃO: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = 'Erro: $e';
      });
    }
  }

  String descricaoTempo(String codigo) {
    const descricoes = {
      'ec': 'Encoberto',
      'ci': 'Cirrus',
      'c': 'Chuva',
      'in': 'Instável',
      'pp': 'Possibilidade de chuva',
      'cm': 'Chuva e trovoadas',
      'cn': 'Chuva e nebulosidade',
      'pc': 'Parcialmente nublado',
      'pn': 'Parcialmente nublado',
      'cv': 'Chuvas isoladas',
      'ch': 'Chuvoso',
      'cl': 'Claro',
      'nv': 'Nevoeiro',
      'n': 'Nublado',
      'nd': 'Nublado',
      'pl': 'Precipitação',
      'e': 'Extremo',
      'g': 'Geada',
      'ne': 'Neve',
      'nu': 'Nublado',
      'ns': 'Nublado',
      'nm': 'Nublado',
      'nt': 'Instável',
    };

    return descricoes[codigo.toLowerCase()] ?? 'Condição meteorológica';
  }

  IconData iconeTempo(String codigo) {
    final c = codigo.toLowerCase();

    if (['cl', 'ci'].contains(c)) {
      return Icons.wb_sunny;
    }

    if (['c', 'ch', 'cv', 'cm', 'pp', 'pl'].contains(c)) {
      return Icons.umbrella;
    }

    if (['e', 'in', 'nt'].contains(c)) {
      return Icons.thunderstorm;
    }

    if (['nv', 'ne', 'g'].contains(c)) {
      return Icons.ac_unit;
    }

    if (['pc', 'pn'].contains(c)) {
      return Icons.cloud_queue;
    }

    return Icons.cloud;
  }

  String formatarDia(String data) {
    try {
      final parsed = DateTime.parse(data);
      const dias = [
        'Segunda-feira',
        'Terça-feira',
        'Quarta-feira',
        'Quinta-feira',
        'Sexta-feira',
        'Sábado',
        'Domingo',
      ];

      return dias[parsed.weekday - 1];
    } catch (_) {
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primeiraPrevisao =
        previsoes.isNotEmpty ? previsoes.first : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PREVISÃO DO TEMPO',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 2,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap: abrirBuscaCidade,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$cidade, $uf',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: carregarPrevisao,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar previsão',
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: _buildConteudoPrevisao(primeiraPrevisao),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConteudoPrevisao(modelo.PrevisaoDia? dia) {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 60,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              erro!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: carregarPrevisao,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (dia == null) {
      return const Center(
        child: Text(
          'Selecione uma cidade para consultar a previsão.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final dias = previsoes.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Icon(
                iconeTempo(dia.tempo),
                size: 100,
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(height: 10),
              Text(
                '${dia.maxima}°',
                style: const TextStyle(
                  fontSize: 82,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Text(
                'Máxima prevista',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                descricaoTempo(dia.tempo),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Máx. ${dia.maxima}°  •  Mín. ${dia.minima}°',
                style: const TextStyle(color: Colors.white54),
              ),
              if (dia.iuv > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Índice UV: ${dia.iuv}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 35),
        const Text(
          'PRÓXIMOS DIAS',
          style: TextStyle(
            letterSpacing: 1.5,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: dias.length,
            itemBuilder: (context, index) {
              final previsao = dias[index];

              return CardPrevisaoDia(
                dia: formatarDia(previsao.data),
                icone: iconeTempo(previsao.tempo),
                descricao: descricaoTempo(previsao.tempo),
                minima: '${previsao.minima}°',
                maxima: '${previsao.maxima}°',
              );
            },
          ),
        ),
      ],
    );
  }
}

class CardPrevisaoDia extends StatelessWidget {
  final String dia;
  final IconData icone;
  final String descricao;
  final String minima;
  final String maxima;

  const CardPrevisaoDia({
    super.key,
    required this.dia,
    required this.icone,
    required this.descricao,
    required this.minima,
    required this.maxima,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF172235),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dia,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              icone,
              color: Colors.lightBlueAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 115,
              child: Text(
                descricao,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ),
            Text(
              minima,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(width: 10),
            Text(
              maxima,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}