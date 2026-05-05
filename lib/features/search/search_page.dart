import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Instrument> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    if (ctrl.text.trim().isEmpty) return;

    setState(() => _loading = true);

    try {
      final data = await api.searchInstruments(ctrl.text.trim());
      if (!mounted) return;
      setState(() {
        _results = data.map((e) => Instrument.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Search Instruments',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: ctrl,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.search_rounded, color: Colors.white38),
            hintText: 'Search by symbol or name',
            hintStyle: GoogleFonts.inter(color: Colors.white24),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  )
                : null,
          ),
          onSubmitted: (_) => _search(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _search,
            child: const Text('Search'),
          ),
        ),
        const SizedBox(height: 12),
        if (_results.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _results.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1,
              ),
              itemBuilder: (_, i) {
                final ins = _results[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        ins.symbol.isNotEmpty ? ins.symbol[0] : '?',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF6C5CE7),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    ins.symbol,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    ins.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  onTap: () => widget.onPick(ins),
                );
              },
            ),
          ),
        if (_results.isEmpty && !_loading)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Type a symbol and tap Search',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white24,
              ),
            ),
          ),
      ],
    );
  }
}
