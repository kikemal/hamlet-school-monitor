import 'package:freezed_annotation/freezed_annotation.dart';

part 'fee.freezed.dart';
part 'fee.g.dart';

@freezed
abstract class Fee with _$Fee {
  const factory Fee({
    required String id,
    required String schoolId,
    String? classId,
    String? studentId,
    required double amount,
    required String description,
    required DateTime dueDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Fee;

  factory Fee.fromJson(Map<String, dynamic> json) => _$FeeFromJson(json);
}
