import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/api_client.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final ApiClient api = ApiClient();

  Future<void> connect() async {
    final uri = Uri.parse(api.authUrl);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect Upstox"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: connect,
          child: const Text("Connect Now"),
        ),
      ),
    );
  }
}