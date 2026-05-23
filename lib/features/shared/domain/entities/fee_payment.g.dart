// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeePayment _$FeePaymentFromJson(Map<String, dynamic> json) => _FeePayment(
  id: json['id'] as String,
  feeId: json['fee_id'] as String,
  parentId: json['parent_id'] as String,
  amountPaid: (json['amount_paid'] as num).toDouble(),
  paymentDate: DateTime.parse(json['payment_date'] as String),
  paymentMethod: json['payment_method'] as String?,
  status: json['status'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FeePaymentToJson(_FeePayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fee_id': instance.feeId,
      'parent_id': instance.parentId,
      'amount_paid': instance.amountPaid,
      'payment_date': instance.paymentDate.toIso8601String(),
      'payment_method': instance.paymentMethod,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
