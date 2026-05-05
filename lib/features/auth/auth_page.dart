import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool openingLogin = false;

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
    timer?.cancel();

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

  Future<void> openLoginInBrowser() async {
    setState(() {
      openingLogin = true;
    });

    final ok = await launchUrl(
      Uri.parse(api.authUrl),
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );

    if (!mounted) return;

    setState(() {
      openingLogin = false;
    });

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open Kite login',
            style: GoogleFonts.inter(),
          ),
        ),
      );
    }
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
        title: Text(
          'Kite Login',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: checking
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C5CE7),
              ),
            )

          // =====================================
          // IF CONNECTED ALREADY
          // =====================================
          : connected
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00E676).withValues(alpha: 0.1),
                          border: Border.all(
                            color: const Color(0xFF00E676).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF00E676),
                          size: 52,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Kite Connected',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00E676),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your trading session is active',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Continue'),
                      ),
                    ],
                  ),
                )

              // =====================================
              // LOGIN
              // =====================================
              : kIsWeb
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF6C5CE7)
                                    .withValues(alpha: 0.1),
                              ),
                              child: const Icon(
                                Icons.open_in_new_rounded,
                                size: 36,
                                color: Color(0xFF6C5CE7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Connect to Kite',
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Authenticate with Zerodha Kite\nto start live trading data.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white38,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed:
                                  openingLogin ? null : openLoginInBrowser,
                              icon: openingLogin
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white54,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: const Text('Continue with Kite'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(api.authUrl),
                      ),
                    ),
    );
  }
}