import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/chat_input.dart';
import '../../../../core/widgets/message_bubble.dart';
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
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead(String conversationId, String userId) async {
    try {
      await ref
          .read(parentRepositoryProvider)
          .markMessagesAsRead(conversationId, userId);
    } catch (e) {
      // Silently fail for read receipts
    }
  }

  Future<void> _handleSendMessage(
    String conversationId,
    String? senderId,
  ) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || senderId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(conversationMessagesProvider.notifier)
          .sendMessage(senderId, text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _handleImageSend(
    String conversationId,
    String? senderId,
    File imageFile,
  ) async {
    if (senderId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(parentRepositoryProvider)
          .sendMessageWithImage(conversationId, senderId, '', imageFile);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _handleFileSend(
    String conversationId,
    String? senderId,
    File file,
  ) async {
    if (senderId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(parentRepositoryProvider)
          .sendMessageWithFile(conversationId, senderId, '', file);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send file: $e')));
      }
    } finally {
      setState(() => _isSending = false);
    }
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
                  style: AppTypography.caption.copyWith(color: Colors.white70),
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
                        errorWidget: (_, __, ___) =>
                            _buildAvatarPlaceholder(teacher.firstName),
                      )
                    : _buildAvatarPlaceholder(teacher.firstName),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
                if (parent != null) {
                  _markAsRead(conversation.id, parent.id);
                }
              });

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
                              return MessageBubble(
                                message: message,
                                isMe: isMe,
                                onImageTap: () {
                                  // Handle image tap - show full screen
                                },
                                onFileTap: () {
                                  // Handle file tap - open/download
                                },
                              );
                            },
                          ),
                  ),
                  ChatInput(
                    controller: _messageController,
                    onSend: () =>
                        _handleSendMessage(conversation.id, parent?.id),
                    onImageSelected: (file) =>
                        _handleImageSend(conversation.id, parent?.id, file),
                    onFileSelected: (file) =>
                        _handleFileSend(conversation.id, parent?.id, file),
                    isLoading: _isSending,
                  ),
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
              child: Icon(
                Icons.school_outlined,
                size: 64.w,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text('No Teacher Assigned', style: AppTypography.h3),
            SizedBox(height: 8.h),
            Text(
              'Your child is currently not assigned to a class with a teacher. Please reach out to the school administration to resolve this.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
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
              child: Icon(
                Icons.chat_bubble_outline,
                size: 48.w,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text('Start a Conversation', style: AppTypography.h3),
            SizedBox(height: 8.h),
            Text(
              'Send a message to ${teacher.firstName} ${teacher.lastName} to begin your 1-to-1 discussion.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
