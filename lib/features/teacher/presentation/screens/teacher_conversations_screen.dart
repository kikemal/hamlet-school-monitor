import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_error_view.dart';
import '../widgets/teacher_loading_view.dart';

class TeacherConversationsScreen extends ConsumerStatefulWidget {
  const TeacherConversationsScreen({super.key});

  @override
  ConsumerState<TeacherConversationsScreen> createState() => _TeacherConversationsScreenState();
}

class _TeacherConversationsScreenState extends ConsumerState<TeacherConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final teacherId = authState.profile?.id;

    if (teacherId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view conversations')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ref.read(teacherRepositoryProvider).fetchConversationsWithDetails(teacherId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const TeacherLoadingView();
          }

          if (snapshot.hasError) {
            return TeacherErrorView(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {});
              },
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _buildConversationTile(conversation, teacherId);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline, size: 64.w, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Conversations Yet',
              style: AppTypography.h3,
            ),
            SizedBox(height: 8.h),
            Text(
              'Start a conversation with parents to begin messaging.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation, String currentUserId) {
    final participant1 = conversation['participant1'] as Map<String, dynamic>?;
    final participant2 = conversation['participant2'] as Map<String, dynamic>?;
    
    final otherParticipant = participant1?['id'] == currentUserId ? participant2 : participant1;
    if (otherParticipant == null) return const SizedBox.shrink();

    final messages = conversation['messages'] as List?;
    final lastMessage = messages != null && messages.isNotEmpty 
        ? messages.last as Map<String, dynamic> 
        : null;
    
    final unreadCount = messages?.where((m) => 
        m['sender_id'] != currentUserId && m['is_read'] == false
    ).length ?? 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/teacher/messages');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(otherParticipant),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${otherParticipant['first_name']} ${otherParticipant['last_name']}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessage != null) ...[
                        Text(
                          _formatTime(lastMessage['created_at']),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage != null 
                              ? (lastMessage['content'] as String? ?? 'Attachment')
                              : 'No messages yet',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> participant) {
    final avatarUrl = participant['avatar_url'] as String?;
    final firstName = participant['first_name'] as String? ?? 'U';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: avatarUrl != null
          ? CachedNetworkImage(
              imageUrl: avatarUrl,
              width: 48.w,
              height: 48.w,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _buildAvatarPlaceholder(firstName),
            )
          : _buildAvatarPlaceholder(firstName),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      width: 48.w,
      height: 48.w,
      color: AppColors.secondary,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '';
    
    final dateTime = createdAt is DateTime 
        ? createdAt 
        : DateTime.tryParse(createdAt.toString());
    
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return DateFormat.jm().format(dateTime.toLocal());
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(dateTime.toLocal());
    } else {
      return DateFormat.yMd().format(dateTime.toLocal());
    }
  }
}
