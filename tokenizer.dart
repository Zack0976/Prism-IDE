class TokenSegment {
  final String text;
  final String type;
  const TokenSegment(this.text, this.type);
}

class Tokenizer {
  static List<List<TokenSegment>> tokenize(String code, String filename) {
    final ext = filename.split('.').last;
    if (ext == 'md') return _tokenizeMd(code);
    return _tokenizeTS(code);
  }

  static List<List<TokenSegment>> _tokenizeMd(String code) {
    return code.split('\n').map((line) {
      if (line.startsWith('# ')) return [TokenSegment(line, 'heading1')];
      if (line.startsWith('## ')) return [TokenSegment(line, 'heading2')];
      if (line.startsWith('### ')) return [TokenSegment(line, 'heading3')];
      if (line.startsWith('  ')) return [TokenSegment(line, 'string')];
      if (line.startsWith('-') || line.startsWith('*')) {
        return [TokenSegment(line, 'keyword')];
      }
      return [TokenSegment(line, 'text')];
    }).toList();
  }

  static List<List<TokenSegment>> _tokenizeTS(String code) {
    const keywords = {
      'import', 'export', 'from', 'const', 'let', 'var', 'function',
      'class', 'async', 'await', 'return', 'if', 'else', 'try', 'catch',
      'throw', 'new', 'this', 'typeof', 'instanceof', 'extends',
      'implements', 'interface', 'type', 'enum', 'private', 'public',
      'static', 'readonly', 'void', 'null', 'undefined', 'true', 'false',
      'for', 'of', 'in', 'while', 'do', 'switch', 'case', 'break',
      'continue', 'default',
    };

    return code.split('\n').map((line) {
      final segments = <TokenSegment>[];

      // Full-line comment
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('//')) {
        return [TokenSegment(line, 'comment')];
      }

      // Simple tokenizer: split on word boundaries
      final buf = StringBuffer();
      int i = 0;

      void flush(String type) {
        if (buf.isNotEmpty) {
          segments.add(TokenSegment(buf.toString(), type));
          buf.clear();
        }
      }

      while (i < line.length) {
        final ch = line[i];

        // String literal
        if (ch == '"' || ch == "'" || ch == '`') {
          flush('text');
          final quote = ch;
          final sb = StringBuffer(ch);
          i++;
          while (i < line.length) {
            sb.write(line[i]);
            if (line[i] == quote && (i == 0 || line[i - 1] != '\\')) {
              i++;
              break;
            }
            i++;
          }
          segments.add(TokenSegment(sb.toString(), 'string'));
          continue;
        }

        // Number
        if (_isDigit(ch)) {
          flush('text');
          final sb = StringBuffer();
          while (i < line.length && (_isDigit(line[i]) || line[i] == '.')) {
            sb.write(line[i++]);
          }
          segments.add(TokenSegment(sb.toString(), 'number'));
          continue;
        }

        // Word
        if (_isAlpha(ch)) {
          flush('text');
          final sb = StringBuffer();
          while (i < line.length && _isAlphaNum(line[i])) {
            sb.write(line[i++]);
          }
          final word = sb.toString();
          // Check if next char is '(' => function call
          final isFunc = i < line.length && line[i] == '(';
          // Check if starts with uppercase => type
          final isType = word[0] == word[0].toUpperCase() &&
              word[0] != word[0].toLowerCase();
          if (keywords.contains(word)) {
            segments.add(TokenSegment(word, 'keyword'));
          } else if (isFunc) {
            segments.add(TokenSegment(word, 'func'));
          } else if (isType) {
            segments.add(TokenSegment(word, 'type'));
          } else {
            segments.add(TokenSegment(word, 'text'));
          }
          continue;
        }

        buf.write(ch);
        i++;
      }
      flush('text');
      return segments.isEmpty ? [TokenSegment(line, 'text')] : segments;
    }).toList();
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  static bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        c == '_' || c == r'$';
  }
  static bool _isAlphaNum(String c) => _isAlpha(c) || _isDigit(c);
}
