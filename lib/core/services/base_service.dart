import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_config.dart';

/// Base service that provides access to the Supabase client
abstract class BaseService {
  final SupabaseClient supabaseClient = SupabaseConfig.client;
  
  /// Handle standard service errors
  Exception handleError(dynamic error) {
    if (error is PostgrestException) {
      return Exception('Database error: ${error.message}');
    } else if (error is AuthException) {
      return Exception('Authentication error: ${error.message}');
    }
    return Exception('An unexpected error occurred: $error');
  }
}
