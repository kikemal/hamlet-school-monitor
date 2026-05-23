import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/shared/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onImageTap;
  final VoidCallback? onFileTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onImageTap,
    this.onFileTap,
  });

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.fileUrl != null) ...[
              _buildAttachment(context, isDark),
              if (message.content.isNotEmpty) SizedBox(height: 8.h),
            ],
            if (message.content.isNotEmpty)
              Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isMe
                      ? Colors.white
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10.sp,
                    color: isMe
                        ? Colors.white70
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12.sp,
                    color: message.isRead ? Colors.white70 : Colors.white54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(BuildContext context, bool isDark) {
    if (message.fileType == 'image') {
      return GestureDetector(
        onTap: onImageTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(
            imageUrl: message.fileUrl!,
            fit: BoxFit.cover,
            width: 200.w,
            height: 200.h,
            placeholder: (context, url) => Container(
              width: 200.w,
              height: 200.h,
              color: isDark ? AppColors.surfaceDark : Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200.w,
              height: 200.h,
              color: isDark ? AppColors.surfaceDark : Colors.grey[300],
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onFileTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(),
              size: 24.sp,
              color: isMe ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                message.fileName ?? 'Attachment',
                style: AppTypography.bodySmall.copyWith(
                  color: isMe ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    switch (message.fileType) {
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.attach_file;
    }
  }
}
