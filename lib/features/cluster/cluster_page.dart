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

  Future<void> _load() async {
    final r = await api.getClusters();
    setState(() => clusters = r);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: clusters.length,
        itemBuilder: (_, i) {
          final r = clusters[i];
          return ListTile(
            title: Text(r['instrument_key']),
            subtitle: Text('Label: ${r['label']}  —  ts: ${r['ts']}'),
          );
        },
      ),
    );
  }
}
