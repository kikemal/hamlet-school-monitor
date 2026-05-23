import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';

class ParentChatScreen extends ConsumerStatefulWidget {
  const ParentChatScreen({super.key});

  @override
  ConsumerState<ParentChatScreen> createState() => _ParentChatScreenState();
}

class _ParentChatScreenState extends ConsumerState<ParentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherAsync = ref.watch(childClassTeacherProvider);
    final activeConversationAsync = ref.watch(activeConversationProvider);

    return Scaffold(
      appBar: AppBar(
        title: teacherAsync.when(
          data: (teacher) {
            if (teacher == null) return const Text('Chat');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${teacher.firstName} ${teacher.lastName}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Class Teacher',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            );
          },
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Chat'),
        ),
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: teacherAsync.when(
            data: (teacher) {
              if (teacher == null) return const Icon(Icons.chat);
              return ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: teacher.avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: teacher.avatarUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _buildAvatarPlaceholder(teacher.firstName),
                      )
                    : _buildAvatarPlaceholder(teacher.firstName),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Icon(Icons.error),
          ),
        ),
      ),
      body: teacherAsync.when(
        loading: () => const ParentLoadingView(),
        error: (e, _) => ParentErrorView(
          message: e.toString(),
          onRetry: () {
            ref.invalidate(childClassTeacherProvider);
          },
        ),
        data: (teacher) {
          if (teacher == null) {
            return _buildNoTeacherState();
          }

          return activeConversationAsync.when(
            loading: () => const ParentLoadingView(),
            error: (e, _) => ParentErrorView(
              message: e.toString(),
              onRetry: () {
                ref.invalidate(activeConversationProvider);
              },
            ),
            data: (conversation) {
              if (conversation == null) {
                return _buildNoTeacherState();
              }

              final messages = ref.watch(conversationMessagesProvider);
              final parent = ref.watch(authProvider).profile;

              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

              return Column(
                children: [
                  Expanded(
                    child: messages.isEmpty
                        ? _buildEmptyChatState(teacher)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(16.w),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == parent?.id;
                              return _buildMessageBubble(context, message, isMe);
                            },
                          ),
                  ),
                  _buildInputArea(parent?.id),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      color: AppColors.secondary,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'T',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNoTeacherState() {
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
              child: Icon(Icons.school_outlined, size: 64.w, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Teacher Assigned',
              style: AppTypography.h3,
            ),
            SizedBox(height: 8.h),
            Text(
              'Your child is currently not assigned to a class with a teacher. Please reach out to the school administration to resolve this.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState(teacher) {
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
              child: Icon(Icons.chat_bubble_outline, size: 48.w, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'Start a Conversation',
              style: AppTypography.h3,
            ),
            SizedBox(height: 8.h),
            Text(
              'Send a message to ${teacher.firstName} ${teacher.lastName} to begin your 1-to-1 discussion.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, message, bool isMe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = message.createdAt != null
        ? DateFormat.jm().format(message.createdAt!.toLocal())
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, left: isMe ? 40.w : 0, right: isMe ? 0 : 40.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: AppTypography.bodyMedium.copyWith(
                color: isMe
                    ? Colors.white
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeStr,
                style: AppTypography.caption.copyWith(
                  fontSize: 10.sp,
                  color: isMe
                      ? Colors.white70
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(String? senderId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  style: AppTypography.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () async {
                final text = _messageController.text.trim();
                if (text.isEmpty || senderId == null) return;

                _messageController.clear();
                try {
                  await ref
                      .read(conversationMessagesProvider.notifier)
                      .sendMessage(senderId, text);
                  _scrollToBottom();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send message: $e')),
                    );
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
