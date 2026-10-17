# ◈ PRISM IDE — Flutter Mobile

Editor de código minimalista e rápido para Android.
Tela de carregamento animada · Modo landscape · Prism AI integrado.

---

## Pré-requisitos

1. Instale o **Flutter SDK**: https://docs.flutter.dev/get-started/install
2. Instale o **Android Studio**: https://developer.android.com/studio
3. Aceite as licenças:
   ```
   flutter doctor --android-licenses
   ```
4. Verifique se tudo está ok:
   ```
   flutter doctor
   ```

---

## Como compilar e instalar

### Opção A — Gerar APK para instalar no celular

```bash
# Entrar na pasta do projeto
cd prism_ide

# Baixar dependências
flutter pub get

# Gerar APK de release
flutter build apk --release

# O APK estará em:
# build/app/outputs/flutter-apk/app-release.apk
```

Transfira o APK para o celular e instale.
(Ative "Instalar de fontes desconhecidas" nas configurações do Android)

---

### Opção B — Rodar direto no celular via USB

```bash
# Conecte o celular com depuração USB ativa
flutter devices        # verifica se o celular aparece
flutter run --release  # instala e abre direto no celular
```

---

### Opção C — Rodar no emulador Android

1. Abra o Android Studio
2. Vá em Device Manager → crie um emulador
3. Execute:
   ```bash
   flutter run
   ```

---

## Estrutura do Projeto

```
prism_ide/
  lib/
    main.dart           # Entry point + lock landscape
    splash_screen.dart  # Tela de carregamento animada
    ide_screen.dart     # Tela principal do editor
    theme.dart          # Temas Prism Dark e Light
    code_editor.dart    # Editor com syntax highlighting
    code_files.dart     # Arquivos de exemplo
    tokenizer.dart      # Colorização de sintaxe
    file_tree.dart      # Sidebar com arquivos
    prism_command.dart  # Modal de comandos (⌘P)
    terminal_panel.dart # Terminal embutido
    ai_panel.dart       # Prism AI (Claude integrado)
  android/
    app/src/main/
      AndroidManifest.xml  # Landscape + permissões
  pubspec.yaml             # Dependências Flutter
```

---

## Funcionalidades

- ✅ Tela de carregamento animada com logo e barra de progresso
- ✅ Modo landscape bloqueado
- ✅ Tema Prism Dark e Prism Light
- ✅ Syntax highlighting (TypeScript, Markdown)
- ✅ Explorador de arquivos com abas
- ✅ Prism Command (modal de busca de comandos)
- ✅ Modo Zen imersivo
- ✅ Terminal embutido interativo
- ✅ Prism AI com contexto do projeto (Claude API)

---

## Licença

Apache 2.0
