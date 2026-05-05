import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../live/live_providers.dart';

final clustersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final data = await api.getClusters();
  return List<Map<String, dynamic>>.from(data);
});

class ClusterPage extends ConsumerWidget {
  const ClusterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clustersAsync = ref.watch(clustersProvider);

    return clustersAsync.when(
      data: (clusters) {
        if (clusters.isEmpty) {
          return Center(
            child: Text(
              'No cluster data',
              style: GoogleFonts.inter(
                color: Colors.white30,
                fontSize: 15,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clusters.length,
          itemBuilder: (context, index) {
            final item = clusters[index];

            final cluster = item['cluster']?.toString() ?? '';
            final strength = item['strength']?.toString() ?? '';
            final clusterType = item['cluster_type']?.toString() ?? 'neutral';
            final stocks = List<String>.from(item['stocks'] ?? []);

            return _ClusterCard(
              cluster: cluster,
              strength: strength,
              clusterType: clusterType,
              stocks: stocks,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Error loading clusters: $err',
          style: GoogleFonts.inter(color: Colors.white30),
        ),
      ),
    );
  }
}

class _ClusterCard extends StatelessWidget {
  final String cluster;
  final String strength;
  final String clusterType;
  final List<String> stocks;

  const _ClusterCard({
    required this.cluster,
    required this.strength,
    required this.clusterType,
    required this.stocks,
  });

  Color _strengthColor(String s) {
    switch (s.toLowerCase()) {
      case 'high':
        return const Color(0xFF00E676);
      case 'medium':
        return const Color(0xFFFFD740);
      default:
        return const Color(0xFFFF5252);
    }
  }

  Color _typeColor(String t) {
    switch (t) {
      case 'profitable':
        return const Color(0xFF00E676);
      case 'volatile':
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFFFFD740);
    }
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'profitable':
        return Icons.rocket_launch_rounded;
      case 'volatile':
        return Icons.bolt_rounded;
      default:
        return Icons.balance_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sColor = _strengthColor(strength);
    final tColor = _typeColor(clusterType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151528),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_typeIcon(clusterType), color: tColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cluster,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  clusterType.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Strength: ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white38,
                ),
              ),
              Text(
                strength,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: sColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: stocks
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E3A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      e,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}