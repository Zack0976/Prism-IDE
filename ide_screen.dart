import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'file_tree.dart';
import 'code_editor.dart';
import 'prism_command.dart';
import 'terminal_panel.dart';
import 'ai_panel.dart';

class IdeScreen extends StatefulWidget {
  const IdeScreen({super.key});

  @override
  State<IdeScreen> createState() => _IdeScreenState();
}

class _IdeScreenState extends State<IdeScreen> with TickerProviderStateMixin {
  bool _isDark = true;
  bool _sidebarOpen = true;
  bool _terminalOpen = false;
  bool _aiOpen = false;
  bool _zenMode = false;
  bool _commandOpen = false;

  String _activeFile = 'main.ts';
  List<String> _openTabs = ['main.ts'];
  int _cursorLine = 1;
  int _cursorCol = 1;

  late AnimationController _sidebarAnim;
  late AnimationController _terminalAnim;
  late AnimationController _aiAnim;

  PrismTheme get theme => _isDark ? PrismTheme.dark : PrismTheme.light;

  @override
  void initState() {
    super.initState();
    _sidebarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _terminalAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _aiAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _sidebarAnim.dispose();
    _terminalAnim.dispose();
    _aiAnim.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _sidebarOpen = !_sidebarOpen);
    if (_sidebarOpen) _sidebarAnim.forward(); else _sidebarAnim.reverse();
  }

  void _toggleTerminal() {
    setState(() => _terminalOpen = !_terminalOpen);
    if (_terminalOpen) _terminalAnim.forward(); else _terminalAnim.reverse();
  }

  void _toggleAI() {
    setState(() => _aiOpen = !_aiOpen);
    if (_aiOpen) _aiAnim.forward(); else _aiAnim.reverse();
  }

  void _openFile(String key) {
    setState(() {
      _activeFile = key;
      if (!_openTabs.contains(key)) _openTabs.add(key);
    });
  }

  void _closeTab(String key) {
    setState(() {
      _openTabs.remove(key);
      if (_activeFile == key && _openTabs.isNotEmpty) {
        _activeFile = _openTabs.last;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Scaffold(
      backgroundColor: t.bg,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (e) {
          if (e is KeyDownEvent) {
            if (e.logicalKey == LogicalKeyboardKey.escape) {
              setState(() { _commandOpen = false; _zenMode = false; });
            }
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                // Title bar
                if (!_zenMode) _buildTitleBar(t),
                // Tabs
                if (!_zenMode) _buildTabs(t),
                // Main
                Expanded(
                  child: Row(
                    children: [
                      // Sidebar
                      if (!_zenMode)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _sidebarOpen ? 200 : 0,
                          child: _sidebarOpen
                              ? FileTree(
                                  theme: t,
                                  activeFile: _activeFile,
                                  onFileOpen: _openFile,
                                  onAIToggle: _toggleAI,
                                  aiOpen: _aiOpen,
                                )
                              : null,
                        ),
                      // Editor area
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: CodeEditor(
                                theme: t,
                                filename: _activeFile,
                                onCursorChange: (l, c) => setState(() {
                                  _cursorLine = l;
                                  _cursorCol = c;
                                }),
                              ),
                            ),
                            // Terminal
                            AnimatedBuilder(
                              animation: _terminalAnim,
                              builder: (_, child) => SizeTransition(
                                sizeFactor: _terminalAnim,
                                axisAlignment: 1,
                                child: child,
                              ),
                              child: TerminalPanel(
                                theme: t,
                                onClose: _toggleTerminal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // AI Panel
                      AnimatedBuilder(
                        animation: _aiAnim,
                        builder: (_, child) => SizeTransition(
                          sizeFactor: _aiAnim,
                          axis: Axis.horizontal,
                          axisAlignment: 1,
                          child: child,
                        ),
                        child: AIPanel(
                          theme: t,
                          activeFile: _activeFile,
                          openTabs: _openTabs,
                          onClose: _toggleAI,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status bar
                if (!_zenMode) _buildStatusBar(t),
              ],
            ),

            // Sidebar toggle button
            if (!_zenMode)
              Positioned(
                left: _sidebarOpen ? 196 : 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleSidebar,
                    child: Container(
                      width: 16,
                      height: 40,
                      decoration: BoxDecoration(
                        color: t.bgPanel,
                        border: Border.all(color: t.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          _sidebarOpen ? '‹' : '›',
                          style: TextStyle(color: t.textMuted, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Command modal
            if (_commandOpen)
              PrismCommand(
                theme: t,
                onClose: () => setState(() => _commandOpen = false),
                onToggleZen: () => setState(() {
                  _zenMode = !_zenMode;
                  _commandOpen = false;
                }),
                onToggleTerminal: () {
                  _toggleTerminal();
                  setState(() => _commandOpen = false);
                },
                onToggleTheme: () => setState(() {
                  _isDark = !_isDark;
                  _commandOpen = false;
                }),
                onToggleAI: () {
                  _toggleAI();
                  setState(() => _commandOpen = false);
                },
              ),

            // Zen mode hint
            if (_zenMode)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.15),
                      border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Modo Zen ativo · ESC para sair',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(PrismTheme t) {
    return Container(
      height: 36,
      color: t.bgPanel,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text('◈', style: TextStyle(color: t.accent, fontSize: 16)),
          const SizedBox(width: 6),
          Text('PRISM IDE',
              style: GoogleFonts.syne(
                  color: t.accent, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(width: 20),
          ...['Arquivo', 'Editar', 'Ver', 'Terminal'].map((m) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(m,
                    style: GoogleFonts.jetBrainsMono(
                        color: t.textMuted, fontSize: 11)),
              )),
          const Spacer(),
          // Command button
          _titleBtn('⌘P  Prism Command', t, () => setState(() => _commandOpen = true)),
          const SizedBox(width: 6),
          _titleBtn(_isDark ? '◑ Light' : '◑ Dark', t,
              () => setState(() => _isDark = !_isDark)),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _titleBtn(String label, PrismTheme t, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: GoogleFonts.jetBrainsMono(color: t.textMuted, fontSize: 10)),
      ),
    );
  }

  Widget _buildTabs(PrismTheme t) {
    return Container(
      height: 32,
      color: t.bgPanel,
      child: Row(
        children: [
          if (_sidebarOpen) SizedBox(width: 200),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _openTabs.map((tab) {
                final active = tab == _activeFile;
                return GestureDetector(
                  onTap: () => setState(() => _activeFile = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: active ? t.bg : Colors.transparent,
                      border: Border(
                        top: BorderSide(
                          color: active ? t.accent : Colors.transparent,
                          width: 2,
                        ),
                        right: BorderSide(color: t.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('⬡ ',
                            style: TextStyle(color: t.accentCyan, fontSize: 9)),
                        Text(tab.split('/').last,
                            style: GoogleFonts.jetBrainsMono(
                              color: active ? t.text : t.textMuted,
                              fontSize: 11,
                            )),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _closeTab(tab),
                          child: Text('✕',
                              style: TextStyle(
                                  color: t.textMuted, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(PrismTheme t) {
    return Container(
      height: 22,
      color: t.accent,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text('◈ main',
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 16),
          Text('✓ 0 erros',
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _toggleTerminal,
            child: Text('⬡ Terminal',
                style: GoogleFonts.jetBrainsMono(
                    color: Colors.white70, fontSize: 10)),
          ),
          const Spacer(),
          Text('Ln $_cursorLine, Col $_cursorCol',
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 16),
          Text('TypeScript',
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 16),
          Text(_isDark ? 'Prism Dark' : 'Prism Light',
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
