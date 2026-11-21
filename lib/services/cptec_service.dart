
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class Cidade {
  final String nome;
  final String uf;
  final String id;

  Cidade({
    required this.nome,
    required this.uf,
    required this.id,
  });

  @override
  String toString() => '$nome - $uf';
}

class CptecService {
  static const String baseUrl = 'http://localhost:3001/api';

  Future<List<Cidade>> buscarCidades(String nome) async {
    if (nome.trim().isEmpty) return [];

    final uri = Uri.parse('$baseUrl/cidades').replace(
      queryParameters: {'city': nome.trim()},
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar cidades.');
    }

    final document = XmlDocument.parse(
      utf8.decode(response.bodyBytes),
    );

    return document.findAllElements('cidade').map((element) {
      return Cidade(
        nome: element.getElement('nome')?.innerText ?? '',
        uf: element.getElement('uf')?.innerText ?? '',
        id: element.getElement('id')?.innerText ?? '',
      );
    }).where((cidade) => cidade.id.isNotEmpty).toList();
  }
}
