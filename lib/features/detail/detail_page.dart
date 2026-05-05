import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../live/live_providers.dart';
import '../../widgets/charts.dart';

const _kCardBg = Color(0xFF151528);
const _kCardBorder = Color(0x10FFFFFF);

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picked = ref.watch(selectedInstrumentProvider);
    final metricsAsync = ref.watch(metricsProvider);

    if (picked == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a stock on the Live tab\nto view ML analytics.',
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

    return metricsAsync.when(
      data: (metrics) {
        if (metrics.predictions.isEmpty && metrics.maeHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Collecting predictions for ${picked.symbol}...\nData will appear as predictions resolve.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final actualPrices = metrics.predictions.map((p) => p.actual).toList();
        final predictedPrices = metrics.predictions.map((p) => p.predicted).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              '${picked.symbol} Analytics',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            // ─── KPI CARDS ───
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    title: 'Current MAE',
                    value: metrics.mae.toStringAsFixed(4),
                    icon: Icons.error_outline_rounded,
                    color: const Color(0xFFFFD740),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiCard(
                    title: 'Current RMSE',
                    value: metrics.rmse.toStringAsFixed(4),
                    icon: Icons.ssid_chart_rounded,
                    color: const Color(0xFFFF5252),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── ACTUAL VS PREDICTED CHART ───
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: Icons.compare_arrows_rounded,
                    title: 'Actual vs Predicted Price',
                  ),
                  const SizedBox(height: 16),
                  PredictionVsActualChart(
                    actualPrices: actualPrices,
                    predictedPrices: predictedPrices,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── MAE CHART ───
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: Icons.timeline_rounded,
                    title: 'Mean Absolute Error (Rolling)',
                  ),
                  const SizedBox(height: 16),
                  MAEChart(history: metrics.maeHistory),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── RMSE CHART ───
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: Icons.show_chart_rounded,
                    title: 'Root Mean Square Error (Rolling)',
                  ),
                  const SizedBox(height: 16),
                  RMSEChart(history: metrics.rmseHistory),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
      ),
      error: (err, _) => Center(
        child: Text(
          'Error loading analytics: $err',
          style: GoogleFonts.inter(color: Colors.white30),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C5CE7), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

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
