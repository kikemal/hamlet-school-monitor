import '../../../shared/domain/entities/behaviour_log.dart';

/// Parsed behaviour log for UI across teacher, parent, and admin.
class BehaviourLogDisplayItem {
  const BehaviourLogDisplayItem({
    required this.log,
    required this.severity,
    required this.notes,
    this.studentName,
    this.teacherName,
  });

  final BehaviourLog log;
  final String severity;
  final String notes;
  final String? studentName;
  final String? teacherName;

  bool get isPositive =>
      log.incidentType.toLowerCase() == 'positive' ||
      log.incidentType.toLowerCase().contains('achievement');

  static const _legacyPattern = r'^\[(low|medium|high|minor|moderate|serious)\]\s*(.*)$';

  static BehaviourLogDisplayItem fromLog(
    BehaviourLog log, {
    String? studentName,
    String? teacherName,
  }) {
    var severity = log.severity ?? 'moderate';
    var notes = log.description;

    final match = RegExp(_legacyPattern, caseSensitive: false)
        .firstMatch(log.description.trim());
    if (match != null) {
      severity = _normalizeSeverity(match.group(1)!);
      notes = match.group(2)!.trim();
    } else if (log.severity != null) {
      severity = _normalizeSeverity(log.severity!);
    }

    return BehaviourLogDisplayItem(
      log: log,
      severity: severity,
      notes: notes,
      studentName: studentName,
      teacherName: teacherName,
    );
  }

  static String _normalizeSeverity(String raw) {
    switch (raw.toLowerCase()) {
      case 'low':
      case 'minor':
        return 'minor';
      case 'high':
      case 'serious':
        return 'serious';
      default:
        return 'moderate';
    }
  }

  static String encodeDescription({
    required String severity,
    required String notes,
  }) =>
      '[${_normalizeSeverity(severity)}] ${notes.trim()}';
}

/// Summary counts for profile cards and dashboards.
class BehaviourSummary {
  const BehaviourSummary({
    this.total = 0,
    this.minor = 0,
    this.moderate = 0,
    this.serious = 0,
    this.positive = 0,
    this.recentIncidents = 0,
  });

  final int total;
  final int minor;
  final int moderate;
  final int serious;
  final int positive;
  final int recentIncidents;

  int get negativeIncidents => minor + moderate + serious;

  String get headline {
    if (total == 0) return 'No incidents';
    if (serious > 0) return '$serious serious';
    if (moderate > 0) return '$moderate moderate';
    if (minor > 0) return '$minor minor';
    return '$positive positive';
  }
}
