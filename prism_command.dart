import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class CommandItem {
  final String icon;
  final String label;
  final String shortcut;
  final VoidCallback? action;

  const CommandItem({
    required this.icon,
    required this.label,
    required this.shortcut,
    this.action,
  });
}

class PrismCommand extends StatefulWidget {
  final PrismTheme theme;
  final VoidCallback onClose;
  final VoidCallback onToggleZen;
  final VoidCallback onToggleTerminal;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleAI;

  const PrismCommand({
    super.key,
    required this.theme,
    required this.onClose,
    required this.onToggleZen,
    required this.onToggleTerminal,
    required this.onToggleTheme,
    required this.onToggleAI,
  });

  @override
  State<PrismCommand> createState() => _PrismCommandState();
}

class _PrismCommandState extends State<PrismCommand>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late AnimationController _anim;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  List<CommandItem> get _commands => [
        CommandItem(icon: '⚡', label: 'Formatar Documento', shortcut: '⇧⌥F'),
        CommandItem(
            icon: '✦',
            label: 'Prism AI: Chat',
            shortcut: '⌘I',
            action: widget.onToggleAI),
        CommandItem(
            icon: '◎',
            label: 'Modo Zen',
            shortcut: '⌃⇧Z',
            action: widget.onToggleZen),
        CommandItem(icon: '⬡', label: 'Novo Arquivo', shortcut: '⌘N'),
        CommandItem(icon: '◎', label: 'Busca no Projeto', shortcut: '⌘⇧F'),
        CommandItem(
            icon: '⟳',
            label: 'Toggle Terminal',
            shortcut: '⌃`',
            action: widget.onToggleTerminal),
        CommandItem(
            icon: '◑',
            label: 'Alternar Tema',
            shortcut: '⌘K T',
            action: widget.onToggleTheme),
        CommandItem(icon: '↗', label: 'Hologram Mode', shortcut: '⌘⇧H'),
        CommandItem(icon: '⊞', label: 'Gerenciar Plugins', shortcut: '⌘⇧X'),
      ];

  List<CommandItem> get _filtered {
    final q = _controller.text.toLowerCase();
    if (q.isEmpty) return _commands;
    return _commands.where((c) => c.label.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scaleAnim =
        Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOut,
    ));
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_anim);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.black26, BlendMode.darken),
          child: Center(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, child) => Opacity(
                opacity: _opacityAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                ),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 500,
                  constraints: const BoxConstraints(maxHeight: 420),
                  decoration: BoxDecoration(
                    color: t.bgPanel,
                    border: Border.all(color: t.borderLight),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: t.accent.withOpacity(0.15),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 60,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search input
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: t.border)),
                        ),
                        child: Row(
                          children: [
                            Text('◈ ',
                                style:
                                    TextStyle(color: t.accent, fontSize: 16)),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                onChanged: (_) => setState(() {}),
                                style: GoogleFonts.jetBrainsMono(
                                  color: t.text,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Buscar comandos, arquivos, símbolos...',
                                  hintStyle: GoogleFonts.jetBrainsMono(
                                    color: t.textMuted,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                cursorColor: t.accent,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: t.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('ESC',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: t.textMuted,
                                  )),
                            ),
                          ],
                        ),
                      ),

                      // Results
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final cmd = _filtered[i];
                            return _CommandRow(
                              item: cmd,
                              theme: t,
                              onTap: () {
                                cmd.action?.call();
                                if (cmd.action == null) widget.onClose();
                              },
                            );
                          },
                        ),
                      ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border:
                              Border(top: BorderSide(color: t.border)),
                        ),
                        child: Row(
                          children: [
                            _hint('↑↓', 'navegar', t),
                            const SizedBox(width: 16),
                            _hint('↵', 'executar', t),
                            const SizedBox(width: 16),
                            _hint('ESC', 'fechar', t),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hint(String key, String label, PrismTheme t) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: t.border,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(key,
              style:
                  GoogleFonts.jetBrainsMono(fontSize: 9, color: t.textMuted)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 10, color: t.textDim)),
      ],
    );
  }
}

class _CommandRow extends StatefulWidget {
  final CommandItem item;
  final PrismTheme theme;
  final VoidCallback onTap;

  const _CommandRow(
      {required this.item, required this.theme, required this.onTap});

  @override
  State<_CommandRow> createState() => _CommandRowState();
}

class _CommandRowState extends State<_CommandRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _hover ? t.border : Colors.transparent,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(widget.item.icon,
                    style: TextStyle(color: t.accent, fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.item.label,
                    style: GoogleFonts.jetBrainsMono(
                        color: t.text, fontSize: 13)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: t.border,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(widget.item.shortcut,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10, color: t.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
