import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/models.dart';
import '../search/search_page.dart';
import '../auth/auth_page.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  final api = ApiClient();

  Instrument? picked;

  Timer? timer;

  double ltp = 0.0;
  String trend = "-";
  int confidence = 0;

  List<double> priceHistory = [];

  // -----------------------------------
  // START AUTO REFRESH
  // -----------------------------------
  void startLive() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => loadData(),
    );

    loadData();
  }

  // -----------------------------------
  // LOAD LIVE + PREDICTION
  // -----------------------------------
  Future<void> loadData() async {
    if (picked == null) return;

    try {
      final live =
      await api.getLivePrice(picked!.key);

      final pred =
      await api.getPrediction(picked!.key);

      setState(() {
        ltp =
            (live['ltp'] as num)
                .toDouble();

        trend =
            pred['trend']
                ?.toString() ??
                '-';

        confidence =
            pred['confidence'] ?? 0;

        priceHistory.add(ltp);

        if (priceHistory.length > 30) {
          priceHistory.removeAt(0);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // -----------------------------------
  // UI
  // -----------------------------------
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
      const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
          children: [
            Text(
              picked?.symbol ??
                  'Pick Stock',
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      content:
                      SizedBox(
                        width: 450,
                        child:
                        SearchPage(
                          onPick:
                              (ins) {
                            setState(() {
                              picked =
                                  ins;
                              priceHistory
                                  .clear();
                            });

                            Navigator.pop(
                                context);

                            startLive();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              child:
              const Text(
                  "Search"),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (picked != null) ...[
          Card(
            elevation: 5,
            child: Padding(
              padding:
              const EdgeInsets.all(
                  16),
              child: Column(
                children: [
                  Text(
                    "Live Price",
                    style:
                    TextStyle(
                      fontSize:
                      18,
                      color: Colors
                          .grey[700],
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Text(
                    "₹ ${ltp.toStringAsFixed(2)}",
                    style:
                    const TextStyle(
                      fontSize:
                      32,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            elevation: 5,
            child: Padding(
              padding:
              const EdgeInsets.all(
                  16),
              child: Column(
                children: [
                  const Text(
                    "Next 1 Hour Prediction",
                    style:
                    TextStyle(
                      fontSize:
                      18,
                    ),
                  ),

                  const SizedBox(
                      height: 12),

                  Text(
                    trend,
                    style:
                    TextStyle(
                      fontSize:
                      28,
                      fontWeight:
                      FontWeight.bold,
                      color: trend ==
                          "UP"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  Text(
                    "Confidence: $confidence%",
                    style:
                    const TextStyle(
                      fontSize:
                      16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(
                  16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  const Text(
                    "Recent Prices",
                    style:
                    TextStyle(
                      fontSize:
                      18,
                    ),
                  ),
                  const SizedBox(
                      height: 10),

                  Text(
                    priceHistory
                        .map((e) => e
                        .toStringAsFixed(
                        1))
                        .join(
                        "  |  "),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const AuthPage(),
              ),
            );
          },
          child: const Text(
              "Connect Upstox"),
        ),
      ],
    );
  }
}