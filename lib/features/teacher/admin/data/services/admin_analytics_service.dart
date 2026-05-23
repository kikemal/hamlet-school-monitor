import '../../domain/models/admin_models.dart';
import 'admin_service_base.dart';

class AdminAnalyticsService extends AdminServiceBase {
  Future<List<ClassPerformance>> fetchClassPerformance(String schoolId) async {
    final classes = await supabaseClient
        .from('classes')
        .select('id, name, students(id)')
        .eq('school_id', schoolId);

    final results = await supabaseClient
        .from('results')
        .select('marks_obtained, max_marks, students!inner(id, class_id, school_id)')
        .eq('students.school_id', schoolId);

    final classMap = <String, ClassPerformance>{};

    for (final c in classes) {
      final map = mapRow(c);
      classMap[map['id'] as String] = ClassPerformance(
        classId: map['id'] as String,
        className: map['name'] as String,
        averagePercentage: 0,
        studentCount: (map['students'] as List?)?.length ?? 0,
      );
    }

    final sums = <String, List<double>>{};
    for (final r in results) {
      final map = mapRow(r);
      final student = map['students'] as Map;
      final classId = student['class_id'] as String?;
      if (classId == null) continue;
      final max = (map['max_marks'] as num).toDouble();
      if (max <= 0) continue;
      final pct = ((map['marks_obtained'] as num).toDouble() / max) * 100;
      sums.putIfAbsent(classId, () => []).add(pct);
    }

    return classMap.entries.map((e) {
      final scores = sums[e.key] ?? [];
      final avg = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;
      return ClassPerformance(
        classId: e.value.classId,
        className: e.value.className,
        averagePercentage: avg,
        studentCount: e.value.studentCount,
      );
    }).toList()
      ..sort((a, b) => b.averagePercentage.compareTo(a.averagePercentage));
  }

  Future<List<SubjectTrend>> fetchSubjectTrends(String schoolId) async {
    final subjects = await supabaseClient
        .from('subjects')
        .select('id, name')
        .eq('school_id', schoolId);

    final results = await supabaseClient
        .from('results')
        .select('marks_obtained, max_marks, subject_id, students!inner(school_id)')
        .eq('students.school_id', schoolId);

    final sums = <String, List<double>>{};
    final names = <String, String>{};
    for (final s in subjects) {
      final map = mapRow(s);
      names[map['id'] as String] = map['name'] as String;
    }

    for (final r in results) {
      final map = mapRow(r);
      final subjectId = map['subject_id'] as String;
      final max = (map['max_marks'] as num).toDouble();
      if (max <= 0) continue;
      final pct = ((map['marks_obtained'] as num).toDouble() / max) * 100;
      sums.putIfAbsent(subjectId, () => []).add(pct);
    }

    return sums.entries
        .map(
          (e) => SubjectTrend(
            subjectId: e.key,
            subjectName: names[e.key] ?? 'Subject',
            averagePercentage:
                e.value.reduce((a, b) => a + b) / e.value.length,
          ),
        )
        .toList()
      ..sort((a, b) => b.averagePercentage.compareTo(a.averagePercentage));
  }
}
