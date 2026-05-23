import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_health_record.freezed.dart';
part 'student_health_record.g.dart';

@freezed
abstract class StudentHealthRecord with _$StudentHealthRecord {
  const factory StudentHealthRecord({
    required String id,
    required String studentId,
    String? bloodGroup,
    String? allergies,
    String? medicalConditions,
    String? emergencyNotes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _StudentHealthRecord;

  factory StudentHealthRecord.fromJson(Map<String, dynamic> json) => _$StudentHealthRecordFromJson(json);
}
