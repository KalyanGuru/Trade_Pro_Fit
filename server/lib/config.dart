import 'package:dotenv/dotenv.dart';

class Config {
  static late String upstoxClientId;
  static late String upstoxClientSecret;
  static late String redirectUri;
  static late String upstoxBase;
  static late int port;

  static void init() {
    final env = DotEnv()..load();

    upstoxClientId =
        env['UPSTOX_CLIENT_ID'] ??
            'your_client_id';

    upstoxClientSecret =
        env['UPSTOX_CLIENT_SECRET'] ??
            'your_client_secret';

    redirectUri =
        env['UPSTOX_REDIRECT_URI'] ??
            'http://localhost:9090/auth/callback';

    upstoxBase =
        env['UPSTOX_BASE'] ??
            'https://api.upstox.com/v2';

    port =
        int.tryParse(
          env['PORT'] ?? '9090',
        ) ??
            9090;
  }
}