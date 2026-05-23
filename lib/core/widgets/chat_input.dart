import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Future<void> Function(File imageFile)? onImageSelected;
  final Future<void> Function(File file)? onFileSelected;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onImageSelected,
    this.onFileSelected,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedFile;

  @override
  void dispose() {
    _selectedFile = null;
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        final file = File(image.path);
        setState(() => _selectedFile = file);
        
        if (widget.onImageSelected != null) {
          await widget.onImageSelected!(file);
          setState(() => _selectedFile = null);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null && mounted) {
        final file = File(result.files.single.path!);
        setState(() => _selectedFile = file);
        
        if (widget.onFileSelected != null) {
          await widget.onFileSelected!(file);
          setState(() => _selectedFile = null);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isEmpty && _selectedFile == null) return;

    widget.onSend();
    widget.controller.clear();
    setState(() => _selectedFile = null);
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedFile != null)
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, size: 16.sp, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        _selectedFile!.path.split('/').last,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => setState(() => _selectedFile = null),
                      child: Icon(Icons.close, size: 16.sp, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                if (widget.onImageSelected != null) ...[
                  IconButton(
                    icon: Icon(Icons.image, size: 24.sp, color: AppColors.primary),
                    onPressed: _pickImage,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                  ),
                  SizedBox(width: 8.w),
                ],
                if (widget.onFileSelected != null) ...[
                  IconButton(
                    icon: Icon(Icons.attach_file, size: 24.sp, color: AppColors.primary),
                    onPressed: _pickFile,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                  ),
                  SizedBox(width: 8.w),
                ],
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TextField(
                      controller: widget.controller,
                      maxLines: null,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: widget.isLoading ? null : _handleSend,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: widget.isLoading ? AppColors.primary.withOpacity(0.5) : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20.w,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
