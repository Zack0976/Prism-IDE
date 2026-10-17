import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'code_files.dart';
import 'tokenizer.dart';

class CodeEditor extends StatefulWidget {
  final PrismTheme theme;
  final String filename;
  final Function(int line, int col) onCursorChange;

  const CodeEditor({
    super.key,
    required this.theme,
    required this.filename,
    required this.onCursorChange,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor>
    with SingleTickerProviderStateMixin {
  int _cursorLine = 1;
  late AnimationController _cursorBlink;

  @override
  void initState() {
    super.initState();
    _cursorBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorBlink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final code = codeFiles[widget.filename] ?? '// File not found';
    final lines = Tokenizer.tokenize(code, widget.filename);

    return Container(
      color: t.bg,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ...lines.asMap().entries.map((entry) {
                  final lineNum = entry.key + 1;
                  final segments = entry.value;
                  final isActive = lineNum == _cursorLine;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _cursorLine = lineNum);
                      widget.onCursorChange(lineNum, 1);
                    },
                    child: Container(
                      height: 22,
                      color: isActive ? t.lineHighlight : Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Line number
                          SizedBox(
                            width: 46,
                            child: Text(
                              '$lineNum',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: isActive ? t.textMuted : t.textDim,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Code segments
                          ...segments.map((seg) => Text(
                                seg.text,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  color: _tokenColor(seg.type, t),
                                  height: 1.0,
                                ),
                              )),
                          // Cursor
                          if (isActive)
                            AnimatedBuilder(
                              animation: _cursorBlink,
                              builder: (_, __) => Opacity(
                                opacity: _cursorBlink.value,
                                child: Container(
                                  width: 2,
                                  height: 14,
                                  color: t.cursor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _tokenColor(String type, PrismTheme t) {
    switch (type) {
      case 'keyword': return t.keyword;
      case 'string': return t.string;
      case 'comment': return t.comment;
      case 'number': return t.number;
      case 'func': return t.func;
      case 'type': return t.type;
      case 'heading1': return t.func;
      case 'heading2': return t.keyword;
      case 'heading3': return t.type;
      default: return t.text;
    }
  }
}
