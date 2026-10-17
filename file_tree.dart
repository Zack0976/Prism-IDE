import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class FileTreeItem {
  final String name;
  final String? key;
  final String icon;
  final int depth;
  final bool isFolder;

  const FileTreeItem({
    required this.name,
    this.key,
    required this.icon,
    required this.depth,
    this.isFolder = false,
  });
}

const _files = [
  FileTreeItem(name: 'main.ts', key: 'main.ts', icon: '⬡', depth: 0),
  FileTreeItem(name: 'auth', icon: '▸', depth: 0, isFolder: true),
  FileTreeItem(name: 'service.ts', key: 'auth/service.ts', icon: '⬡', depth: 1),
  FileTreeItem(name: 'db', icon: '▸', depth: 0, isFolder: true),
  FileTreeItem(name: 'connection.ts', key: 'db/connection.ts', icon: '⬡', depth: 1),
  FileTreeItem(name: 'README.md', key: 'README.md', icon: '◈', depth: 0),
];

class FileTree extends StatelessWidget {
  final PrismTheme theme;
  final String activeFile;
  final Function(String) onFileOpen;
  final VoidCallback onAIToggle;
  final bool aiOpen;

  const FileTree({
    super.key,
    required this.theme,
    required this.activeFile,
    required this.onFileOpen,
    required this.onAIToggle,
    required this.aiOpen,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      color: t.bgSidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Text(
              'EXPLORER',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: t.textMuted,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: _files.map((item) {
                final isActive = item.key == activeFile;
                return GestureDetector(
                  onTap: () {
                    if (item.key != null) onFileOpen(item.key!);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        14.0 + item.depth * 14, 6, 14, 6),
                    color: isActive ? t.border : Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          item.icon + ' ',
                          style: TextStyle(
                            color: item.isFolder ? t.accentAmber : t.accentCyan,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          item.name,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: isActive ? t.text : t.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // AI button
          Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: onAIToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: aiOpen ? t.accent : Colors.transparent,
                  border: Border.all(color: aiOpen ? t.accent : t.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✦ ',
                        style: TextStyle(
                            color: aiOpen ? Colors.white : t.textMuted,
                            fontSize: 12)),
                    Text('Prism AI',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: aiOpen ? Colors.white : t.textMuted,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
