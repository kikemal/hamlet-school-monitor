import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/chat_input.dart';
import '../../../../core/widgets/message_bubble.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_error_view.dart';
import '../widgets/teacher_loading_view.dart';

class TeacherChatScreen extends ConsumerStatefulWidget {
  final String parentId;

  const TeacherChatScreen({super.key, required this.parentId});

  @override
  ConsumerState<TeacherChatScreen> createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends ConsumerState<TeacherChatScreen> {
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
          .read(teacherRepositoryProvider)
          .markMessagesAsRead(conversationId, userId);
    } catch (e) {
      // Silently fail for read receipts
    }
  }

  Future<void> _handleSendMessage(String conversationId, String? senderId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || senderId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(teacherRepositoryProvider)
          .sendMessage(conversationId, senderId, text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _handleImageSend(String conversationId, String? senderId, File imageFile) async {
    if (senderId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(teacherRepositoryProvider)
          .sendMessageWithImage(conversationId, senderId, '', imageFile);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _handleFileSend(String conversationId, String? senderId, File file) async {
    if (senderId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(teacherRepositoryProvider)
          .sendMessageWithFile(conversationId, senderId, '', file);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send file: $e')),
        );
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
    final authState = ref.watch(authProvider);
    final teacherId = authState.profile?.id;

    if (teacherId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to chat')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: FutureBuilder(
        future: ref.read(teacherRepositoryProvider).getOrCreateConversation(teacherId, widget.parentId),
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

          final conversation = snapshot.data;
          if (conversation == null) {
            return const Center(child: Text('Failed to load conversation'));
          }

          return FutureBuilder<List<>>(
            future: ref.read(teacherRepositoryProvider).fetchMessages(conversation.id),
            builder: (context, messagesSnapshot) {
              if (messagesSnapshot.connectionState == ConnectionState.waiting) {
                return const TeacherLoadingView();
              }

              final messages = messagesSnapshot.data ?? [];

              // Mark messages as read when conversation opens
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
                _markAsRead(conversation.id, teacherId);
              });

              return Column(
                children: [
                  Expanded(
                    child: messages.isEmpty
                        ? _buildEmptyChatState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(16.w),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == teacherId;
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
                    onSend: () => _handleSendMessage(conversation.id, teacherId),
                    onImageSelected: (file) => _handleImageSend(conversation.id, teacherId, file),
                    onFileSelected: (file) => _handleFileSend(conversation.id, teacherId, file),
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

  Widget _buildEmptyChatState() {
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
            Text(
              'Start a Conversation',
              style: AppTypography.h3,
            ),
            SizedBox(height: 8.h),
            Text(
              'Send a message to begin your discussion.',
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
