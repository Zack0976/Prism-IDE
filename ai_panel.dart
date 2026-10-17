import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'code_files.dart';

class AIMessage {
  final String role;
  final String text;
  AIMessage(this.role, this.text);
}

class AIPanel extends StatefulWidget {
  final PrismTheme theme;
  final String activeFile;
  final List<String> openTabs;
  final VoidCallback onClose;

  const AIPanel({
    super.key,
    required this.theme,
    required this.activeFile,
    required this.openTabs,
    required this.onClose,
  });

  @override
  State<AIPanel> createState() => _AIPanelState();
}

class _AIPanelState extends State<AIPanel> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _loading = false;

  final List<AIMessage> _messages = [
    AIMessage('assistant',
        'Olá! Sou o Prism AI. Tenho contexto completo do seu projeto. Como posso ajudar?'),
  ];

  Future<void> _send() async {
    final input = _controller.text.trim();
    if (input.isEmpty || _loading) return;

    setState(() {
      _messages.add(AIMessage('user', input));
      _loading = true;
    });
    _controller.clear();
    _scrollDown();

    try {
      final code = codeFiles[widget.activeFile] ?? '';
      final systemPrompt =
          'Você é o Prism AI, assistente nativo de um editor de código chamado Prism IDE. '
          'Arquivo ativo: ${widget.activeFile}. '
          'Arquivos abertos: ${widget.openTabs.join(", ")}. '
          'Código atual (trecho):\n${code.substring(0, code.length.clamp(0, 600))}...\n\n'
          'Responda de forma concisa e técnica, como um assistente de IDE especializado. '
          'Use português brasileiro.';

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'system': systemPrompt,
          'messages': [
            {'role': 'user', 'content': input}
          ],
        }),
      );

      final data = jsonDecode(response.body);
      final reply = data['content']?[0]?['text'] ?? 'Erro ao obter resposta.';
      setState(() => _messages.add(AIMessage('assistant', reply)));
    } catch (e) {
      setState(() => _messages
          .add(AIMessage('assistant', 'Erro de conexão com o Prism AI Cloud.')));
    } finally {
      setState(() => _loading = false);
      _scrollDown();
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: t.bgPanel,
        border: Border(left: BorderSide(color: t.border)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: t.border)),
            ),
            child: Row(
              children: [
                Text('✦ ', style: TextStyle(color: t.accent, fontSize: 16)),
                Text('Prism AI',
                    style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.text)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: t.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('NATIVE',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 8,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Text('✕',
                      style: TextStyle(color: t.textMuted, fontSize: 14)),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('✦ analisando contexto...',
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 11, color: t.textMuted)),
                  );
                }
                final msg = _messages[i];
                final isUser = msg.role == 'user';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUser ? t.border : Colors.transparent,
                    border: isUser
                        ? null
                        : Border.all(color: t.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUser ? 'VOCÊ' : '✦ PRISM AI',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isUser ? t.accentCyan : t.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(msg.text,
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: t.text,
                              height: 1.5)),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.border)),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: t.bg,
                    border: Border.all(color: t.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _send(),
                          maxLines: null,
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 12, color: t.text),
                          decoration: InputDecoration(
                            hintText: 'Pergunte sobre o projeto...',
                            hintStyle: GoogleFonts.jetBrainsMono(
                                fontSize: 11, color: t.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          cursorColor: t.accent,
                        ),
                      ),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: t.accent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text('↑',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Contexto: ${widget.activeFile} + ${widget.openTabs.length} arquivos',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 9, color: t.textDim),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
