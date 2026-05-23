import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/parent_page_header.dart';

class ParentChatScreen extends ConsumerWidget {
  const ParentChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Messages',
            subtitle: 'Chat with teachers',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64.w,
                      color: AppColors.textSecondaryLight,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Chat Feature',
                      style: AppTypography.h3,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '1-to-1 chat with teachers will be implemented with Supabase Realtime.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
