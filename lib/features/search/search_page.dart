import 'package:flutter/material.dart';
import '../../data/api_client.dart';
import '../../data/models.dart';

class SearchPage extends StatefulWidget {
  final void Function(Instrument) onPick;
  const SearchPage({super.key, required this.onPick});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ctrl = TextEditingController();
  final api = ApiClient();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: ctrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by symbol')),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final results = await api.searchInstruments(ctrl.text.trim());
            showModalBottomSheet(context: context, builder: (_) {
              return ListView(
                children: results.map((e) {
                  final ins = Instrument.fromJson(e);
                  return ListTile(
                    title: Text(ins.symbol),
                    subtitle: Text(ins.name),
                    onTap: () { Navigator.pop(context); widget.onPick(ins); },
                  );
                }).toList(),
              );
            });
          },
          child: const Text('Search'),
        ),
      ],
    );
  }
}
