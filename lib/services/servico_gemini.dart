import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  GeminiService({http.Client? client}) : _client = client ?? http.Client();
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  final http.Client _client;
  bool get isConfigured => _apiKey.isNotEmpty;
  Future<String> sendMessage(List<GeminiChatMessage> messages) async {
    if (!isConfigured) throw const GeminiException('Configure GEMINI_API_KEY ao iniciar o app.');
    final response = await _client.post(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent'), headers: {'Content-Type': 'application/json', 'x-goog-api-key': _apiKey}, body: jsonEncode({'systemInstruction': {'parts': [{'text': 'Voce e o assistente do SafeNeighbor. Responda em portugues do Brasil, de modo claro e acolhedor. Em risco imediato, oriente a acionar os servicos de emergencia locais.'}]}, 'contents': messages.map((m) => {'role': m.isUser ? 'user' : 'model', 'parts': [{'text': m.text}]}).toList()})).timeout(const Duration(seconds: 30));
    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) throw GeminiException((body['error'] is Map ? body['error']['message'] : null) as String? ?? 'Erro na API Gemini (${response.statusCode}).');
    final candidates = body['candidates'];
    final parts = candidates is List && candidates.isNotEmpty && candidates.first['content'] is Map ? candidates.first['content']['parts'] : null;
    final text = parts is List ? parts.whereType<Map>().map((p) => p['text']).whereType<String>().join().trim() : '';
    if (text.isEmpty) throw const GeminiException('O Gemini nao retornou uma resposta.');
    return text;
  }
  Map<String, dynamic> _decode(String source) { try { final v = jsonDecode(source); return v is Map<String, dynamic> ? v : {}; } on FormatException { return {}; } }
}
class GeminiChatMessage { const GeminiChatMessage({required this.text, required this.isUser}); final String text; final bool isUser; }
class GeminiException implements Exception { const GeminiException(this.message); final String message; @override String toString() => message; }
