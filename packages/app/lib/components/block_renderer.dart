import 'package:flutter/material.dart' hide Card;
import 'package:domain/domain.dart';
import '../theme/tokens.dart';

// ─── Card-kind-aware lesson card layout ──────────────────────────────────────

/// Top-level widget that routes a [Card] to the appropriate rich layout
/// based on its [CardKind]. Wraps each layout in the calm card shell.
class LessonCardLayout extends StatelessWidget {
  final Card card;
  final int cardIndex;
  final int totalCards;

  const LessonCardLayout({
    super.key,
    required this.card,
    required this.cardIndex,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return switch (card.kind) {
      CardKind.intro   => _IntroCard(card: card, t: t),
      CardKind.concept => _ConceptCard(card: card, t: t),
      CardKind.example => _ExampleCard(card: card, t: t),
      CardKind.recap   => _RecapCard(card: card, t: t),
    };
  }
}

// ─── Shared card scaffold ─────────────────────────────────────────────────────

/// A coloured-fill lesson card with a white pill label and content area.
class _BentoCard extends StatelessWidget {
  final Card card;
  final AppTokens t;
  final Color fillColor;
  final String label;
  final bool darkFill; // true = ink card (intro), text should be white

  const _BentoCard({
    required this.card,
    required this.t,
    required this.fillColor,
    required this.label,
    this.darkFill = false,
  });

