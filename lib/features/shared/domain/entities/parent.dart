import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent.freezed.dart';
part 'parent.g.dart';

@freezed
abstract class Parent with _$Parent {
  const factory Parent({
    required String id,
    String? address,
    String? emergencyContact,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Parent;

  factory Parent.fromJson(Map<String, dynamic> json) => _$ParentFromJson(json);
}
