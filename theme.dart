import 'package:flutter/material.dart';

class PrismTheme {
  final Color bg;
  final Color bgPanel;
  final Color bgSidebar;
  final Color text;
  final Color textMuted;
  final Color textDim;
  final Color accent;
  final Color accentBlue;
  final Color accentCyan;
  final Color accentGreen;
  final Color accentAmber;
  final Color keyword;
  final Color string;
  final Color comment;
  final Color number;
  final Color func;
  final Color type;
  final Color border;
  final Color borderLight;
  final Color cursor;
  final Color lineHighlight;

  const PrismTheme({
    required this.bg,
    required this.bgPanel,
    required this.bgSidebar,
    required this.text,
    required this.textMuted,
    required this.textDim,
    required this.accent,
    required this.accentBlue,
    required this.accentCyan,
    required this.accentGreen,
    required this.accentAmber,
    required this.keyword,
    required this.string,
    required this.comment,
    required this.number,
    required this.func,
    required this.type,
    required this.border,
    required this.borderLight,
    required this.cursor,
    required this.lineHighlight,
  });

  static const PrismTheme dark = PrismTheme(
    bg: Color(0xFF0F1117),
    bgPanel: Color(0xFF161B22),
    bgSidebar: Color(0xFF13181F),
    text: Color(0xFFE2E8F0),
    textMuted: Color(0xFF6B7280),
    textDim: Color(0xFF374151),
    accent: Color(0xFF7C3AED),
    accentBlue: Color(0xFF1E6FFF),
    accentCyan: Color(0xFF06B6D4),
    accentGreen: Color(0xFF10B981),
    accentAmber: Color(0xFFF59E0B),
    keyword: Color(0xFFA78BFA),
    string: Color(0xFF34D399),
    comment: Color(0xFF4B5563),
    number: Color(0xFFF59E0B),
    func: Color(0xFF60A5FA),
    type: Color(0xFFF472B6),
    border: Color(0xFF1F2937),
    borderLight: Color(0xFF374151),
    cursor: Color(0xFF7C3AED),
    lineHighlight: Color(0xFF1A1F2E),
  );

  static const PrismTheme light = PrismTheme(
    bg: Color(0xFFFAFAF9),
    bgPanel: Color(0xFFF4F3F0),
    bgSidebar: Color(0xFFEEEDEA),
    text: Color(0xFF1C1917),
    textMuted: Color(0xFF78716C),
    textDim: Color(0xFFA8A29E),
    accent: Color(0xFF6D28D9),
    accentBlue: Color(0xFF1D4ED8),
    accentCyan: Color(0xFF0891B2),
    accentGreen: Color(0xFF047857),
    accentAmber: Color(0xFFB45309),
    keyword: Color(0xFF6D28D9),
    string: Color(0xFF047857),
    comment: Color(0xFF9CA3AF),
    number: Color(0xFFB45309),
    func: Color(0xFF1D4ED8),
    type: Color(0xFFBE185D),
    border: Color(0xFFE7E5E4),
    borderLight: Color(0xFFD6D3D1),
    cursor: Color(0xFF7C3AED),
    lineHighlight: Color(0xFFF0EFEC),
  );
}
