import 'package:freezed_annotation/freezed_annotation.dart';

part 'homework.freezed.dart';
part 'homework.g.dart';

@freezed
abstract class Homework with _$Homework {
  const factory Homework({
    required String id,
    required String classId,
    required String subjectId,
    required String teacherId,
    required String title,
    String? description,
    required DateTime dueDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Homework;

  factory Homework.fromJson(Map<String, dynamic> json) => _$HomeworkFromJson(json);
}
