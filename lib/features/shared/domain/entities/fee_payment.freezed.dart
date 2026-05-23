// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeePayment {

 String get id; String get feeId; String get parentId; double get amountPaid; DateTime get paymentDate; String? get paymentMethod; String get status;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of FeePayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeePaymentCopyWith<FeePayment> get copyWith => _$FeePaymentCopyWithImpl<FeePayment>(this as FeePayment, _$identity);

  /// Serializes this FeePayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.feeId, feeId) || other.feeId == feeId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,feeId,parentId,amountPaid,paymentDate,paymentMethod,status,createdAt,updatedAt);

@override
String toString() {
  return 'FeePayment(id: $id, feeId: $feeId, parentId: $parentId, amountPaid: $amountPaid, paymentDate: $paymentDate, paymentMethod: $paymentMethod, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FeePaymentCopyWith<$Res>  {
  factory $FeePaymentCopyWith(FeePayment value, $Res Function(FeePayment) _then) = _$FeePaymentCopyWithImpl;
@useResult
$Res call({
 String id, String feeId, String parentId, double amountPaid, DateTime paymentDate, String? paymentMethod, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$FeePaymentCopyWithImpl<$Res>
    implements $FeePaymentCopyWith<$Res> {
  _$FeePaymentCopyWithImpl(this._self, this._then);

  final FeePayment _self;
  final $Res Function(FeePayment) _then;

/// Create a copy of FeePayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? feeId = null,Object? parentId = null,Object? amountPaid = null,Object? paymentDate = null,Object? paymentMethod = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,feeId: null == feeId ? _self.feeId : feeId // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as double,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeePayment].
extension FeePaymentPatterns on FeePayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeePayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeePayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeePayment value)  $default,){
final _that = this;
switch (_that) {
case _FeePayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeePayment value)?  $default,){
final _that = this;
switch (_that) {
case _FeePayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String feeId,  String parentId,  double amountPaid,  DateTime paymentDate,  String? paymentMethod,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeePayment() when $default != null:
return $default(_that.id,_that.feeId,_that.parentId,_that.amountPaid,_that.paymentDate,_that.paymentMethod,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String feeId,  String parentId,  double amountPaid,  DateTime paymentDate,  String? paymentMethod,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FeePayment():
return $default(_that.id,_that.feeId,_that.parentId,_that.amountPaid,_that.paymentDate,_that.paymentMethod,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String feeId,  String parentId,  double amountPaid,  DateTime paymentDate,  String? paymentMethod,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FeePayment() when $default != null:
return $default(_that.id,_that.feeId,_that.parentId,_that.amountPaid,_that.paymentDate,_that.paymentMethod,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeePayment implements FeePayment {
  const _FeePayment({required this.id, required this.feeId, required this.parentId, required this.amountPaid, required this.paymentDate, this.paymentMethod, required this.status, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _FeePayment.fromJson(Map<String, dynamic> json) => _$FeePaymentFromJson(json);

@override final  String id;
@override final  String feeId;
@override final  String parentId;
@override final  double amountPaid;
@override final  DateTime paymentDate;
@override final  String? paymentMethod;
@override final  String status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of FeePayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeePaymentCopyWith<_FeePayment> get copyWith => __$FeePaymentCopyWithImpl<_FeePayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeePaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.feeId, feeId) || other.feeId == feeId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,feeId,parentId,amountPaid,paymentDate,paymentMethod,status,createdAt,updatedAt);

@override
String toString() {
  return 'FeePayment(id: $id, feeId: $feeId, parentId: $parentId, amountPaid: $amountPaid, paymentDate: $paymentDate, paymentMethod: $paymentMethod, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FeePaymentCopyWith<$Res> implements $FeePaymentCopyWith<$Res> {
  factory _$FeePaymentCopyWith(_FeePayment value, $Res Function(_FeePayment) _then) = __$FeePaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String feeId, String parentId, double amountPaid, DateTime paymentDate, String? paymentMethod, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$FeePaymentCopyWithImpl<$Res>
    implements _$FeePaymentCopyWith<$Res> {
  __$FeePaymentCopyWithImpl(this._self, this._then);

  final _FeePayment _self;
  final $Res Function(_FeePayment) _then;

/// Create a copy of FeePayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? feeId = null,Object? parentId = null,Object? amountPaid = null,Object? paymentDate = null,Object? paymentMethod = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_FeePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,feeId: null == feeId ? _self.feeId : feeId // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as double,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
