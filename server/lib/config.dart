import 'dart:io';
import 'package:dotenv/dotenv.dart';

class Config {
  static late String kiteApiKey;
  static late String kiteApiSecret;
  static late String redirectUri;

  static late int port;

  static void init() {
    // Try loading from explicit path first, then fallback
    final scriptDir = File(Platform.script.toFilePath()).parent.parent;
    final envFile = File('${scriptDir.path}/.env');

    final env = DotEnv();
    if (envFile.existsSync()) {
      env.load(['${scriptDir.path}/.env']);
      print('📄 Loaded .env from: ${envFile.path}');
    } else {
      env.load();
      print('📄 Loaded .env from working directory');
    }

    kiteApiKey = env['KITE_API_KEY'] ?? '';
    kiteApiSecret = env['KITE_API_SECRET'] ?? '';

    print('🔑 API Key: ${kiteApiKey.substring(0, 4)}...');

    redirectUri =
        env['KITE_REDIRECT_URI'] ??
            'http://localhost:9090/auth/callback';

    port = int.tryParse(env['PORT'] ?? '9090') ?? 9090;
  }
}