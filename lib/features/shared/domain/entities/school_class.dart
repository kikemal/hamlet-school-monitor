import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_class.freezed.dart';
part 'school_class.g.dart';

@freezed
abstract class SchoolClass with _$SchoolClass {
  const factory SchoolClass({
    required String id,
    required String schoolId,
    required String name,
    String? teacherId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SchoolClass;

  factory SchoolClass.fromJson(Map<String, dynamic> json) => _$SchoolClassFromJson(json);
}
