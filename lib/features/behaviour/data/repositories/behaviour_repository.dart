import '../services/admin_behaviour_service.dart';
import '../services/behaviour_service.dart';
import '../../domain/models/behaviour_models.dart';

class BehaviourRepository {
  BehaviourRepository({
    BehaviourService? behaviour,
    AdminBehaviourService? admin,
  })  : _behaviour = behaviour ?? BehaviourService(),
        _admin = admin ?? AdminBehaviourService();

  final BehaviourService _behaviour;
  final AdminBehaviourService _admin;

  Future<BehaviourSummary> fetchSummaryForStudent(String studentId) =>
      _behaviour.fetchSummaryForStudent(studentId);

  Future<void> notifyParentOfIncident({
    required String studentId,
    required String severity,
    required String notes,
    required DateTime date,
  }) =>
      _behaviour.notifyParentOfIncident(
        studentId: studentId,
        severity: severity,
        notes: notes,
        date: date,
      );

  Future<List<BehaviourLogDisplayItem>> fetchSchoolLogs(String schoolId) =>
      _admin.fetchSchoolLogs(schoolId);
}
