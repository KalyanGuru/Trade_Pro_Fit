class Env {
  static const backendBase = String.fromEnvironment(
    'BACKEND_BASE',
    defaultValue: 'http://localhost:8080',
  );
}