  @override
  Widget build(BuildContext context) {
    final onFill = darkFill ? Colors.white : t.ink;
    final onFillSoft = darkFill ? Colors.white70 : t.ink.withOpacity(0.65);

    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: pill + arrow ─────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: darkFill
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: darkFill ? Colors.white : t.ink,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.north_east_rounded, size: 18,
                  color: darkFill ? Colors.white38 : t.ink.withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Content blocks ────────────────────────────────────────────
          ...card.blocks.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _BentoBlock(
                  block: b,
                  t: t,
                  onFill: onFill,
                  onFillSoft: onFillSoft,
                  darkFill: darkFill,
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Intro card (ink / dark fill) ────────────────────────────────────────────

class _IntroCard extends StatelessWidget {
  final Card card;
  final AppTokens t;
  const _IntroCard({required this.card, required this.t});

  @override
  Widget build(BuildContext context) => _BentoCard(
        card: card, t: t,
        fillColor: t.ink,
        label: 'LESSON',
        darkFill: true,
      );
}

// ─── Concept card (sage fill) ─────────────────────────────────────────────────

class _ConceptCard extends StatelessWidget {
  final Card card;
  final AppTokens t;
  const _ConceptCard({required this.card, required this.t});

  @override
  Widget build(BuildContext context) => _BentoCard(
        card: card, t: t,
        fillColor: t.sage,
        label: 'CONCEPT',
      );
}

// ─── Example card (amber fill) ───────────────────────────────────────────────

class _ExampleCard extends StatelessWidget {
  final Card card;
  final AppTokens t;
  const _ExampleCard({required this.card, required this.t});

  @override
  Widget build(BuildContext context) => _BentoCard(
        card: card, t: t,
        fillColor: t.amber,
        label: 'WORKED EXAMPLE',
      );
}

// ─── Recap card (sky fill) ────────────────────────────────────────────────────

class _RecapCard extends StatelessWidget {
  final Card card;
  final AppTokens t;
  const _RecapCard({required this.card, required this.t});

  @override
  Widget build(BuildContext context) => _BentoCard(
        card: card, t: t,
        fillColor: t.sky,
        label: 'RECAP',
      );
}

/// Block renderer aware of its card fill context.
/// Overrides formula rendering to use the dark inset style.
class _BentoBlock extends StatelessWidget {
  final ContentBlock block;
  final AppTokens t;
  final Color onFill;
  final Color onFillSoft;
  final bool darkFill;

  const _BentoBlock({
    required this.block,
    required this.t,
    required this.onFill,
    required this.onFillSoft,
    required this.darkFill,
  });

  @override
  Widget build(BuildContext context) {
    if (block is FormulaBlock) {
      // Dark inset formula box — always ink bg regardless of card fill
      return _DarkFormulaBox(block: block as FormulaBlock, t: t);
    }
    if (block is TextBlock) {
      return _BentoText(md: (block as TextBlock).md.resolve('en'), onFill: onFill, onFillSoft: onFillSoft, t: t);
    }
    // Charts and media delegate to the standard renderer
    return ContentBlockRenderer(block: block);
  }
}

// ─── Dark formula inset box ───────────────────────────────────────────────────

/// Renders a formula inside a dark ink inset box (always #1A1A1A bg).
/// Variables in sage, numbers in white, operators in white70.
class _DarkFormulaBox extends StatelessWidget {
  final FormulaBlock block;
  final AppTokens t;
  const _DarkFormulaBox({required this.block, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: t.ink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: _formulaSpans(block.latex, t),
    );
  }

  Widget _formulaSpans(String latex, AppTokens t) {
    // Tokenise the latex string into variable / number / operator spans
    final spans = <InlineSpan>[];
    final reg = RegExp(r'([A-Za-z_][A-Za-z0-9_]*)|([0-9]+\.?[0-9]*%?)|([^\w\s])|([\s]+)');
    for (final m in reg.allMatches(latex)) {
      final varr = m.group(1);
      final num = m.group(2);
      final op = m.group(3);
      final sp = m.group(4);
      if (varr != null) {
        spans.add(TextSpan(
          text: varr,
          style: TextStyle(color: t.sage, fontWeight: FontWeight.w700, fontFamily: 'Inter', fontSize: 14),
        ));
      } else if (num != null) {
        spans.add(TextSpan(
          text: num,
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 14),
        ));
      } else if (op != null) {
        spans.add(TextSpan(
          text: op,
          style: const TextStyle(color: Colors.white60, fontFamily: 'Inter', fontSize: 14),
        ));
      } else if (sp != null) {
        spans.add(TextSpan(text: sp));
      }
    }
    return RichText(text: TextSpan(children: spans));
  }
}

// ─── Bento text renderer ──────────────────────────────────────────────────────

/// Text renderer for bento card context — respects the card fill colour
/// for text instead of defaulting to the system textPrimary token.
class _BentoText extends StatelessWidget {
  final String md;
  final Color onFill;
  final Color onFillSoft;
  final AppTokens t;

  const _BentoText({
    required this.md,
    required this.onFill,
    required this.onFillSoft,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    // Delegate to the standard ContentBlockRenderer but with override colours
    // applied via a thin Theme override so textPrimary/secondary resolve correctly.
    return ContentBlockRenderer(
      block: TextBlock(LocalizedString({'en': md})),
      textColor: onFill,
      textColorSoft: onFillSoft,
    );
  }
}

// ─── Block renderer ───────────────────────────────────────────────────────────

/// Renders a [ContentBlock]. Called by the card layouts above.
/// Smart markdown parser handles: titles, verdicts, scenario steps,
/// callouts, bullets, headings, bold, italic.
class ContentBlockRenderer extends StatelessWidget {
  final ContentBlock block;
  final Color? textColor;
  final Color? textColorSoft;

  const ContentBlockRenderer({
    super.key,
    required this.block,
    this.textColor,
    this.textColorSoft,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return switch (block) {
      TextBlock(:final md) => _richText(md.resolve('en'), t,
          overrideColor: textColor, overrideColorSoft: textColorSoft),
      FormulaBlock(:final latex) => _formula(latex, t),
      ChartBlock(:final spec) => _chart(spec, t),
      MediaBlock() => _media(block as MediaBlock, t),
    };
  }


  // ─── Rich text renderer ───────────────────────────────────────────────────

  Widget _richText(String md, AppTokens t, {Color? overrideColor, Color? overrideColorSoft}) {
    final effectivePrimary = overrideColor ?? t.textPrimary;
    final effectiveSoft = overrideColorSoft ?? t.textSecondary;
    final lines = md.split('\n');
    final widgets = <Widget>[];

    int i = 0;
    while (i < lines.length) {
      final raw = lines[i];
      final line = raw.trim();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 4));
        i++;
        continue;
      }

      if (_isTitleLine(line, lines, i)) {
        final title = line.replaceAll('**', '').trim();
        widgets.add(_renderTitle(title, t, textColor: effectivePrimary));
        i++;
        continue;
      }

      if (_isVerdictLine(line)) {
        widgets.add(_renderVerdict(line, t, textColor: effectivePrimary));
        i++;
        continue;
      }

      if (line.startsWith('> ')) {
        widgets.add(_renderCallout(line.substring(2).trim(), t, textColor: effectivePrimary));
        i++;
        continue;
      }

      if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        widgets.add(_renderNumberedStep(line, t, textColor: effectivePrimary));
        i++;
        continue;
      }

      if (raw.startsWith('  - ') || raw.startsWith('  • ')) {
        final content = line.startsWith('- ') || line.startsWith('• ')
            ? line.substring(2).trim()
            : line;
        widgets.add(_renderNestedBullet(content, t, textColor: effectiveSoft));
        i++;
        continue;
      }

      if (line.startsWith('- ') || line.startsWith('• ')) {
        final content = line.substring(2).trim();
        widgets.add(_renderBullet(content, t, textColor: effectivePrimary));
        i++;
        continue;
      }

      if (line.startsWith('## ')) {
        widgets.add(_renderH2(line.substring(3).trim(), t, textColor: effectiveSoft));
        i++;
        continue;
      }
      if (line.startsWith('# ')) {
        widgets.add(_renderH1(line.substring(2).trim(), t, textColor: effectivePrimary));
        i++;
        continue;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text.rich(TextSpan(children: _inlineSpans(line, t, textColor: effectivePrimary))),
      ));
      i++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // ─── Title detection & rendering ──────────────────────────────────────────

  bool _isTitleLine(String line, List<String> lines, int i) {
    if (!line.startsWith('**') || !line.endsWith('**')) return false;
    if (line.length < 5) return false;
    // Must be full line bold (no other content outside the **)
    final stripped = line.replaceAll('**', '').trim();
    return stripped.isNotEmpty && !stripped.contains('|');
  }

  Widget _renderTitle(String text, AppTokens t, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textColor ?? t.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _renderH1(String text, AppTokens t, {Color? textColor}) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor ?? t.textPrimary,
          ),
        ),
      );

