// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'homework_submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeworkSubmission {

 String get id; String get homeworkId; String get studentId; String? get submissionText; String? get fileUrl; String get status; double? get gradedMarks;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of HomeworkSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeworkSubmissionCopyWith<HomeworkSubmission> get copyWith => _$HomeworkSubmissionCopyWithImpl<HomeworkSubmission>(this as HomeworkSubmission, _$identity);

  /// Serializes this HomeworkSubmission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeworkSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.homeworkId, homeworkId) || other.homeworkId == homeworkId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.submissionText, submissionText) || other.submissionText == submissionText)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.gradedMarks, gradedMarks) || other.gradedMarks == gradedMarks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,homeworkId,studentId,submissionText,fileUrl,status,gradedMarks,createdAt,updatedAt);

@override
String toString() {
  return 'HomeworkSubmission(id: $id, homeworkId: $homeworkId, studentId: $studentId, submissionText: $submissionText, fileUrl: $fileUrl, status: $status, gradedMarks: $gradedMarks, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HomeworkSubmissionCopyWith<$Res>  {
  factory $HomeworkSubmissionCopyWith(HomeworkSubmission value, $Res Function(HomeworkSubmission) _then) = _$HomeworkSubmissionCopyWithImpl;
@useResult
$Res call({
 String id, String homeworkId, String studentId, String? submissionText, String? fileUrl, String status, double? gradedMarks,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$HomeworkSubmissionCopyWithImpl<$Res>
    implements $HomeworkSubmissionCopyWith<$Res> {
  _$HomeworkSubmissionCopyWithImpl(this._self, this._then);

  final HomeworkSubmission _self;
  final $Res Function(HomeworkSubmission) _then;

/// Create a copy of HomeworkSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? homeworkId = null,Object? studentId = null,Object? submissionText = freezed,Object? fileUrl = freezed,Object? status = null,Object? gradedMarks = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,homeworkId: null == homeworkId ? _self.homeworkId : homeworkId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,submissionText: freezed == submissionText ? _self.submissionText : submissionText // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,gradedMarks: freezed == gradedMarks ? _self.gradedMarks : gradedMarks // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeworkSubmission].
extension HomeworkSubmissionPatterns on HomeworkSubmission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeworkSubmission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeworkSubmission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeworkSubmission value)  $default,){
final _that = this;
switch (_that) {
case _HomeworkSubmission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeworkSubmission value)?  $default,){
final _that = this;
switch (_that) {
case _HomeworkSubmission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String homeworkId,  String studentId,  String? submissionText,  String? fileUrl,  String status,  double? gradedMarks, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeworkSubmission() when $default != null:
return $default(_that.id,_that.homeworkId,_that.studentId,_that.submissionText,_that.fileUrl,_that.status,_that.gradedMarks,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String homeworkId,  String studentId,  String? submissionText,  String? fileUrl,  String status,  double? gradedMarks, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _HomeworkSubmission():
return $default(_that.id,_that.homeworkId,_that.studentId,_that.submissionText,_that.fileUrl,_that.status,_that.gradedMarks,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String homeworkId,  String studentId,  String? submissionText,  String? fileUrl,  String status,  double? gradedMarks, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HomeworkSubmission() when $default != null:
return $default(_that.id,_that.homeworkId,_that.studentId,_that.submissionText,_that.fileUrl,_that.status,_that.gradedMarks,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeworkSubmission implements HomeworkSubmission {
  const _HomeworkSubmission({required this.id, required this.homeworkId, required this.studentId, this.submissionText, this.fileUrl, required this.status, this.gradedMarks, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _HomeworkSubmission.fromJson(Map<String, dynamic> json) => _$HomeworkSubmissionFromJson(json);

@override final  String id;
@override final  String homeworkId;
@override final  String studentId;
@override final  String? submissionText;
@override final  String? fileUrl;
@override final  String status;
@override final  double? gradedMarks;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of HomeworkSubmission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeworkSubmissionCopyWith<_HomeworkSubmission> get copyWith => __$HomeworkSubmissionCopyWithImpl<_HomeworkSubmission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeworkSubmissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeworkSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.homeworkId, homeworkId) || other.homeworkId == homeworkId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.submissionText, submissionText) || other.submissionText == submissionText)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.gradedMarks, gradedMarks) || other.gradedMarks == gradedMarks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,homeworkId,studentId,submissionText,fileUrl,status,gradedMarks,createdAt,updatedAt);

@override
String toString() {
  return 'HomeworkSubmission(id: $id, homeworkId: $homeworkId, studentId: $studentId, submissionText: $submissionText, fileUrl: $fileUrl, status: $status, gradedMarks: $gradedMarks, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HomeworkSubmissionCopyWith<$Res> implements $HomeworkSubmissionCopyWith<$Res> {
  factory _$HomeworkSubmissionCopyWith(_HomeworkSubmission value, $Res Function(_HomeworkSubmission) _then) = __$HomeworkSubmissionCopyWithImpl;
@override @useResult
$Res call({
 String id, String homeworkId, String studentId, String? submissionText, String? fileUrl, String status, double? gradedMarks,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$HomeworkSubmissionCopyWithImpl<$Res>
    implements _$HomeworkSubmissionCopyWith<$Res> {
  __$HomeworkSubmissionCopyWithImpl(this._self, this._then);

  final _HomeworkSubmission _self;
  final $Res Function(_HomeworkSubmission) _then;

/// Create a copy of HomeworkSubmission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? homeworkId = null,Object? studentId = null,Object? submissionText = freezed,Object? fileUrl = freezed,Object? status = null,Object? gradedMarks = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_HomeworkSubmission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,homeworkId: null == homeworkId ? _self.homeworkId : homeworkId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,submissionText: freezed == submissionText ? _self.submissionText : submissionText // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,gradedMarks: freezed == gradedMarks ? _self.gradedMarks : gradedMarks // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
