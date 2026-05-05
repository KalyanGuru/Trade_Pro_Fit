import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../search/search_page.dart';
import '../auth/auth_page.dart';
import '../../widgets/charts.dart';
import '../../data/models.dart';
import 'live_providers.dart';

// =========================================
// COLOR PALETTE
// =========================================

const _kAccent = Color(0xFF6C5CE7);
const _kGreen = Color(0xFF00E676);
const _kRed = Color(0xFFFF5252);
const _kAmber = Color(0xFFFFD740);
const _kCyan = Color(0xFF00D2FF);
const _kCardBg = Color(0xFF151528);
const _kCardBorder = Color(0x10FFFFFF);

class LivePage extends ConsumerWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picked = ref.watch(selectedInstrumentProvider);
    final connectionAsync = ref.watch(connectionStatusProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // ─── CONNECTION STATUS BAR ───
        _ConnectionStatusBar(connectionAsync: connectionAsync),

        const SizedBox(height: 12),

        // ─── HEADER ───
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    picked?.symbol ?? 'Select a Stock',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (picked != null)
                    Text(
                      picked.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white38,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                _GlowButton(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  onTap: () => _openSearch(context, ref),
                ),
                const SizedBox(width: 8),
                _GlowButton(
                  icon: Icons.link_rounded,
                  label: 'Kite',
                  color: _kCyan,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AuthPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ─── DATA CARDS ───
        if (picked != null) ...[
          // Row 1: Live Price (full width)
          const _LivePriceCard(),

          const SizedBox(height: 12),

          // Row 2: Prediction + Trend
          const Row(
            children: [
              Expanded(child: _PredictionCard()),
              SizedBox(width: 12),
              Expanded(child: _TrendCard()),
            ],
          ),

          const SizedBox(height: 12),

          // Row 3: Confidence + Cluster
          const Row(
            children: [
              Expanded(child: _ConfidenceCard()),
              SizedBox(width: 12),
              Expanded(child: _ClusterTypeCard()),
            ],
          ),

          const SizedBox(height: 16),

          // ─── CHART ───
          const _PriceHistorySection(),

          const SizedBox(height: 12),

          // ─── LAST UPDATED ───
          const _LastUpdatedRow(),
        ] else ...[
          const SizedBox(height: 80),
          _EmptyState(),
        ],
      ],
    );
  }

  void _openSearch(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF12122A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 420,
            child: SearchPage(
              onPick: (ins) {
                ref.read(selectedInstrumentProvider.notifier).select(ins);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// CONNECTION STATUS BAR
// ═══════════════════════════════════════════

class _ConnectionStatusBar extends StatelessWidget {
  final AsyncValue<ConnectionStatus> connectionAsync;

  const _ConnectionStatusBar({required this.connectionAsync});

  @override
  Widget build(BuildContext context) {
    final status = connectionAsync.valueOrNull ?? ConnectionStatus.disconnected;

    Color dotColor;
    String label;

    switch (status) {
      case ConnectionStatus.connected:
        dotColor = _kGreen;
        label = 'Live';
        break;
      case ConnectionStatus.reconnecting:
        dotColor = _kAmber;
        label = 'Reconnecting...';
        break;
      case ConnectionStatus.disconnected:
        dotColor = _kRed;
        label = 'Disconnected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: dotColor, animate: status == ConnectionStatus.connected),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// CARD 1 — LIVE PRICE (LTP)
// ═══════════════════════════════════════════

class _LivePriceCard extends ConsumerStatefulWidget {
  const _LivePriceCard();

  @override
  ConsumerState<_LivePriceCard> createState() => _LivePriceCardState();
}

class _LivePriceCardState extends ConsumerState<_LivePriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  double? _prevPrice;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ltpAsync = ref.watch(livePriceProvider);

    return ltpAsync.when(
      data: (ltp) {
        final isUp = _prevPrice != null && ltp > _prevPrice!;
        final isDown = _prevPrice != null && ltp < _prevPrice!;
        final priceColor = isUp ? _kGreen : (isDown ? _kRed : Colors.white);

        if (_prevPrice != null && ltp != _prevPrice) {
          _pulseCtrl.forward(from: 0);
        }
        _prevPrice = ltp;

        return _GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: _kCyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Live Price',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 1 - _pulseCtrl.value,
                        child: Container(
                          width: 8 + _pulseCtrl.value * 8,
                          height: 8 + _pulseCtrl.value * 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: priceColor.withValues(
                                alpha: 0.6 - _pulseCtrl.value * 0.6),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.inter(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: priceColor,
                  letterSpacing: -1,
                ),
                child: Text('₹${ltp.toStringAsFixed(2)}'),
              ),
              if (isUp)
                _directionalChip('▲', _kGreen)
              else if (isDown)
                _directionalChip('▼', _kRed),
            ],
          ),
        );
      },
      loading: () => _GlassCard(
        child: _ShimmerBlock(height: 100),
      ),
      error: (err, _) => _GlassCard(
        child: _ErrorContent(message: 'Price unavailable'),
      ),
    );
  }

  Widget _directionalChip(String arrow, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        arrow,
        style: TextStyle(fontSize: 16, color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// CARD 2 — PREDICTION
// ═══════════════════════════════════════════

class _PredictionCard extends ConsumerWidget {
  const _PredictionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predAsync = ref.watch(predictionProvider);

    return predAsync.when(
      data: (data) {
        final val = data.prediction;
        final color = val > 0 ? _kGreen : (val < 0 ? _kRed : Colors.white70);

        return _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardLabel(icon: Icons.auto_graph_rounded, label: 'Prediction'),
              const SizedBox(height: 14),
              Text(
                '${val >= 0 ? '+' : ''}${val.toStringAsFixed(3)}%',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '60-min return',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _GlassCard(child: _ShimmerBlock(height: 80)),
      error: (_, __) => _GlassCard(child: _ErrorContent(message: '—')),
    );
  }
}

// ═══════════════════════════════════════════
// CARD 3 — TREND
// ═══════════════════════════════════════════

class _TrendCard extends ConsumerWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predAsync = ref.watch(predictionProvider);

    return predAsync.when(
      data: (data) {
        IconData icon;
        Color color;
        switch (data.trend) {
          case 'UP':
            icon = Icons.trending_up_rounded;
            color = _kGreen;
            break;
          case 'DOWN':
            icon = Icons.trending_down_rounded;
            color = _kRed;
            break;
          default:
            icon = Icons.trending_flat_rounded;
            color = _kAmber;
        }

        return _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardLabel(icon: Icons.insights_rounded, label: 'Trend'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    data.trend,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => _GlassCard(child: _ShimmerBlock(height: 80)),
      error: (_, __) => _GlassCard(child: _ErrorContent(message: '—')),
    );
  }
}

// ═══════════════════════════════════════════
// CARD 4 — CONFIDENCE SCORE
// ═══════════════════════════════════════════

class _ConfidenceCard extends ConsumerWidget {
  const _ConfidenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predAsync = ref.watch(predictionProvider);

    return predAsync.when(
      data: (data) {
        final pct = data.confidence.clamp(0, 100);
        final color = pct >= 70
            ? _kGreen
            : pct >= 45
                ? _kAmber
                : _kRed;

        return _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardLabel(icon: Icons.psychology_rounded, label: 'Confidence'),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: pct / 100,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _GlassCard(child: _ShimmerBlock(height: 100)),
      error: (_, __) => _GlassCard(child: _ErrorContent(message: '—')),
    );
  }
}

// ═══════════════════════════════════════════
// CARD 5 — CLUSTER TYPE
// ═══════════════════════════════════════════

class _ClusterTypeCard extends ConsumerWidget {
  const _ClusterTypeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predAsync = ref.watch(predictionProvider);

    return predAsync.when(
      data: (data) {
        Color badgeColor;
        IconData badgeIcon;
        switch (data.clusterType) {
          case 'profitable':
            badgeColor = _kGreen;
            badgeIcon = Icons.rocket_launch_rounded;
            break;
          case 'volatile':
            badgeColor = _kRed;
            badgeIcon = Icons.bolt_rounded;
            break;
          default:
            badgeColor = _kAmber;
            badgeIcon = Icons.balance_rounded;
        }

        return _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardLabel(icon: Icons.category_rounded, label: 'Cluster'),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      data.clusterType.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _GlassCard(child: _ShimmerBlock(height: 80)),
      error: (_, __) => _GlassCard(child: _ErrorContent(message: '—')),
    );
  }
}

// ═══════════════════════════════════════════
// PRICE HISTORY CHART SECTION
// ═══════════════════════════════════════════

class _PriceHistorySection extends ConsumerWidget {
  const _PriceHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predAsync = ref.watch(predictionProvider);

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(icon: Icons.timeline_rounded, label: 'Price History'),
          const SizedBox(height: 12),
          predAsync.when(
            data: (data) => CandleChart(prices: data.priceHistory),
            loading: () => const SizedBox(
              height: 250,
              child: Center(
                child: CircularProgressIndicator(color: _kAccent),
              ),
            ),
            error: (_, __) => const SizedBox(
              height: 250,
              child: Center(
                child: Text(
                  'Chart unavailable',
                  style: TextStyle(color: Colors.white30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// LAST UPDATED ROW
// ═══════════════════════════════════════════

class _LastUpdatedRow extends ConsumerWidget {
  const _LastUpdatedRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predAsync = ref.watch(predictionProvider);
    final ts = predAsync.valueOrNull?.lastUpdated;

    if (ts == null) return const SizedBox.shrink();

    final time =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';

    return Center(
      child: Text(
        'Last updated $time',
        style: GoogleFonts.inter(
          fontSize: 11,
          color: Colors.white24,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.candlestick_chart_outlined,
            size: 64,
            color: _kAccent.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Search and select a stock\nto begin real-time analysis',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white30,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CardLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kAccent, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0x66FFFFFF),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _GlowButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GlowButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = _kAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool animate;
  const _PulsingDot({required this.color, this.animate = true});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.animate) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.animate && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: widget.animate
              ? [
                  BoxShadow(
                    color:
                        widget.color.withValues(alpha: 0.3 + _ctrl.value * 0.4),
                    blurRadius: 4 + _ctrl.value * 6,
                    spreadRadius: _ctrl.value * 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double height;
  const _ShimmerBlock({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.03),
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  const _ErrorContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white30,
        ),
      ),
    );
  }
}