  Widget _renderH2(String text, AppTokens t, {Color? textColor}) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor ?? t.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Container(height: 1.5, width: 28,
                color: (textColor ?? t.accent).withOpacity(0.5)),
          ],
        ),
      );

  // ─── Verdict / outcome line ────────────────────────────────────────────────

  bool _isVerdictLine(String line) {
    return line.startsWith('✅') ||
        line.startsWith('⚠') ||
        line.startsWith('❌') ||
        line.startsWith('🟢') ||
        line.startsWith('🔴') ||
        line.startsWith('🟡');
  }

  Widget _renderVerdict(String line, AppTokens t, {Color? textColor}) {
    Color bg;
    Color border;
    if (line.startsWith('✅') || line.startsWith('🟢')) {
      bg = const Color(0x1A22C55E);
      border = const Color(0xFF22C55E);
    } else if (line.startsWith('❌') || line.startsWith('🔴')) {
      bg = t.danger.withOpacity(0.12);
      border = t.danger;
    } else {
      bg = t.warning.withOpacity(0.12);
      border = t.warning;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border.withOpacity(0.4)),
        ),
        child: Text.rich(TextSpan(children: _inlineSpans(line, t, textColor: textColor))),
      ),
    );
  }

  // ─── Callout ──────────────────────────────────────────────────────────────

  Widget _renderCallout(String text, AppTokens t, {Color? textColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: (textColor ?? t.accent).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(
              color: (textColor ?? t.accent).withOpacity(0.6), width: 3)),
          ),
          child: Text.rich(TextSpan(children: _inlineSpans(text, t, textColor: textColor))),
        ),
      );

  // ─── Bullets ──────────────────────────────────────────────────────────────

  Widget _renderBullet(String content, AppTokens t, {Color? textColor}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 10),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: (textColor ?? t.accent).withOpacity(0.7),
                  shape: BoxShape.circle),
              ),
            ),
            Expanded(
              child: Text.rich(TextSpan(children: _inlineSpans(content, t, textColor: textColor))),
            ),
          ],
        ),
      );

  Widget _renderNestedBullet(String content, AppTokens t, {Color? textColor}) => Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                    color: (textColor ?? t.textTertiary).withOpacity(0.5),
                    shape: BoxShape.circle),
              ),
            ),
            Expanded(
              child: Text.rich(TextSpan(children: _inlineSpans(content, t, textColor: textColor))),
            ),
          ],
        ),
      );

  // ─── Numbered step ────────────────────────────────────────────────────────

  Widget _renderNumberedStep(String line, AppTokens t, {Color? textColor}) {
    final match = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line);
    final num = match?.group(1) ?? '•';
    final content = match?.group(2) ?? line;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 10, top: 1),
            decoration: BoxDecoration(
              color: t.accentSoft,
              shape: BoxShape.circle,
              border: Border.all(color: t.accent.withOpacity(0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor ?? t.accent,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(TextSpan(children: _inlineSpans(content, t, textColor: textColor))),
          ),
        ],
      ),
    );
  }

  // ─── Inline spans (bold + italic) ─────────────────────────────────────────

  List<InlineSpan> _inlineSpans(String text, AppTokens t, {Color? textColor}) {
    final fg = textColor ?? t.textPrimary;
    final base = TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: fg,
    );
    final bold = base.copyWith(fontWeight: FontWeight.w700);
    final italic = base.copyWith(fontStyle: FontStyle.italic);

    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    var idx = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > idx) {
        spans.add(TextSpan(text: text.substring(idx, m.start), style: base));
      }
      if (m.group(1) != null) {
        spans.add(TextSpan(text: m.group(1), style: bold));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(text: m.group(2), style: italic));
      }
      idx = m.end;
    }
    if (idx < text.length) {
      spans.add(TextSpan(text: text.substring(idx), style: base));
    }
    return spans.isEmpty ? [TextSpan(text: text, style: base)] : spans;
  }

  // ─── Formula ──────────────────────────────────────────────────────────────

  Widget _formula(String latex, AppTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: t.accentSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.accent.withOpacity(0.4)),
        ),
        child: _buildMathWidget(latex, t),
      ),
    );
  }

  Widget _buildMathWidget(String latex, AppTokens t) {
    final fracMatch =
        RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}').firstMatch(latex);
    if (fracMatch != null) {
      final before = latex.substring(0, fracMatch.start).trim();
      final num = fracMatch.group(1)!.trim();
      final den = fracMatch.group(2)!.trim();
      final after = latex.substring(fracMatch.end).trim();

      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          if (before.isNotEmpty)
            Text(_tok(before), style: _opSt(t), textAlign: TextAlign.center),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_tok(num), style: _varSt(t), textAlign: TextAlign.center),
              Container(
                height: 1.5,
                width: _fracW(num, den),
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: t.accent,
              ),
              Text(_tok(den), style: _varSt(t), textAlign: TextAlign.center),
            ],
          ),
          if (after.isNotEmpty)
            Text(_tok(after), style: _opSt(t), textAlign: TextAlign.center),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      children: _colorizeLatex(latex, t),
    );
  }

  double _fracW(String a, String b) =>
      ((a.length > b.length ? a : b).length * 8.5).clamp(40.0, 240.0);

  String _tok(String s) {
    var r = s;
    r = r.replaceAllMapped(RegExp(r'\\text\{(.*?)\}'), (m) => m[1] ?? '');
    r = r
        .replaceAll(r'\times', '×')
        .replaceAll(r'\div', '÷')
        .replaceAll(r'\cdot', '·')
        .replaceAll(r'\le', '≤')
        .replaceAll(r'\ge', '≥')
        .replaceAll(r'\%', '%')
        .replaceAll(r'\approx', '≈')
        .replaceAll(r'\pm', '±')
        .replaceAll(r'\alpha', 'α')
        .replaceAll(r'\beta', 'β')
        .replaceAll(r'\sigma', 'σ')
        .replaceAll(r'\mu', 'μ')
        .replaceAll(r'\Delta', 'Δ')
        .replaceAll(r'\sqrt', '√')
        .replaceAll('{', '').replaceAll('}', '').replaceAll('\\', '').trim();
    return r;
  }

  List<Widget> _colorizeLatex(String latex, AppTokens t) {
    final clean = _tok(latex);
    final re = RegExp(r'([A-Za-z_]\w*)|([0-9]+\.?[0-9]*%?)|([^\w\s]+)|(\s+)');
    final out = <Widget>[];
    for (final m in re.allMatches(clean)) {
      if (m.group(4) != null) {
        out.add(const SizedBox(width: 3));
        continue;
      }
      final txt = m.group(0) ?? '';
      final style = m.group(1) != null
          ? _varSt(t)
          : m.group(2) != null
              ? _numSt(t)
              : _opSt(t);
      out.add(Text(txt, style: style));
    }
    return out.isEmpty ? [Text(clean, style: _opSt(t))] : out;
  }

  TextStyle _varSt(AppTokens t) => TextStyle(
        color: t.accent,
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
        fontFamily: 'Inter',
      );
  TextStyle _numSt(AppTokens t) => TextStyle(
        color: t.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 13.5,
        fontFamily: 'Inter',
      );
  TextStyle _opSt(AppTokens t) => TextStyle(
        color: t.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 13.5,
        fontFamily: 'Inter',
      );

  // ─── Chart ────────────────────────────────────────────────────────────────

  Widget _chart(Map<String, dynamic> spec, AppTokens t) {
    final type = spec['type']?.toString() ?? '';
    final title = spec['title']?.toString();
    final unit = (spec['unit'] ?? '%').toString();

    Widget body;
    if (type == 'stacked_bar') {
      body = _stackedBar(spec, t, unit);
    } else if (type == 'threshold_line') {
      body = _thresholdLine(spec, t, unit);
    } else {
      body = _legacyBars(spec, t, unit);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: t.bgBase,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: t.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
            ],
            body,
          ],
        ),
      ),
    );
  }

  Widget _stackedBar(Map<String, dynamic> spec, AppTokens t, String unit) {
    final groups = (spec['groups'] as List?) ?? const [];
    if (groups.isEmpty) return const SizedBox.shrink();
    double totalMax = 0;
    for (final g in groups) {
      final layers = (g as Map)['layers'] as List? ?? const [];
      final sum = layers.fold<double>(
          0, (acc, l) => acc + ((l as Map)['value'] as num? ?? 0).toDouble());
      if (sum > totalMax) totalMax = sum;
    }
    if (totalMax == 0) totalMax = 1;
    final allLayers = <Map>[];
    for (final g in groups) {
      for (final l in (g as Map)['layers'] as List? ?? const []) {
        final lm = (l as Map).cast<String, dynamic>();
        if (!allLayers.any((x) => x['label'] == lm['label'])) {
          allLayers.add(lm);
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final g in groups) ...[
          _stackedRow(g as Map, totalMax, t, unit),
          const SizedBox(height: 6),
        ],
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: allLayers
              .map((l) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _hex(l['color']?.toString() ?? '', t.accent),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${l['label'] ?? ''} (${_fmtV((l['value'] as num?)?.toDouble() ?? 0)}$unit)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5,
                          color: t.textTertiary,
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _stackedRow(Map g, double totalMax, AppTokens t, String unit) {
    final label = (g['label'] ?? '').toString();
    final layers = (g['layers'] as List?) ?? const [];
    final sum = layers.fold<double>(
        0, (acc, l) => acc + ((l as Map)['value'] as num? ?? 0).toDouble());
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                color: t.textSecondary),
            textAlign: TextAlign.right,
            maxLines: 2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 16,
            child: LayoutBuilder(builder: (ctx, bc) {
              return CustomPaint(
                size: Size(bc.maxWidth, 16),
                painter:
                    _StackedBarPainter(layers: layers, totalMax: totalMax, t: t),
              );
            }),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${_fmtV(sum)}$unit',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: t.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _thresholdLine(Map<String, dynamic> spec, AppTokens t, String unit) {
    final bars = (spec['bars'] as List?) ?? const [];
    final thresholds = (spec['thresholds'] as List?) ?? const [];
    final maxVal = (spec['max'] as num?)?.toDouble() ?? 150;
    return Column(
      children: (bars).map((b) {
        final bm = b as Map;
        final label = (bm['label'] ?? '').toString();
        final value = (bm['value'] as num?)?.toDouble() ?? 0;
        final color = _hex(bm['color']?.toString() ?? '', t.accent);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 88,
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: t.textSecondary),
                    textAlign: TextAlign.right,
                    maxLines: 2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: LayoutBuilder(builder: (ctx, bc) {
                    return CustomPaint(
                      size: Size(bc.maxWidth, 36),
                      painter: _ThresholdBarPainter(
                        value: value,
                        maxVal: maxVal,
                        thresholds: thresholds,
                        barColor: color,
                        t: t,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_fmtV(value)}$unit',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _legacyBars(Map<String, dynamic> spec, AppTokens t, String unit) {
    final type = spec['type']?.toString() ?? '';
    final bars = <_Bar>[];
    if (type == 'bar_segment') {
      final seg =
          (spec['segment'] as Map?)?.cast<String, dynamic>() ?? const {};
      bars.add(_Bar((seg['label'] ?? '').toString(),
          (seg['value'] as num?)?.toDouble() ?? 0, 100));
    } else {
      final items = (spec['items'] as List?) ?? const [];
      var maxV = 0.0;
      for (final e in items) {
        final v = ((e as Map)['value'] as num?)?.toDouble() ?? 0;
        if (v > maxV) maxV = v;
      }
      for (final e in items) {
        final m = (e as Map).cast<String, dynamic>();
        bars.add(_Bar((m['label'] ?? '').toString(),
            (m['value'] as num?)?.toDouble() ?? 0, maxV == 0 ? 1 : maxV));
      }
    }
    if (bars.isEmpty) bars.add(const _Bar('', 0, 1));
    return SizedBox(
      width: double.infinity,
      height: bars.length * 30.0 + 4,
      child:
          CustomPaint(painter: _BarChartPainter(bars: bars, unit: unit, t: t)),
    );
  }

  // ─── Media ────────────────────────────────────────────────────────────────

  Widget _media(MediaBlock b, AppTokens t) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: t.bgBase,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.border),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                b.mediaKind == 'audio'
                    ? Icons.audiotrack_outlined
                    : Icons.image_outlined,
                color: t.accent,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(b.alt.resolve('en'),
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: t.textTertiary)),
            ],
          ),
        ),
      );

  // ─── Utilities ────────────────────────────────────────────────────────────

  String _fmtV(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Color _hex(String hex, Color fallback) {
    try {
      final h = hex.replaceAll('#', '');
      if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    } catch (_) {}
    return fallback;
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _Bar {
  final String label;
  final double value;
  final double max;
  const _Bar(this.label, this.value, this.max);
}

class _BarChartPainter extends CustomPainter {
  final List<_Bar> bars;
  final String unit;
  final AppTokens t;

  _BarChartPainter({required this.bars, required this.unit, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final n = bars.length;
    if (n == 0 || size.width < 1) return;
    final rowH = size.height / n;
    final labelW = size.width * 0.38;
    const valueW = 54.0;
    final trackLeft = labelW + 8;
    final trackRight = size.width - valueW;
    final trackW = (trackRight - trackLeft).clamp(10.0, size.width);

    for (var i = 0; i < n; i++) {
      final bar = bars[i];
      final cy = i * rowH + rowH / 2;
      final barH = (rowH * 0.45).clamp(5.0, 14.0);
      final top = cy - barH / 2;

      _tp(canvas, bar.label, Offset(0, cy), labelW, t.textSecondary,
          TextAlign.right);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(trackLeft, top, trackW, barH),
              const Radius.circular(4)),
          Paint()..color = t.border);
      final frac = (bar.max <= 0 ? 0.0 : bar.value / bar.max).clamp(0.0, 1.0);
      if (frac > 0) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(trackLeft, top, trackW * frac, barH),
                const Radius.circular(4)),
            Paint()..color = t.accent);
      }
      _tp(canvas, '${_fmtV(bar.value)}$unit', Offset(trackRight + 4, cy),
          valueW - 4, t.textPrimary, TextAlign.left);
    }
  }

  void _tp(Canvas canvas, String s, Offset at, double width, Color color,
      TextAlign align) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              color: color, fontSize: 11.5, fontFamily: 'Inter')),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: width);
    final dx =
        align == TextAlign.right ? at.dx + width - tp.width : at.dx;
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  String _fmtV(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.bars != bars;
}

