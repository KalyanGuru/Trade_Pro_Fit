import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../data/api_client.dart';

class AuthPage extends StatelessWidget {
  final api = ApiClient();
  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Upstox')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(api.authUrl)),
        onLoadStop: (c, u) {
          if (u.toString().contains('/auth/callback')) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connected!')));
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
