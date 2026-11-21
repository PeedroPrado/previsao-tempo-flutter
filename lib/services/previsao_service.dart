
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/previsao_dia.dart';

class PrevisaoService {
  static const String baseUrl = 'http://localhost:3001/api';

  Future<List<PrevisaoDia>> buscarPrevisao(String idCidade) async {
    final uri = Uri.parse('$baseUrl/previsao').replace(
      queryParameters: {'id': idCidade},
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar previsão meteorológica.');
    }

    final documento = XmlDocument.parse(
      utf8.decode(response.bodyBytes),
    );

    return documento
        .findAllElements('previsao')
        .map((elemento) => PrevisaoDia.fromXml(elemento))
        .toList();
  }
}
