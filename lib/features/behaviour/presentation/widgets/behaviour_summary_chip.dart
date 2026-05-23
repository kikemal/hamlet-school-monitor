import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/models/behaviour_models.dart';

/// Compact behaviour summary for profile / child cards.
class BehaviourSummaryChip extends StatelessWidget {
  const BehaviourSummaryChip({super.key, required this.summary});

  final BehaviourSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = summary.serious > 0
        ? Colors.red
        : summary.moderate > 0
            ? Colors.orange
            : summary.minor > 0
                ? Colors.amber
                : summary.positive > 0
                    ? Colors.green
                    : Theme.of(context).colorScheme.outline;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14.w, color: color),
          SizedBox(width: 4.w),
          Text(
            summary.headline,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
