import '../../../../core/network/supabase_config.dart';
import '../../../../core/services/base_service.dart';

class StudentServiceBase extends BaseService {
  Map<String, dynamic> mapRow(dynamic row) =>
      Map<String, dynamic>.from(row as Map);
}