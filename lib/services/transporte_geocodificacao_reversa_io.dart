// Faz a consulta de endereco fora do navegador.
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchReverseGeocoding(
  Uri uri, {
  required Duration timeout,
}) async {
  final response = await http.get(
    uri,
    headers: const {
      'Accept': 'application/json',
      'User-Agent': 'SafeNeighbor/1.0 (community-safety-app)',
    },
  ).timeout(timeout);

  if (response.statusCode != 200) {
    throw StateError('Geocoding HTTP ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Resposta de geocodificação inválida.');
  }
  return decoded;
}
