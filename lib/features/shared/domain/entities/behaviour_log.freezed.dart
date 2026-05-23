// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'behaviour_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BehaviourLog {

 String get id; String get studentId; String get teacherId; String get incidentType; String get description; DateTime get date;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of BehaviourLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BehaviourLogCopyWith<BehaviourLog> get copyWith => _$BehaviourLogCopyWithImpl<BehaviourLog>(this as BehaviourLog, _$identity);

  /// Serializes this BehaviourLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BehaviourLog&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.teacherId, teacherId) || other.teacherId == teacherId)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.description, description) || other.description == description)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,teacherId,incidentType,description,date,createdAt,updatedAt);

@override
String toString() {
  return 'BehaviourLog(id: $id, studentId: $studentId, teacherId: $teacherId, incidentType: $incidentType, description: $description, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BehaviourLogCopyWith<$Res>  {
  factory $BehaviourLogCopyWith(BehaviourLog value, $Res Function(BehaviourLog) _then) = _$BehaviourLogCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String teacherId, String incidentType, String description, DateTime date,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$BehaviourLogCopyWithImpl<$Res>
    implements $BehaviourLogCopyWith<$Res> {
  _$BehaviourLogCopyWithImpl(this._self, this._then);

  final BehaviourLog _self;
  final $Res Function(BehaviourLog) _then;

/// Create a copy of BehaviourLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? teacherId = null,Object? incidentType = null,Object? description = null,Object? date = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,teacherId: null == teacherId ? _self.teacherId : teacherId // ignore: cast_nullable_to_non_nullable
as String,incidentType: null == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BehaviourLog].
extension BehaviourLogPatterns on BehaviourLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BehaviourLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BehaviourLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BehaviourLog value)  $default,){
final _that = this;
switch (_that) {
case _BehaviourLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BehaviourLog value)?  $default,){
final _that = this;
switch (_that) {
case _BehaviourLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String teacherId,  String incidentType,  String description,  DateTime date, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BehaviourLog() when $default != null:
return $default(_that.id,_that.studentId,_that.teacherId,_that.incidentType,_that.description,_that.date,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String teacherId,  String incidentType,  String description,  DateTime date, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BehaviourLog():
return $default(_that.id,_that.studentId,_that.teacherId,_that.incidentType,_that.description,_that.date,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String teacherId,  String incidentType,  String description,  DateTime date, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BehaviourLog() when $default != null:
return $default(_that.id,_that.studentId,_that.teacherId,_that.incidentType,_that.description,_that.date,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BehaviourLog implements BehaviourLog {
  const _BehaviourLog({required this.id, required this.studentId, required this.teacherId, required this.incidentType, required this.description, required this.date, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _BehaviourLog.fromJson(Map<String, dynamic> json) => _$BehaviourLogFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String teacherId;
@override final  String incidentType;
@override final  String description;
@override final  DateTime date;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of BehaviourLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BehaviourLogCopyWith<_BehaviourLog> get copyWith => __$BehaviourLogCopyWithImpl<_BehaviourLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BehaviourLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BehaviourLog&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.teacherId, teacherId) || other.teacherId == teacherId)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.description, description) || other.description == description)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,teacherId,incidentType,description,date,createdAt,updatedAt);

@override
String toString() {
  return 'BehaviourLog(id: $id, studentId: $studentId, teacherId: $teacherId, incidentType: $incidentType, description: $description, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BehaviourLogCopyWith<$Res> implements $BehaviourLogCopyWith<$Res> {
  factory _$BehaviourLogCopyWith(_BehaviourLog value, $Res Function(_BehaviourLog) _then) = __$BehaviourLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String teacherId, String incidentType, String description, DateTime date,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$BehaviourLogCopyWithImpl<$Res>
    implements _$BehaviourLogCopyWith<$Res> {
  __$BehaviourLogCopyWithImpl(this._self, this._then);

  final _BehaviourLog _self;
  final $Res Function(_BehaviourLog) _then;

/// Create a copy of BehaviourLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? teacherId = null,Object? incidentType = null,Object? description = null,Object? date = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_BehaviourLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,teacherId: null == teacherId ? _self.teacherId : teacherId // ignore: cast_nullable_to_non_nullable
as String,incidentType: null == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
