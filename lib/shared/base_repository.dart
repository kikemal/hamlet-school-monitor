import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/network/supabase_config.dart';

/// Base repository that provides Supabase data access
abstract class BaseRepository {
  final SupabaseClient supabaseClient = SupabaseConfig.client;

  /// Helper to get a specific table
  SupabaseQueryBuilder getTable(String tableName) {
    return supabaseClient.from(tableName);
  }
}
