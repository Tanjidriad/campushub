import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:book_user_app/l10n/app_localizations.dart';

class ChatInputArea extends StatefulWidget {
  final TextEditingController controller;

  const ChatInputArea({super.key, required this.controller});

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isTyping = widget.controller.text.trim().isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() {
        _isTyping = isTyping;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border(top: BorderSide(color: AppColors.of(context).border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).textPrimary.withOpacity(0.02),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 1. Plus / Attachment Button
            _buildIconButton(
              icon: Icons.add,
              color: AppColors.of(context).accent, // iOS Blue / Messenger Blue
              onTap: () {},
            ),

            SizedBox(width: 8.w),

            // 2. Make Offer Icon Button
            // Replaces the bulky "Make Offer" text button
            _buildIconButton(
              icon: Iconsax.dollar_circle,
              color: const Color(
                0xFFFE2C55,
              ), // Distinction color (e.g. TikTok/accent) or Green
              onTap: () {
                // Trigger offer logic
              },
              tooltip: l10n.makeAnOffer,
            ),

            SizedBox(width: 12.w),

            // 3. Modern Pill Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.of(
                    context,
                  ).inputFill, // Messenger/Telegram grey
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TextField(
                          controller: widget.controller,
                          minLines: 1,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.of(context).textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.typeMessage,
                            hintStyle: TextStyle(
                              color: AppColors.of(context).textSecondary,
                              fontSize: 15.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Emoji Icon inside the text field
                    Padding(
                      padding: EdgeInsets.only(right: 8.w, bottom: 6.h),
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        color: AppColors.of(context).textSecondary,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // 4. Send Button
            // Animates or changes color based on typing state is common,
            // but for now we keep the sleek circle style.
            GestureDetector(
              onTap: _isTyping
                  ? () {
                      // Send logic
                      widget.controller.clear();
                    }
                  : null, // Disable if empty? Or keep enabled for mic like WhatsApp
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _isTyping
                      ? AppColors.of(context).accent
                      : AppColors.of(context).subtleFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isTyping
                      ? Iconsax.send_15
                      : Icons.mic, // Switch to mic if not typing (mock)
                  color: _isTyping
                      ? AppColors.of(context).onPrimary
                      : AppColors.of(context).accent,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6.h), // Align with text field bottom
        child: Icon(icon, color: color, size: 28.sp),
      ),
    );
  }
}
