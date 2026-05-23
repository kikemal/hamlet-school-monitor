import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable.freezed.dart';
part 'timetable.g.dart';

@freezed
abstract class Timetable with _$Timetable {
  const factory Timetable({
    required String id,
    required String classId,
    required String subjectId,
    required String teacherId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Timetable;

  factory Timetable.fromJson(Map<String, dynamic> json) => _$TimetableFromJson(json);
}
