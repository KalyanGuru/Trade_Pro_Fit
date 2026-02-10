import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int idx = 0;
  final pages = const [LivePage(), ClusterPage(), DetailPage()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tread Pro Fit',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Tread Pro Fit')),
        body: pages[idx],
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) => setState(() => idx = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.show_chart), label: 'Live'),
            NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Clusters'),
            NavigationDestination(icon: Icon(Icons.info_outline), label: 'Detail'),
          ],
        ),
      ),
    );
  }
}