class _StackedBarPainter extends CustomPainter {
  final List layers;
  final double totalMax;
  final AppTokens t;

  _StackedBarPainter(
      {required this.layers, required this.totalMax, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final barH = size.height * 0.65;
    final top = (size.height - barH) / 2;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, top, size.width, barH),
            const Radius.circular(4)),
        Paint()..color = t.border);
    var x = 0.0;
    for (final l in layers) {
      final lm = l as Map;
      final value = (lm['value'] as num?)?.toDouble() ?? 0;
      final color = _hex(lm['color']?.toString() ?? '', t.accent);
      final frac =
          (totalMax <= 0 ? 0.0 : value / totalMax).clamp(0.0, 1.0);
      final segW = size.width * frac;
      if (segW > 0) {
        final isFirst = x < 0.5;
        final isLast = (x + segW) >= size.width - 1;
        canvas.drawRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(x, top, segW, barH),
              topLeft: isFirst ? const Radius.circular(4) : Radius.zero,
              bottomLeft: isFirst ? const Radius.circular(4) : Radius.zero,
              topRight: isLast ? const Radius.circular(4) : Radius.zero,
              bottomRight: isLast ? const Radius.circular(4) : Radius.zero,
            ),
            Paint()..color = color);
      }
      x += segW;
    }
  }

  Color _hex(String hex, Color fallback) {
    try {
      final h = hex.replaceAll('#', '');
      if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    } catch (_) {}
    return fallback;
  }

  @override
  bool shouldRepaint(covariant _StackedBarPainter old) => false;
}

