import '../../../../core/services/base_service.dart';

abstract class TeacherServiceBase extends BaseService {
  Map<String, dynamic> mapRow(dynamic row) =>
      Map<String, dynamic>.from(row as Map);
}
