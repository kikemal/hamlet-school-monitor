import '../../../../core/services/base_service.dart';

abstract class AdminServiceBase extends BaseService {
  Map<String, dynamic> mapRow(dynamic row) =>
      Map<String, dynamic>.from(row as Map);

  List<Map<String, dynamic>> mapRows(List<dynamic> rows) =>
      rows.map((e) => mapRow(e)).toList();
}
