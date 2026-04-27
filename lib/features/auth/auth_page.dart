import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../data/api_client.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final api = ApiClient();

  Timer? timer;

  bool connected = false;
  bool checking = true;

  @override
  void initState() {
    super.initState();

    checkAlreadyConnected();
  }

  // =====================================
  // CHECK IF USER ALREADY CONNECTED
  // =====================================
  Future<void> checkAlreadyConnected() async {
    final ok = await api.isConnected();

    if (!mounted) return;

    if (ok) {
      setState(() {
        connected = true;
        checking = false;
      });
    } else {
      setState(() {
        checking = false;
      });

      startPolling();
    }
  }

  // =====================================
  // CHECK LOGIN STATUS EVERY 2 SEC
  // =====================================
  void startPolling() {
    timer = Timer.periodic(
      const Duration(seconds: 2),
          (_) async {
        final ok = await api.isConnected();

        if (ok && mounted) {
          timer?.cancel();

          setState(() {
            connected = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // =====================================
  // UI
  // =====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upstox Login"),
      ),

      body: checking
          ? const Center(
        child: CircularProgressIndicator(),
      )

      // =====================================
      // IF CONNECTED ALREADY
      // =====================================
          : connected
          ? Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              "Upstox Connected ✅",
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                "Continue",
              ),
            ),
          ],
        ),
      )

      // =====================================
      // LOGIN WEBVIEW
      // =====================================
          : InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(api.authUrl),
        ),
      ),
    );
  }
}