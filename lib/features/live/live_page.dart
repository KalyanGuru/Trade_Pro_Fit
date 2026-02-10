import 'package:flutter/material.dart';
import '../../data/api_client.dart';
import '../../data/models.dart';
import '../../data/ws.dart';
import '../../widgets/charts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../search/search_page.dart';
import '../auth/auth_page.dart';

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});
  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  Instrument? picked;
  final prices = <double>[];
  List<double> predCurve = [];
  final api = ApiClient();
  final ws = WsClient();

  void _connect() {
    if (picked == null) return;
    ws.connect([picked!.key], (ticks) {
      if (ticks.isNotEmpty) {
        final t = Tick.fromJson(ticks.first);
        setState(() {
          prices.add(t.ltp);
          if (prices.length > 300) prices.removeAt(0);
        });
      }
    });
    _fetchPred();
  }

  Future<void> _fetchPred() async {
    if (picked == null) return;
    final r = await api.getPrediction(picked!.key);
    final curve = List<double>.from(r['curve']?.map((e) => (e as num).toDouble()) ?? []);
    setState(() { predCurve = curve; });
  }

  @override
  void dispose() {
    ws.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(picked?.symbol ?? 'Pick stock', style: Theme.of(context).textTheme.titleLarge),
          ElevatedButton(onPressed: () async {
            await showDialog(context: context, builder: (_) {
              return AlertDialog(content: SizedBox(width: 400, child: SearchPage(onPick: (ins) {
                setState(() { picked = ins; prices.clear(); predCurve = []; });
                Navigator.pop(context);
                _connect();
              })));
            });
          }, child: const Text('Search')),
          OutlinedButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AuthPage()));
          }, child: const Text('Connect Upstox')),
        ]),
        const SizedBox(height: 12),
        if (prices.isNotEmpty) LineChartSimple(title: 'Live LTP', y: prices),
        const SizedBox(height: 16),
        if (predCurve.isNotEmpty) LineChartSimple(title: 'Predicted 60 min curve', y: predCurve),
      ],
    );
  }
}
