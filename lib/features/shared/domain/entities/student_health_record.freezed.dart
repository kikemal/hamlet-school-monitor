// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_health_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentHealthRecord {

 String get id; String get studentId; String? get bloodGroup; String? get allergies; String? get medicalConditions; String? get emergencyNotes;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of StudentHealthRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentHealthRecordCopyWith<StudentHealthRecord> get copyWith => _$StudentHealthRecordCopyWithImpl<StudentHealthRecord>(this as StudentHealthRecord, _$identity);

  /// Serializes this StudentHealthRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentHealthRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.bloodGroup, bloodGroup) || other.bloodGroup == bloodGroup)&&(identical(other.allergies, allergies) || other.allergies == allergies)&&(identical(other.medicalConditions, medicalConditions) || other.medicalConditions == medicalConditions)&&(identical(other.emergencyNotes, emergencyNotes) || other.emergencyNotes == emergencyNotes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,bloodGroup,allergies,medicalConditions,emergencyNotes,createdAt,updatedAt);

@override
String toString() {
  return 'StudentHealthRecord(id: $id, studentId: $studentId, bloodGroup: $bloodGroup, allergies: $allergies, medicalConditions: $medicalConditions, emergencyNotes: $emergencyNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StudentHealthRecordCopyWith<$Res>  {
  factory $StudentHealthRecordCopyWith(StudentHealthRecord value, $Res Function(StudentHealthRecord) _then) = _$StudentHealthRecordCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String? bloodGroup, String? allergies, String? medicalConditions, String? emergencyNotes,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$StudentHealthRecordCopyWithImpl<$Res>
    implements $StudentHealthRecordCopyWith<$Res> {
  _$StudentHealthRecordCopyWithImpl(this._self, this._then);

  final StudentHealthRecord _self;
  final $Res Function(StudentHealthRecord) _then;

/// Create a copy of StudentHealthRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? bloodGroup = freezed,Object? allergies = freezed,Object? medicalConditions = freezed,Object? emergencyNotes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,bloodGroup: freezed == bloodGroup ? _self.bloodGroup : bloodGroup // ignore: cast_nullable_to_non_nullable
as String?,allergies: freezed == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as String?,medicalConditions: freezed == medicalConditions ? _self.medicalConditions : medicalConditions // ignore: cast_nullable_to_non_nullable
as String?,emergencyNotes: freezed == emergencyNotes ? _self.emergencyNotes : emergencyNotes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentHealthRecord].
extension StudentHealthRecordPatterns on StudentHealthRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentHealthRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentHealthRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentHealthRecord value)  $default,){
final _that = this;
switch (_that) {
case _StudentHealthRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentHealthRecord value)?  $default,){
final _that = this;
switch (_that) {
case _StudentHealthRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String? bloodGroup,  String? allergies,  String? medicalConditions,  String? emergencyNotes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentHealthRecord() when $default != null:
return $default(_that.id,_that.studentId,_that.bloodGroup,_that.allergies,_that.medicalConditions,_that.emergencyNotes,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String? bloodGroup,  String? allergies,  String? medicalConditions,  String? emergencyNotes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StudentHealthRecord():
return $default(_that.id,_that.studentId,_that.bloodGroup,_that.allergies,_that.medicalConditions,_that.emergencyNotes,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String? bloodGroup,  String? allergies,  String? medicalConditions,  String? emergencyNotes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StudentHealthRecord() when $default != null:
return $default(_that.id,_that.studentId,_that.bloodGroup,_that.allergies,_that.medicalConditions,_that.emergencyNotes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentHealthRecord implements StudentHealthRecord {
  const _StudentHealthRecord({required this.id, required this.studentId, this.bloodGroup, this.allergies, this.medicalConditions, this.emergencyNotes, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _StudentHealthRecord.fromJson(Map<String, dynamic> json) => _$StudentHealthRecordFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String? bloodGroup;
@override final  String? allergies;
@override final  String? medicalConditions;
@override final  String? emergencyNotes;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of StudentHealthRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentHealthRecordCopyWith<_StudentHealthRecord> get copyWith => __$StudentHealthRecordCopyWithImpl<_StudentHealthRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentHealthRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentHealthRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.bloodGroup, bloodGroup) || other.bloodGroup == bloodGroup)&&(identical(other.allergies, allergies) || other.allergies == allergies)&&(identical(other.medicalConditions, medicalConditions) || other.medicalConditions == medicalConditions)&&(identical(other.emergencyNotes, emergencyNotes) || other.emergencyNotes == emergencyNotes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,bloodGroup,allergies,medicalConditions,emergencyNotes,createdAt,updatedAt);

@override
String toString() {
  return 'StudentHealthRecord(id: $id, studentId: $studentId, bloodGroup: $bloodGroup, allergies: $allergies, medicalConditions: $medicalConditions, emergencyNotes: $emergencyNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StudentHealthRecordCopyWith<$Res> implements $StudentHealthRecordCopyWith<$Res> {
  factory _$StudentHealthRecordCopyWith(_StudentHealthRecord value, $Res Function(_StudentHealthRecord) _then) = __$StudentHealthRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String? bloodGroup, String? allergies, String? medicalConditions, String? emergencyNotes,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$StudentHealthRecordCopyWithImpl<$Res>
    implements _$StudentHealthRecordCopyWith<$Res> {
  __$StudentHealthRecordCopyWithImpl(this._self, this._then);

  final _StudentHealthRecord _self;
  final $Res Function(_StudentHealthRecord) _then;

/// Create a copy of StudentHealthRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? bloodGroup = freezed,Object? allergies = freezed,Object? medicalConditions = freezed,Object? emergencyNotes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_StudentHealthRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,bloodGroup: freezed == bloodGroup ? _self.bloodGroup : bloodGroup // ignore: cast_nullable_to_non_nullable
as String?,allergies: freezed == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as String?,medicalConditions: freezed == medicalConditions ? _self.medicalConditions : medicalConditions // ignore: cast_nullable_to_non_nullable
as String?,emergencyNotes: freezed == emergencyNotes ? _self.emergencyNotes : emergencyNotes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
