import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class TerminalPanel extends StatefulWidget {
  final PrismTheme theme;
  final VoidCallback onClose;

  const TerminalPanel({super.key, required this.theme, required this.onClose});

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_TermLine> _lines = [
    _TermLine('prism-term v1.0 — GPU Accelerated', _LineType.system),
    _TermLine(r'$ npm run dev', _LineType.command),
    _TermLine('  ▸ Compiling TypeScript...', _LineType.info),
    _TermLine('  ✅ Build successful in 312ms', _LineType.success),
    _TermLine('  🚀 Server running on port 3000', _LineType.success),
  ];

  void _submit(String input) {
    final cmd = input.trim();
    if (cmd.isEmpty) return;
    setState(() {
      _lines.add(_TermLine('\\$ $cmd', _LineType.command));
      if (cmd == 'clear') {
        _lines.clear();
      } else if (cmd == 'help') {
        _lines.add(_TermLine('  Comandos: clear, help, npm run dev', _LineType.info));
      } else if (cmd.startsWith('npm')) {
        _lines.add(_TermLine('  ▸ Executando...', _LineType.info));
        _lines.add(_TermLine('  ✅ Concluído', _LineType.success));
      } else {
        _lines.add(_TermLine('  bash: $cmd: command not found', _LineType.error));
      }
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 50), () {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C10),
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: t.bgPanel,
            child: Row(
              children: [
                Text('⬡ PRISM TERMINAL',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: t.textMuted,
                        letterSpacing: 1)),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Text('✕',
                      style: TextStyle(color: t.textMuted, fontSize: 12)),
                ),
              ],
            ),
          ),
          // Output
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              itemCount: _lines.length,
              itemBuilder: (_, i) {
                final line = _lines[i];
                return Text(
                  line.text,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: _lineColor(line.type, t),
                    height: 1.6,
                  ),
                );
              },
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Text(r'$ ',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 12, color: t.accentGreen)),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _submit,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 12, color: t.accentGreen),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Digite um comando...',
                      hintStyle: GoogleFonts.jetBrainsMono(
                          fontSize: 12, color: t.textDim),
                    ),
                    cursorColor: t.accentGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _lineColor(_LineType type, PrismTheme t) {
    switch (type) {
      case _LineType.command: return t.accentGreen;
      case _LineType.success: return t.accentGreen;
      case _LineType.error: return const Color(0xFFF87171);
      case _LineType.info: return t.accentAmber;
      case _LineType.system: return t.accentCyan;
    }
  }
}

enum _LineType { command, success, error, info, system }

class _TermLine {
  final String text;
  final _LineType type;
  _TermLine(this.text, this.type);
}
