import 'package:flutter/material.dart';
import '../services/servico_gemini.dart';
import '../theme/tema_aplicativo.dart';
import '../widgets/caixa_transparente.dart';
import '../widgets/pagina_menu.dart';

class ChatScreen extends StatefulWidget { const ChatScreen({super.key}); @override State<ChatScreen> createState() => _ChatScreenState(); }
class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController(); final _gemini = GeminiService();
  final _messages = <GeminiChatMessage>[const GeminiChatMessage(text: 'Ola! Sou o assistente do SafeNeighbor. Como posso ajudar?', isUser: false)]; bool _sending = false;
  @override void dispose() { _input.dispose(); super.dispose(); }
  Future<void> _send() async {
    final text = _input.text.trim(); if (text.isEmpty || _sending) return;
    setState(() { _messages.add(GeminiChatMessage(text: text, isUser: true)); _input.clear(); _sending = true; });
    try { final answer = await _gemini.sendMessage(_messages); if (mounted) setState(() => _messages.add(GeminiChatMessage(text: answer, isUser: false))); }
    on GeminiException catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message))); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nao foi possivel falar com o Gemini. Tente novamente.'))); }
    finally { if (mounted) setState(() => _sending = false); }
  }
  @override Widget build(BuildContext context) => MenuPage(key: const ValueKey('chat-screen'), icon: Icons.auto_awesome_outlined, title: 'Assistente SafeNeighbor', subtitle: 'Tire duvidas sobre seguranca e convivencia no bairro', child: Column(children: [
    if (!_gemini.isConfigured) const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Configure GEMINI_API_KEY para ativar a IA.', style: TextStyle(color: AppColors.medium, fontSize: 12))),
    Expanded(child: ListView.separated(itemCount: _messages.length + (_sending ? 1 : 0), separatorBuilder: (context, index) => const SizedBox(height: 10), itemBuilder: (context, i) => i == _messages.length ? const Padding(padding: EdgeInsets.all(12), child: Text('Assistente esta digitando...', style: TextStyle(color: AppColors.muted))) : _Bubble(message: _messages[i]))),
    const SizedBox(height: 12), GlassContainer(radius: 18, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Row(children: [Expanded(child: TextField(controller: _input, enabled: !_sending, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Escreva sua mensagem...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)))), IconButton.filled(onPressed: _sending ? null : _send, tooltip: 'Enviar mensagem', icon: _sending ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded))]))
  ]));
}
class _Bubble extends StatelessWidget { const _Bubble({required this.message}); final GeminiChatMessage message; @override Widget build(BuildContext context) => Align(alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(constraints: const BoxConstraints(maxWidth: 520), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: message.isUser ? AppColors.primary : AppColors.glass, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.glassBorder)), child: Text(message.text, style: const TextStyle(height: 1.4)))); }
