
import 'package:flutter/material.dart';
import '../services/cptec_service.dart';

class BuscaCidadeScreen extends StatefulWidget {
  const BuscaCidadeScreen({super.key});

  @override
  State<BuscaCidadeScreen> createState() => _BuscaCidadeScreenState();
}

class _BuscaCidadeScreenState extends State<BuscaCidadeScreen> {
  final TextEditingController _controller = TextEditingController();
  final CptecService _service = CptecService();

  List<Cidade> cidades = [];
  bool carregando = false;
  String? erro;

  Future<void> pesquisar() async {
    final texto = _controller.text.trim();

    if (texto.isEmpty) return;

    setState(() {
      carregando = true;
      erro = null;
      cidades = [];
    });

    try {
      final resultado = await _service.buscarCidades(texto);

      if (!mounted) return;

      setState(() {
        cidades = resultado;
        if (resultado.isEmpty) {
          erro = 'Nenhuma cidade encontrada.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = 'Não foi possível consultar as cidades. Verifique sua conexão.';
      });
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar cidade'),
        backgroundColor: const Color(0xFF0B1220),
      ),
      backgroundColor: const Color(0xFF0B1220),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => pesquisar(),
              decoration: InputDecoration(
                hintText: 'Digite o nome da cidade',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: pesquisar,
                ),
                filled: true,
                fillColor: const Color(0xFF172235),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (carregando)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),

            if (erro != null && !carregando)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  erro!,
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ),

            Expanded(
              child: ListView.builder(
                itemCount: cidades.length,
                itemBuilder: (context, index) {
                  final cidade = cidades[index];

                  return Card(
                    color: const Color(0xFF172235),
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_city,
                        color: Colors.lightBlueAccent,
                      ),
                      title: Text(cidade.nome),
                      subtitle: Text(cidade.uf),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context, cidade);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
