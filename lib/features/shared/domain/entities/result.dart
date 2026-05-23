import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';
part 'result.g.dart';

@freezed
abstract class Result with _$Result {
  const factory Result({
    required String id,
    required String studentId,
    required String subjectId,
    required String examName,
    required double marksObtained,
    required double maxMarks,
    required DateTime date,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}
