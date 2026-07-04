import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_theme.dart';

/// ════════════════════════════════════════════════════════════════════════
/// Section Kit — shared "editorial data brief" UI language for category
/// screens. One bold accent-colored hero per screen; everything else quiet
/// white panels with an accent-spine section header.
///
/// All components are accent-driven: pass the group color (blue = Economic,
/// green = Social, orange = Development) and the chrome adapts.
/// ════════════════════════════════════════════════════════════════════════

const String kDisplayFont = 'PlusJakartaSans';

/// Deepen + saturate an accent into a solid hero fill. Lightness is clamped
/// dark enough that white type clears contrast on every brand color.
Color heroFill(Color accent) {
  final hsl = HSLColor.fromColor(accent);
  return hsl
      .withLightness((hsl.lightness - 0.04).clamp(0.0, 0.46))
      .withSaturation((hsl.saturation + 0.06).clamp(0.0, 1.0))
      .toColor();
}

/// Bake a lighter shade of [fill] by mixing in white — returns a SOLID color
/// (no runtime transparency), so the hero never shows a translucent fade.
Color heroShade(Color fill, double whiteAmount) =>
    Color.alphaBlend(Colors.white.withOpacity(whiteAmount), fill);

/// Quiet white container used for every non-hero section.
class SectionPanel extends StatelessWidget {
  final Widget child;
  final bool isSmall;
  final EdgeInsets? padding;