class _ThresholdBarPainter extends CustomPainter {
  final double value;
  final double maxVal;
  final List thresholds;
  final Color barColor;
  final AppTokens t;

  _ThresholdBarPainter({
    required this.value,
    required this.maxVal,
    required this.thresholds,
    required this.barColor,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barH = 14.0;
    const top = 2.0;
    final frac = (maxVal <= 0 ? 0.0 : value / maxVal).clamp(0.0, 1.0);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, top, size.width, barH),
            const Radius.circular(4)),
        Paint()..color = t.border);
    if (frac > 0) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(0, top, size.width * frac, barH),
              const Radius.circular(4)),
          Paint()..color = barColor);
    }
    for (final thresh in thresholds) {
      final tm = thresh as Map;
      final tv = (tm['value'] as num?)?.toDouble() ?? 0;
      final tFrac = (maxVal <= 0 ? 0.0 : tv / maxVal).clamp(0.0, 1.0);
      final tx = size.width * tFrac;
      final thColor =
          _hex(tm['color']?.toString() ?? '', const Color(0xFFEF4444));
      final paint = Paint()
        ..color = thColor
        ..strokeWidth = 1.5;
      var dy = top - 3.0;
      while (dy < top + barH + 3) {
        canvas.drawLine(Offset(tx, dy), Offset(tx, (dy + 4).clamp(0, size.height)), paint);
        dy += 7;
      }
      final tp = TextPainter(
        text: TextSpan(
            text: '${tm['label'] ?? ''} (${tv.toStringAsFixed(0)}%)',
            style: TextStyle(
                color: thColor, fontSize: 10, fontFamily: 'Inter')),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.6);
      tp.paint(canvas,
          Offset((tx - tp.width / 2).clamp(0, size.width - tp.width), top + barH + 4));
    }
  }

  Color _hex(String hex, Color fallback) {
    try {
      final h = hex.replaceAll('#', '');
      if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    } catch (_) {}
    return fallback;
  }

  @override
  bool shouldRepaint(covariant _ThresholdBarPainter old) => false;
}
