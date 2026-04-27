import 'package:flutter/material.dart';
import '../../data/api_client.dart';

class ClusterPage extends StatefulWidget {
  const ClusterPage({super.key});

  @override
  State<ClusterPage> createState() => _ClusterPageState();
}

class _ClusterPageState extends State<ClusterPage> {
  final api = ApiClient();

  List<Map<String, dynamic>> clusters = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadClusters();
  }

  Future<void> loadClusters() async {
    try {
      final data = await api.getClusters();

      setState(() {
        clusters = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Color getColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (clusters.isEmpty) {
      return const Center(
        child: Text("No cluster data"),
      );
    }

    return ListView.builder(
      itemCount: clusters.length,
      itemBuilder: (context, index) {
        final item = clusters[index];

        final cluster =
            item['cluster']?.toString() ?? '';

        final strength =
            item['strength']?.toString() ?? '';

        final stocks =
        List<String>.from(item['stocks'] ?? []);

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  cluster,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Strength: $strength",
                  style: TextStyle(
                    color: getColor(strength),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: stocks
                      .map(
                        (e) => Chip(
                      label: Text(e),
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}