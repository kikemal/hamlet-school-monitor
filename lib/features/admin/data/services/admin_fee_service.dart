import '../../../shared/domain/entities/fee.dart';
import '../../../shared/domain/entities/fee_payment.dart';
import '../../domain/models/admin_models.dart';
import 'admin_service_base.dart';

class AdminFeeService extends AdminServiceBase {
  Future<List<FeeWithStatus>> fetchFees(String schoolId) async {
    final rows = await supabaseClient
        .from('fees')
        .select('*, fee_payments(amount_paid, status)')
        .eq('school_id', schoolId)
        .order('due_date', ascending: false);

    return rows.map((row) {
      final map = mapRow(row);
      final payments = map['fee_payments'] as List? ?? [];
      var totalPaid = 0.0;
      var latestStatus = 'pending';
      for (final p in payments) {
        final payment = p as Map;
        totalPaid += (payment['amount_paid'] as num).toDouble();
        latestStatus = payment['status'] as String? ?? latestStatus;
      }
      return FeeWithStatus(
        fee: Fee.fromJson(map),
        totalPaid: totalPaid,
        paymentCount: payments.length,
        latestStatus: latestStatus,
      );
    }).toList();
  }

  Future<List<FeePaymentListItem>> fetchPayments(String schoolId) async {
    final rows = await supabaseClient
        .from('fee_payments')
        .select(
          '*, fees!inner(description, school_id), parents(id, profiles(first_name, last_name))',
        )
        .eq('fees.school_id', schoolId);

    return rows.map((row) {
      final map = mapRow(row);
      final fee = map['fees'] as Map;
      final parent = map['parents'] as Map;
      final profile = parent['profiles'] as Map;
      return FeePaymentListItem(
        payment: FeePayment.fromJson(map),
        feeDescription: fee['description'] as String,
        parentName: '${profile['first_name']} ${profile['last_name']}',
      );
    }).toList();
  }

  Future<Fee> createFee({
    required String schoolId,
    required double amount,
    required String description,
    required DateTime dueDate,
    String? classId,
    String? studentId,
  }) async {
    final row = await supabaseClient
        .from('fees')
        .insert({
          'school_id': schoolId,
          'amount': amount,
          'description': description,
          'due_date': dueDate.toIso8601String().split('T').first,
          if (classId != null) 'class_id': classId,
          if (studentId != null) 'student_id': studentId,
        })
        .select()
        .single();
    return Fee.fromJson(mapRow(row));
  }

  Future<Fee> updateFee({
    required String id,
    required double amount,
    required String description,
    required DateTime dueDate,
    String? classId,
    String? studentId,
  }) async {
    final row = await supabaseClient
        .from('fees')
        .update({
          'amount': amount,
          'description': description,
          'due_date': dueDate.toIso8601String().split('T').first,
          'class_id': classId,
          'student_id': studentId,
        })
        .eq('id', id)
        .select()
        .single();
    return Fee.fromJson(mapRow(row));
  }

  Future<void> deleteFee(String id) async {
    await supabaseClient.from('fees').delete().eq('id', id);
  }

  Future<FeePayment> recordPayment({
    required String feeId,
    required String parentId,
    required double amountPaid,
    required String status,
    String? paymentMethod,
  }) async {
    final row = await supabaseClient
        .from('fee_payments')
        .insert({
          'fee_id': feeId,
          'parent_id': parentId,
          'amount_paid': amountPaid,
          'status': status,
          if (paymentMethod != null) 'payment_method': paymentMethod,
        })
        .select()
        .single();
    return FeePayment.fromJson(mapRow(row));
  }
}
