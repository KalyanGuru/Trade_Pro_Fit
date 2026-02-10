// server/lib/config.dart
import 'dart:io';
import 'package:dotenv/dotenv.dart' as dotenv;

class Config {
  static final _env = dotenv.DotEnv(includePlatformEnvironment: true)..load();

  static final upstoxClientId = _env['UPSTOX_CLIENT_ID']?.trim() ?? '';
  static final redirectUri    = _env['UPSTOX_REDIRECT_URI']?.trim() ?? 'http://localhost:8080/auth/callback';
  static final scopes         = _env['UPSTOX_SCOPES']?.trim() ?? 'market.full';
  static final upstoxBase     = _env['UPSTOX_BASE']?.trim() ?? 'https://api.upstox.com/v2';
  static final upstoxWs       = _env['UPSTOX_WS']?.trim() ?? '';
  static final port           = int.tryParse(_env['PORT'] ?? '8080') ?? 8080;



  /// Call at application startup to load and validate .env values.


  static void _validateAndPrint() {
    stderr.writeln('=== Upstox server config ===');

    if (upstoxClientId.isEmpty) {
      stderr.writeln('ERROR: UPSTOX_CLIENT_ID is missing in .env. Add your API Key (Client ID).');
      // don't exit here — let the server start for dev, but warn loudly.
    } else {
      stdout.writeln('UPSTOX_CLIENT_ID: ${upstoxClientId.substring(0, 8)}... (hidden tail)');
    }

    stdout.writeln('UPSTOX_REDIRECT_URI: $redirectUri');
    stdout.writeln('UPSTOX_SCOPES: $scopes');
    stdout.writeln('UPSTOX_BASE: $upstoxBase');
    stdout.writeln('UPSTOX_WS: ${upstoxWs.isEmpty ? "(not set)" : upstoxWs}');
    stdout.writeln('PORT: $port');

    // Basic redirect URI sanity checks
    try {
      final uri = Uri.parse(redirectUri);
      if (!(uri.scheme == 'http' || uri.scheme == 'https')) {
        stderr.writeln('WARNING: redirect uri scheme should be http or https.');
      }
      if (uri.path.isEmpty || !uri.path.contains('/auth')) {
        stderr.writeln('WARNING: redirect uri path looks unusual. Use "/auth/callback".');
      }
    } catch (e) {
      stderr.writeln('WARNING: redirect uri parse error: $e');
    }

    stdout.writeln('=== End config ===\n');
  }
}
