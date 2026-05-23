import 'package:freezed_annotation/freezed_annotation.dart';

part 'fee_payment.freezed.dart';
part 'fee_payment.g.dart';

@freezed
abstract class FeePayment with _$FeePayment {
  const factory FeePayment({
    required String id,
    required String feeId,
    required String parentId,
    required double amountPaid,
    required DateTime paymentDate,
    String? paymentMethod,
    required String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _FeePayment;

  factory FeePayment.fromJson(Map<String, dynamic> json) => _$FeePaymentFromJson(json);
}
