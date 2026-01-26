import 'package:flutter_dotenv/flutter_dotenv.dart';

// For Emulator use 10.0.2.2. For Physical Device use 192.168.1.X
// Configured in assets/.env
String get baseURL => dotenv.env['API_BASE_URL'] ?? "http://10.0.2.2:8000/api/v1";

// Helper to get the root URL (e.g. for images)
String get rootBaseURL {
  final base = baseURL;
  if (base.endsWith('/api/v1')) {
    return base.replaceAll('/api/v1', '');
  }
  if (base.endsWith('/api/v1/')) {
    return base.replaceAll('/api/v1/', '');
  }
  return base;
}

const Map<String, String> headers = {
  "Accept": "application/json",
  "Content-Type": "application/json"
};

