import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../data/api_client.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final ApiClient api = ApiClient();

  @override
  Widget build(BuildContext context) {
    final String loginUrl = api.authUrl.startsWith('http')
        ? api.authUrl
        : 'http://localhost:8080/auth/login';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Upstox'),
        centerTitle: true,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(loginUrl),
        ),

        onLoadStop: (controller, url) async {
          final currentUrl = url.toString();

          /// Success callback from backend
          if (currentUrl.contains('/auth/callback')) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upstox Connected Successfully'),
                ),
              );

              Navigator.pop(context, true);
            }
          }

          /// If backend root page opens accidentally
          if (currentUrl == 'http://localhost:8080/' ||
              currentUrl == 'http://127.0.0.1:8080/') {
            await controller.loadUrl(
              urlRequest: URLRequest(
                url: WebUri('http://localhost:8080/auth/login'),
              ),
            );
          }
        },

        onReceivedError: (controller, request, error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Connection Failed: ${error.description}',
                ),
              ),
            );
          }
        },

        onReceivedHttpError: (controller, request, response) {
          if (response.statusCode == 404) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Backend route not found'),
              ),
            );
          }
        },
      ),
    );
  }
}