  const SectionPanel({
    super.key,
    required this.child,
    this.isSmall = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Flat surface to match the editorial spine: no border, no shadow. The
    // spine rail now carries the structure, so panels stay quiet.
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(isSmall ? 16 : 18),
      decoration: BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

/// Accent-spine section header: 4px color bar + title (+ optional subtitle,
/// trailing widget). Replaces the old boxed-icon + grey header pattern.
class SectionHead extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accent;
  final bool isSmall;
  final Widget? trailing;

  const SectionHead({
    super.key,
    required this.title,
    this.subtitle,
    this.accent = bpsBlue,
    this.isSmall = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: subtitle != null ? (isSmall ? 34 : 38) : 22,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: kDisplayFont,
                  fontSize: isSmall ? 15.5 : 17,
                  fontWeight: FontWeight.w700,
                  color: bpsTextPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: isSmall ? 11.5 : 12.5,
                    color: bpsTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small left-accent stat tile (paired metrics under a feature value).
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSmall;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 14),
      decoration: BoxDecoration(
        color: bpsBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmall ? 18 : 20),
          SizedBox(height: isSmall ? 8 : 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: kDisplayFont,
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.w800,
              color: bpsTextPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              color: bpsTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single labelled fact rendered inside the hero footer.
class HeroFact {
  final String label;
  final String value;
  const HeroFact(this.label, this.value);
}

/// The one bold colored block per screen — the headline indicator.
/// Gradient field, oversized value, optional delta chip, optional sparkline,
/// optional footer facts.
class IndicatorHero extends StatelessWidget {
  final String overline;
  final String value;
  final String subtitle;
  final String? badge;
  final Color accent;
  final double? delta;
  final String deltaUnit;
  final List<double>? sparkline;
  final List<HeroFact> facts;
  final bool isSmall;
  final IconData? icon;

  const IndicatorHero({
    super.key,
    required this.overline,
    required this.value,
    required this.subtitle,
    this.badge,
    this.accent = bpsBlue,
    this.delta,
    this.deltaUnit = 'pp',
    this.sparkline,
    this.facts = const [],
    this.isSmall = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fill = heroFill(accent);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // One solid, deepened brand color. No gradient, no wash, no glow.
        color: fill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          // Measurement-rule texture along the base — the masthead signature.
          painter: _HeroRulerPainter(fill: fill),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isSmall ? 20 : 24,
              isSmall ? 18 : 22,
              isSmall ? 20 : 24,
              isSmall ? 22 : 28,
            ),
            child: _content(fill),
          ),
        ),
      ),
    );
  }

  Widget _content(Color fill) {
    // All non-white tones are baked to solid shades of the fill.
    final faint = heroShade(fill, 0.22);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                overline.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: heroShade(fill, 0.82),
                  fontSize: isSmall ? 10 : 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: fill,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: isSmall ? 14 : 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kDisplayFont,
                  color: Colors.white,
                  fontSize: isSmall ? 48 : 58,
                  fontWeight: FontWeight.w800,
                  height: 0.92,
                  letterSpacing: -2.2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (delta != null) ...[
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _DeltaChip(
                    delta: delta!, unit: deltaUnit, isSmall: isSmall),
              ),
            ],
          ],
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: TextStyle(
            color: heroShade(fill, 0.72),
            fontSize: isSmall ? 11.5 : 12.5,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        if (sparkline != null && sparkline!.isNotEmpty) ...[
          SizedBox(height: isSmall ? 16 : 20),
          SizedBox(
            height: isSmall ? 44 : 52,
            child: MiniSparkline(values: sparkline!, accent: fill),
          ),
        ],
        if (facts.isNotEmpty) ...[
          SizedBox(height: isSmall ? 16 : 20),
          Container(height: 1, color: faint),
          SizedBox(height: isSmall ? 12 : 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < facts.length; i++) ...[
                if (i > 0) Container(width: 1, height: 28, color: faint),
                _heroFact(fill, facts[i]),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _heroFact(Color fill, HeroFact fact) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fact.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: heroShade(fill, 0.6),
                fontSize: isSmall ? 9.5 : 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              fact.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: kDisplayFont,
                color: Colors.white,
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Measurement-rule scale pinned to the base of the solid hero field. Ticks
/// are solid shades of the fill (no transparency); every fifth tick is taller
/// and brighter. Gives the masthead a precision-instrument identity.
class _HeroRulerPainter extends CustomPainter {
  final Color fill;
  const _HeroRulerPainter({required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    const step = 13.0;
    final baseY = size.height - 1;

    final base = Paint()
      ..color = heroShade(fill, 0.2)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), base);

    final minor = Paint()
      ..color = heroShade(fill, 0.26)
      ..strokeWidth = 1;
    final major = Paint()
      ..color = heroShade(fill, 0.66)
      ..strokeWidth = 1.4;

    int i = 0;
    for (double x = step; x < size.width; x += step) {
      final isMajor = i % 5 == 4;
      final h = isMajor ? 11.0 : 6.0;
      canvas.drawLine(
        Offset(x, baseY - h),
        Offset(x, baseY),
        isMajor ? major : minor,
      );
      i++;
    }
  }

  @override
  bool shouldRepaint(_HeroRulerPainter old) => old.fill != fill;
}

class _DeltaChip extends StatelessWidget {
  final double delta;
  final String unit;
  final bool isSmall;

  const _DeltaChip(
      {required this.delta, required this.unit, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final tint = positive ? bpsGreen : bpsRed;
    final fmt = delta.abs().toStringAsFixed(2).replaceAll('.', ',');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        // Solid white chip on the colored field — colored text carries the
        // up/down signal. No translucent tint.
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: tint,
            size: isSmall ? 13 : 14,
          ),
          const SizedBox(width: 3),
          Text(
            '${positive ? '+' : '-'}$fmt $unit',
            style: TextStyle(
              color: tint,
              fontSize: isSmall ? 11.5 : 12.5,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Accent line sparkline on the paper hero field. Dot only on the last point.
class MiniSparkline extends StatelessWidget {
  final List<double> values;
  final Color accent;

  const MiniSparkline({super.key, required this.values, required this.accent});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final lastIndex = values.length - 1;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minX: 0,
        maxX: lastIndex.toDouble(),
        minY: minV - 1,
        maxY: maxV + 1,
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            color: Colors.white,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index != lastIndex) {
                  return FlDotCirclePainter(radius: 0, color: Colors.white);
                }
                // White ring around the fill color — solid, no fade.
                return FlDotCirclePainter(
                  radius: 4.5,
                  color: accent,
                  strokeWidth: 2.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            // No area fill — the user asked for no semi-transparent gradients.
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

/// Horizontal pill rail for selecting a year (or any int key).
class YearRail extends StatelessWidget {
  final List<int> years;
  final int selected;
  final ValueChanged<int> onSelect;
  final Color accent;
  final bool isSmall;
  final ScrollController? controller;
  final String label;

  const YearRail({
    super.key,
    required this.years,
    required this.selected,
    required this.onSelect,
    this.accent = bpsBlue,
    this.isSmall = false,
    this.controller,
    this.label = 'TAHUN DATA',
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...years]..sort();
    final menuYears = sorted.reversed.toList(); // latest first

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: kDisplayFont,
            fontSize: isSmall ? 9.5 : 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: bpsTextLabel,
          ),
        ),
        SizedBox(width: isSmall ? 10 : 12),
        // compact dropdown chip
        PopupMenuButton<int>(
          initialValue: selected,
          onSelected: onSelect,
          tooltip: 'Pilih tahun',
          offset: const Offset(0, 44),
          color: bpsCardBg,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: bpsBorder),
          ),
          itemBuilder: (_) => [
            for (final year in menuYears)
              PopupMenuItem<int>(
                value: year,
                height: 42,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontFamily: kDisplayFont,
                          fontSize: 15,
                          fontWeight: year == selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: year == selected ? accent : bpsTextPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    if (year == selected)
                      Icon(Icons.check_rounded, color: accent, size: 18),
                  ],
                ),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selected.toString(),
                  style: TextStyle(
                    fontFamily: kDisplayFont,
                    fontSize: isSmall ? 16 : 17.5,
                    fontWeight: FontWeight.w800,
                    color: bpsTextPrimary,
                    letterSpacing: 0.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(width: isSmall ? 2 : 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: accent, size: isSmall ? 20 : 22),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// Editorial spine — a continuous left rail threads every section of a screen.
/// Each section gets a numbered node + title beside it; content sits below,
/// indented under the title. Sections stack with NO gaps between them so the
/// rail reads as one unbroken line down the page.
///
/// Every section shares ONE quiet surface — flat white, soft rounded, no
/// border and no drop shadow — so the page reads as a single connected
/// document threaded by the rail rather than a stack of disconnected cards.
/// `framed: false` only tightens padding (used for charts that supply their
/// own internal margins); it is NOT a different surface.
///
/// Pass a `number` ("01", "02"…) for ordinary nodes; leave it null for the
/// final/conclusion node, which renders as a solid accent dot.
/// ════════════════════════════════════════════════════════════════════════
class SpineSection extends StatelessWidget {
  final String? number;
  final String title;
  final String? subtitle;
  final String? overline;
  final Color accent;
  final Widget child;
  final bool framed;
  final bool surface;
  final bool spine;
  final bool isFirst;
  final bool isLast;
  final bool isSmall;
  final Widget? trailing;

  const SpineSection({
    super.key,
    this.number,
    required this.title,
    required this.child,
    this.subtitle,
    this.overline,
    this.accent = bpsBlue,
    this.framed = true,
    this.surface = true,
    this.spine = false,
    this.isFirst = false,
    this.isLast = false,
    this.isSmall = false,
    this.trailing,
  });

  static const double _nodeSize = 24;
  // Slim left gutter: the node sits in the top-left corner and the rail line
  // runs down the far-left edge, so section BODIES keep almost the full screen
  // width on a phone. Only the header hangs indented beside the node.
  static const double _bodyIndent = 16; // clears the rail line
  // Node center measured from the top of the section — aligned to the vertical
  // middle of the title block so the line enters/exits through the node.
  double get _nodeCenterY => _nodeSize / 2;

  @override
  Widget build(BuildContext context) {
    if (!spine) return _buildReport(context);

    final lineX = _nodeSize / 2; // rail line runs through the node centre
    final headerExtra = _nodeSize + 8 - _bodyIndent; // header clears the node
    final line = accent.withOpacity(0.22);
    final bottomGap = isLast ? 0.0 : (isSmall ? 22.0 : 26.0);

    // Stack sized by the (non-positioned) content; the rail line uses
    // top/bottom anchoring to fill that height — no IntrinsicHeight, so
    // LayoutBuilder / ScrollView children inside the surface are safe.
    return Stack(
      children: [
        // line above the node (omitted on the first section)
        if (!isFirst)
          Positioned(
            left: lineX - 1,
            top: 0,
            height: _nodeCenterY,
            child: Container(width: 2, color: line),
          ),
        // line below the node, fills to the bottom (omitted on last)
        if (!isLast)
          Positioned(
            left: lineX - 1,
            top: _nodeCenterY,
            bottom: 0,
            child: Container(width: 2, color: line),
          ),
        // ── Content column (sizes the stack) ──────────────────────────
        Padding(
          padding: EdgeInsets.only(left: _bodyIndent, bottom: bottomGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header hangs indented beside the corner node
              Padding(
                padding: EdgeInsets.only(left: headerExtra),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _nodeSize),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (overline != null) ...[
                      Text(
                        overline!.toUpperCase(),
                        style: TextStyle(
                          fontFamily: kDisplayFont,
                          fontSize: isSmall ? 9.5 : 10,
                          fontWeight: FontWeight.w700,
                          color: accent,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: kDisplayFont,
                              fontSize: isSmall ? 16.5 : 18.5,
                              fontWeight: FontWeight.w800,
                              color: bpsTextPrimary,
                              letterSpacing: -0.4,
                              height: 1.08,
                            ),
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 8),
                          trailing!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: isSmall ? 11.5 : 12.5,
                          color: bpsTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ),
              SizedBox(height: isSmall ? 9 : 11),
              // report-style rule: short accent lead + hairline
              Row(
                children: [
                  Container(width: 22, height: 2.5, color: accent),
                  Expanded(
                    child: Container(height: 1, color: bpsBorder),
                  ),
                ],
              ),
              SizedBox(height: isSmall ? 12 : 14),
              if (surface)
                Container(
                  width: double.infinity,
                  padding: framed
                      ? EdgeInsets.all(isSmall ? 16 : 18)
                      : EdgeInsets.all(isSmall ? 10 : 12),
                  decoration: BoxDecoration(
                    color: bpsCardBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: child,
                )
              else
                child,
            ],
          ),
        ),
        // ── Node (top-left corner, on top of the line) ────────────────
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: _nodeSize,
            height: _nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLast ? accent : Colors.white,
              border: Border.all(color: accent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isLast
                  ? const Icon(Icons.flag_rounded,
                      color: Colors.white, size: 13)
                  : Text(
                      number ?? '•',
                      style: TextStyle(
                        fontFamily: kDisplayFont,
                        color: accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Report mode (`spine: false`): no rail, no node, no per-section card —
  /// the section sits directly on the white "sheet" page, full width, with a
  /// numbered overline + title + hairline rule acting as the divider.
  Widget _buildReport(BuildContext context) {
    final bottomGap = isLast ? 0.0 : (isSmall ? 26.0 : 30.0);
    final kicker = [
      if (number != null) number!,
      if (overline != null) overline!.toUpperCase(),
    ].join('  ·  ');

    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kicker.isNotEmpty) ...[
            Text(
              kicker,
              style: TextStyle(
                fontFamily: kDisplayFont,
                fontSize: isSmall ? 9.5 : 10,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 1.6,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: kDisplayFont,
                    fontSize: isSmall ? 18 : 20,
                    fontWeight: FontWeight.w800,
                    color: bpsTextPrimary,
                    letterSpacing: -0.4,
                    height: 1.05,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: isSmall ? 11.5 : 12.5,
                color: bpsTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: isSmall ? 10 : 12),
          // divider rule: short accent lead + hairline
          Row(
            children: [
              Container(width: 26, height: 2.5, color: accent),
              Expanded(child: Container(height: 1, color: bpsBorder)),
            ],
          ),
          SizedBox(height: isSmall ? 14 : 16),
          child,
        ],
      ),
    );
  }
}

/// Slim screen header with overline + title, accent background.
class CategoryHeader extends StatelessWidget {
  final String overline;
  final String title;
  final IconData icon;
  final Color accent;
  final bool isSmall;
  final double titleSize;

  const CategoryHeader({
    super.key,
    required this.overline,
    required this.title,
    required this.icon,
    this.accent = bpsBlue,
    this.isSmall = false,
    this.titleSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Same deepened fill as the hero — header + hero read as one solid
      // masthead. Flat: no colored glow.
      decoration: BoxDecoration(color: heroFill(accent)),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 16,
            vertical: isSmall ? 10 : 14,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(isSmall ? 10 : 12),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: isSmall ? 20 : 24,
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overline,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: isSmall ? 9.5 : 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: kDisplayFont,
                        color: Colors.white,
                        fontSize: isSmall ? titleSize - 4 : titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: isSmall ? 22 : 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
