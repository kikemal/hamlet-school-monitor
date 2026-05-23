import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/constants.dart';

class SupabaseConfig {
  static bool get isConfigured =>
      AppConstants.supabaseUrl.isNotEmpty &&
      AppConstants.supabaseAnonKey.isNotEmpty &&
      Uri.tryParse(AppConstants.supabaseUrl)?.hasScheme == true;

  static Future<void> initialize() async {
    if (!isConfigured) {
      throw const SupabaseConfigException(
        'Supabase URL and anon key are missing. '
        'Run with --dart-define=SUPABASE_URL=... and '
        '--dart-define=SUPABASE_ANON_KEY=...',
      );
    }

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

class SupabaseConfigException implements Exception {
  const SupabaseConfigException(this.message);
  final String message;

  @override
  String toString() => message;
}
