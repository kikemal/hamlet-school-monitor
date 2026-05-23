import 'package:freezed_annotation/freezed_annotation.dart';

part 'behaviour_log.freezed.dart';
part 'behaviour_log.g.dart';

@freezed
abstract class BehaviourLog with _$BehaviourLog {
  const factory BehaviourLog({
    required String id,
    required String studentId,
    required String teacherId,
    required String incidentType,
    required String description,
    required DateTime date,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BehaviourLog;

  factory BehaviourLog.fromJson(Map<String, dynamic> json) => _$BehaviourLogFromJson(json);
}
