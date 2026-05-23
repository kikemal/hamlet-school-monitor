import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_event.freezed.dart';
part 'school_event.g.dart';

@freezed
abstract class SchoolEvent with _$SchoolEvent {
  const factory SchoolEvent({
    required String id,
    required String schoolId,
    required String title,
    String? description,
    required DateTime eventDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SchoolEvent;

  factory SchoolEvent.fromJson(Map<String, dynamic> json) => _$SchoolEventFromJson(json);
}
